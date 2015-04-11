import os
import math
import subprocess
import random
import numpy

def sample_wr(population, k):
    "Chooses k random elements (with replacement) from a population"
    n = len(population)
    _random, _int = random.random, int  # speed hack 
    result = [None] * k
    for i in xrange(k):
        j = _int(_random() * n)
        result[i] = population[j]
    return result

########################################
	
#f = open("standard_model.church")
f = open("standard_model_uniform.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

# get priors from slider experiment (23)
pdir = "/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/_priors/"
rfile = open("results/results.txt","w")	
pline = ch_model.index("(define theprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1))")
iline = ch_model.index("(define item 'blabla)")

for p in os.listdir(pdir):
	if p.endswith(".txt"):
		print "processing..." + p
		itemname = p[:len(p)-4]
		pfile = open(pdir+p)
		lines = [l.rstrip() for l in pfile.readlines()]
		pfile.close()
		plength = len(lines)
		means = []
		# run each item with 100 samples from empirical prior
		for j in range(100):
			samples = sample_wr(lines, plength)
			splitsamples = [s.split() for s in samples]
			means = []
			for i in range(16):
				means.append(str(numpy.mean([float(s[i]) for s in splitsamples])))
#			print means
			strmeans = " ".join(means)
			# here starts the church business
			ch_model[pline] = "(define theprior (list %s))"%strmeans
			ch_model[iline] = "(define item '%s)"%itemname
			ofile = open("m.church","w")
			ofile.write("\n".join(ch_model))
			ofile.close()
		#	print ofile.name
			subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
			subresults.communicate()[0]
		#		print "".join(open("results_simulation/raw/test.txt").readlines())
			rfile.write("".join(open("results/raw_results.txt").readlines()))
	
#rfile = open("results.txt","w")	
#rfile.write("".join(results))
rfile.close()
