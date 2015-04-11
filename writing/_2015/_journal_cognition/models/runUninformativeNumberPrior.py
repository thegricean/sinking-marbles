import os
import math
import subprocess
import random
import numpy


f = open("wonkyworld-uniform-uninformative.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

# get priors from slider experiment (23)
pfile = open("smoothed_15marbles_priors_withnames.txt")
priors_15 = [l.rstrip() for l in pfile.readlines()[1:]]
pfile.close()

wpriors = [.3, .5, .6, .7, .8, .9]

rfile = open("modelresults/results_uniform_uninformative.txt.tmp.results","w")
	
pline = ch_model.index("(define empiricalprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1))")
iline = ch_model.index("(define item 'blabla)")
wwline = ch_model.index("(define wonkyworld-prior .5)")

for k,p in enumerate(priors_15):
	psplit = p.split("\t")
	item = psplit[0]
	print item
	prior = " ".join(psplit[1:])
	print prior
	for ww in wpriors:
		ch_model[pline] = "(define empiricalprior (list %s))"%prior
		ch_model[iline] = "(define item '(%s))"%item
		#print ch_model[iline]
		ch_model[wwline] = "(define wonkyworld-prior %s)"%ww
		ofile = open("m.church","w")
		ofile.write("\n".join(ch_model))
		ofile.close()
		subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
		subresults.communicate()[0]
		rfile.write("".join(open("modelresults/raw_uniform_uninformative_results.txt.tmp.results").readlines()))
  
rfile.close()
#
#
#
#for p in os.listdir(pdir):
#	if p.endswith(".txt"):
#		print "processing..." + p
#		itemname = p[:len(p)-4]
#		pfile = open(pdir+p)
#		lines = [l.rstrip() for l in pfile.readlines()]
#		pfile.close()
#		plength = len(lines)
#		means = []
#		# run each item with 100 samples from empirical prior
#		for j in range(100):
#			samples = sample_wr(lines, plength)
#			splitsamples = [s.split() for s in samples]
#			means = []
#			for i in range(16):
#				means.append(str(numpy.mean([float(s[i]) for s in splitsamples])))
##			print means
#			strmeans = " ".join(means)
#			# here starts the church business
#			ch_model[pline] = "(define theprior (list %s))"%strmeans
#			ch_model[iline] = "(define item '%s)"%itemname
#			ofile = open("m.church","w")
#			ofile.write("\n".join(ch_model))
#			ofile.close()
#		#	print ofile.name
#			subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
#			subresults.communicate()[0]
#		#		print "".join(open("results_simulation/raw/test.txt").readlines())
#			rfile.write("".join(open("results/raw_results.txt").readlines()))
#	
##rfile = open("results.txt","w")	
##rfile.write("".join(results))
#rfile.close()
