import os
import math
import subprocess

########################################
	
f = open("standard_model.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

rfile = open("results.txt","w")	
#results = []

w = ch_model.index("(define alternatives '(some all))")

alternatives = [["some","all","none"],
                ["some","all","none","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],
                ["some","all","none","most","many","few", "half","several"],
                ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"],                
                ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone"],
                ["some","all","none","most","many","few", "half","several","one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","acouple","afew","almostnone","veryfew","almostall","overhalf","alot","notone","onlyone","everyone","notmany","justone","morethanhalf","allbutone","lessthanhalf"]]

#print parameters[0]
#print len(parameters)

for i,a in enumerate(alternatives):
    alts = " ".join(a)#([alt for altset in alternatives[0:i+1] for alt in altset])
    print alts
    ch_model[w] = "(define alternatives '(%s))"%alts
#	print p
#	print ch_model[w]
    ofile = open("m.church","w")
    ofile.write("\n".join(ch_model))
    ofile.close()
#	print ofile.name
    subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
    subresults.communicate()[0]
#		print "".join(open("results_simulation/raw/test.txt").readlines())
    rfile.write("".join(open("results_simulation/raw_results.txt").readlines()))
	
#rfile = open("results.txt","w")	
#rfile.write("".join(results))
rfile.close()
