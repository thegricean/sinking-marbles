import os
import math
import subprocess
import random
import numpy


f = open("standard_model.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

# get priors from slider experiment (23)
pfile = open("betapriors.txt")
priors_15 = [l.rstrip() for l in pfile.readlines()[1:]]
pfile.close()

rfile = open("modelresults/results_rsa_betapriors.txt.tmp.results","w")
	
pline = ch_model.index("(define theprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1))")
iline = ch_model.index("(define item 'blabla)")

for k,p in enumerate(priors_15):
	psplit = p.split("\t")
	item = psplit[0]
	print item
	prior = " ".join(psplit[1:])
#	print prior
	ch_model[pline] = "(define theprior (list %s))"%prior
	ch_model[iline] = "(define item '(%s))"%item
#	print ch_model[pline]
#	print ch_model[iline]
	ofile = open("m.church","w")
	ofile.write("\n".join(ch_model))
	ofile.close()
	subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
	subresults.communicate()[0]
	rfile.write("".join(open("modelresults/raw_rsa_betapriors_results.txt.tmp.results").readlines()))
  
rfile.close()
