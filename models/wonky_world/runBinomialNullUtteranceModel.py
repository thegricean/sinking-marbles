import os
import math
import subprocess

########################################
	
f = open("wonkyworld-binomial-nullutterance.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

pfile = open("smoothed_15marbles_priors.txt") # get smoothed priors (kernel density estimates)
priors_15 = [l.rstrip() for l in pfile.readlines()[1:]]
pfile.close()
#print priors
#pfile = open("smoothed_priors_15_bwdefault.txt") # get smoothed priors (kernel density estimates with bw=default)
#priors_bwdf = [l.rstrip() for l in pfile.readlines()]
#pfile.close()

wpriors = [.1, .3, .5]
costs = [.5, 1, 5]

rfile = open("results/model_results/results_binomial_nullutterance.txt","w")	
#results = []

w = ch_model.index("(define alternatives '(nullutterance some all none))")
pline = ch_model.index("(define empiricalprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 5))")
wline = ch_model.index("	'(prior)")
wwline = ch_model.index("(define wonkyworld-prior .5)")
cline = ch_model.index("	'(nullutterance-cost)")
ccline = ch_model.index("(define costs (list 1 1 1 1))")

alternatives = [["some","all","none"]#,
	#["some","all","none","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],
#["some","all","none","one","two","three","four","five","six","seven","eight","nine","ten"],	
#                ["some","all","none","most","many","few", "afew"],
 #               ["some","all","none","most","many","few", "afew","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],
 #               ["some","all","none","most","many","few", "afew","one","two","three","four","five","six","seven","eight","nine","ten"],                 
#				["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone"],
#				["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone"],			
 #               ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone","morethanhalf","allbutone","lessthanhalf"],     
 #               ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone","morethanhalf","allbutone","lessthanhalf"]                

                ]

for i,a in enumerate(alternatives):
	print a
	for k,p in enumerate(priors_15):
		print p
		for ww in wpriors:   
			for c in costs:				     
				alts = " ".join(a)        
				ch_model[w] = "(define alternatives '(nullutterance %s))"%alts
				ch_model[pline] = "(define empiricalprior (list %s))"%p
				ch_model[wline] = "'(prior_15)"
				ch_model[wwline] = "(define wonkyworld-prior %s)"%ww
				clist = " ".join([str(c)]+["1" for el in a])
				ch_model[ccline] = "(define costs (list %s))"%clist	
				ofile = open("m.church","w")
				ofile.write("\n".join(ch_model))
				ofile.close()
				subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
				subresults.communicate()[0]
				rfile.write("".join(open("results/model_results/raw_binomial_nullutterance_results.txt").readlines()))
  

rfile.close()
