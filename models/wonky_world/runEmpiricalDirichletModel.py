import os
import math
import subprocess

########################################
	
f = open("wonkyworld-empiricaldirichlet-infermarbles.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

pfile = open("smoothed_15marbles_priors.txt") # get smoothed priors (kernel density estimates)
priors_15 = [l.rstrip() for l in pfile.readlines()[1:]]
pfile.close()
#print priors
#pfile = open("smoothed_priors_15_bwdefault.txt") # get smoothed priors (kernel density estimates with bw=default)
#priors_bwdf = [l.rstrip() for l in pfile.readlines()]
#pfile.close()


rfile = open("results/model_results/results_empiricaldirichlet_infermarbles.txt","w")	
#results = []

w = ch_model.index("(define alternatives '(some all none))")
pline = ch_model.index("(define empiricalprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 5))")
wline = ch_model.index("	'(prior)")
concentrationline = ch_model.index("(define concentration-param 1)")

cparams = [1, 3, 5]

alternatives = [["some","all","none"],
	["some","all","none","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],
["some","all","none","one","two","three","four","five","six","seven","eight","nine","ten"],	
                ["some","all","none","most","many","few", "afew"],
                ["some","all","none","most","many","few", "afew","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],
                ["some","all","none","most","many","few", "afew","one","two","three","four","five","six","seven","eight","nine","ten"],                 
				["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone"],
				["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone"],			
                ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone","morethanhalf","allbutone","lessthanhalf"],     
                ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone","morethanhalf","allbutone","lessthanhalf"]                

                ]

for i,a in enumerate(alternatives):
    print a
    for c in cparams:
	    for k,p in enumerate(priors_15):
	        print p
	        alts = " ".join(a)        
	#        alts = " ".join([alt for altset in alternatives[0:i+1] for alt in altset])
	#        print alts
	        ch_model[w] = "(define alternatives '(%s))"%alts
	        ch_model[pline] = "(define empiricalprior (list %s))"%p
	        ch_model[wline] = "'(prior_15)"
	        ch_model[concentrationline] = "(define concentration-param %s)"%c	        
	#	print p
	#	print ch_model[w]
	        ofile = open("m.church","w")
	        ofile.write("\n".join(ch_model))
	        ofile.close()
	#	print ofile.name
	        subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
	        subresults.communicate()[0]
	#		print "".join(open("results_simulation/raw/test.txt").readlines())
	        rfile.write("".join(open("results/model_results/raw_empiricaldirichlet_infermarbles_results.txt").readlines()))
  
        
rfile.close()
