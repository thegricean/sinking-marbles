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
	
f = open("wonkyworld-uniform.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

pfile = open("smoothed_15marbles_priors.txt") # get smoothed priors (kernel density estimates)
priors_15 = [l.rstrip() for l in pfile.readlines()[1:]]
pfile.close()

wpriors = [.3, .5, .7, .9]

# get priors from slider experiment (23)
pdir = "/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/_priors/"
rfile = open("results/model_results/results_uniform_sliderpriors.txt.tmp.results","w")	

pline = ch_model.index("(define empiricalprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 1 5))")
wline = ch_model.index("	'(prior)")
iline = ch_model.index("(define item 'blabla)")
wwline = ch_model.index("(define wonkyworld-prior .1)")

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
#			print strmeans
			# here starts the church business
			for ww in wpriors:		
#				print "wonkyprior: "+str(ww)
				ch_model[pline] = "(define empiricalprior (list %s))"%strmeans
				ch_model[wline] = "'(prior_15)"			
				ch_model[iline] = "(define item '%s)"%itemname
				ch_model[wwline] = "(define wonkyworld-prior %s)"%ww			
				ofile = open("m.church","w")
				ofile.write("\n".join(ch_model))
				ofile.close()
		#	print ofile.name
				subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
				subresults.communicate()[0]
		#		print "".join(open("results_simulation/raw/test.txt").readlines())
				rfile.write("".join(open("results/model_results/raw_uniform_results.txt.tmp.results").readlines()))
	
rfile.close()
