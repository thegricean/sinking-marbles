import os
import math
import subprocess

########################################
	
f = open("wonkyworld.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

#pfile = open("binned_priors.txt")
pfile = open("smoothed_priors_15_bw5.txt") # get smoothed priors (kernel density estimates with bw=5)
priors_bw5 = [l.rstrip() for l in pfile.readlines()]
pfile.close()
#print priors
pfile = open("smoothed_priors_15_bwdefault.txt") # get smoothed priors (kernel density estimates with bw=default)
priors_bwdf = [l.rstrip() for l in pfile.readlines()]
pfile.close()


rfile = open("results/model_results/results.txt","w")	
#results = []

w = ch_model.index("(define alternatives '(some all none))")
pline = ch_model.index("(define varprior (list .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 .1 1 5))")
wline = ch_model.index("	'(prior)")

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
    for k,p in enumerate(priors_bw5):
        print p
        alts = " ".join(a)        
#        alts = " ".join([alt for altset in alternatives[0:i+1] for alt in altset])
#        print alts
        ch_model[w] = "(define alternatives '(%s))"%alts
        ch_model[pline] = "(define varprior (list %s))"%p
        ch_model[wline] = "'(prior_bw5)"
#	print p
#	print ch_model[w]
        ofile = open("m.church","w")
        ofile.write("\n".join(ch_model))
        ofile.close()
#	print ofile.name
        subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
        subresults.communicate()[0]
#		print "".join(open("results_simulation/raw/test.txt").readlines())
        rfile.write("".join(open("results/model_results/raw_results.txt").readlines()))
  
        
for i,a in enumerate(alternatives):
    print a
    for k,p in enumerate(priors_bwdf):
        print p
        alts = " ".join(a)        
#        alts = " ".join([alt for altset in alternatives[0:i+1] for alt in altset])
#        print alts
        ch_model[w] = "(define alternatives '(%s))"%alts
        ch_model[pline] = "(define varprior (list %s))"%p
        ch_model[wline] = "'(prior_bwdf)"
#	print p
#	print ch_model[w]
        ofile = open("m.church","w")
        ofile.write("\n".join(ch_model))
        ofile.close()
#	print ofile.name
        subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
        subresults.communicate()[0]
#		print "".join(open("results_simulation/raw/test.txt").readlines())
        rfile.write("".join(open("results/model_results/raw_results.txt").readlines()))        
	
#rfile = open("results.txt","w")	
#rfile.write("".join(results))
rfile.close()
