import os
import math
import subprocess

########################################
	
#f = open("standard_model.church")
f = open("standard_model_uniform.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

#pfile = open("binned_priors.txt")
pfile = open("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_epsilon.txt") # get smoothed priors (add-epsilon smoothing)
priors = [l.rstrip() for l in pfile.readlines()[1:]]
pfile.close()
print priors

rfile = open("results/results.txt","w")	
#results = []

w = ch_model.index("(define alternatives '(some all none))")
pline = ch_model.index("(define theprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1))")

alternatives = [["some","all","none"]]#,
#	["some","all","none","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],
#["some","all","none","one","two","three","four","five","six","seven","eight","nine","ten"],	
#                ["some","all","none","most","many","few", "afew"],
#                ["some","all","none","most","many","few", "afew","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],
#                ["some","all","none","most","many","few", "afew","one","two","three","four","five","six","seven","eight","nine","ten"],                 
#				["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone"],
#				["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone"],			
#                ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone","morethanhalf","allbutone","lessthanhalf"],     
#                ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone","morethanhalf","allbutone","lessthanhalf"]                
#
#                ]

for i,a in enumerate(alternatives):
    print a
    for k,p in enumerate(priors):
        print p
        alts = " ".join(a)        
        ch_model[w] = "(define alternatives '(%s))"%alts
        ch_model[pline] = "(define theprior (list %s))"%p
#	print p
#	print ch_model[w]
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
