import os
import math
import subprocess

########################################
	
f = open("wonkyworld-uniform.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

pfile = open("prits.txt") # get inferred priors
priors_15 = [l.rstrip() for l in pfile.readlines()[1:]]
pfile.close()

wpriors = [.3, .5, .6, .7, .8, .9]


rfile = open("results/model_results/results_uniform.txt.tmp.results","w")	
#results = []

w = ch_model.index("(define alternatives '(some all none))")
pline = ch_model.index("(define empiricalprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 1 5))")
wline = ch_model.index("	'(prior)")
wwline = ch_model.index("(define wonkyworld-prior .1)")

alternatives = [["some","all","none"]]

for i,a in enumerate(alternatives):
    print a
    for k,p in enumerate(priors_15):
		print p
		for ww in wpriors:
			alts = " ".join(a)        
			ch_model[w] = "(define alternatives '(%s))"%alts
			ch_model[pline] = "(define empiricalprior (list %s))"%p
			ch_model[wline] = "'(prior_15)"
			ch_model[wwline] = "(define wonkyworld-prior %s)"%ww
			ofile = open("m.church","w")
			ofile.write("\n".join(ch_model))
			ofile.close()
			subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
			subresults.communicate()[0]
			rfile.write("".join(open("results/model_results/raw_uniform_results.txt.tmp.results").readlines()))
  
rfile.close()
