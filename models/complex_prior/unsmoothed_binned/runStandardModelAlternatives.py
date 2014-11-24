import os
import math
import subprocess

########################################
	
f = open("standard_model.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

#pfile = open("binned_priors.txt")
pfile = open("binned_priors_smoothed.txt") # get smoothed priors (with 0.001 prob added to each state to avoid model freaking out about zero-states)
priors = [l.rstrip() for l in pfile.readlines()[1:]]
pfile.close()
print priors

rfile = open("results/results.txt","w")	
#results = []

w = ch_model.index("(define alternatives '(some all none))")
pline = ch_model.index("(define theprior (list .25 .25 .25 .25))")

alternatives = [["some","all","none"],
#                ["one","two","three"],#,"four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],
#                ["most","many","few", "a few"],
                ["some","all","none","one","two","three"],
                ["some","all","none","most","many","few", "afew"],
#                ["one","two","three","most","many","few", "a few"],
                ["some","all","none","most","many","few", "afew","one","two","three"],                
                ]
#                ["acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone"],
 #               ["morethanhalf","allbutone","lessthanhalf"]]

#print parameters[0]
#print len(parameters)

for i,a in enumerate(alternatives):
    print a
    for k,p in enumerate(priors):
        print p
        alts = " ".join(a)        
#        alts = " ".join([alt for altset in alternatives[0:i+1] for alt in altset])
#        print alts
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
