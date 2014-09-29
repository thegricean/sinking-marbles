import os
import math
import subprocess

########################################
	
f = open("sinking_marbles.church")
ch_model = [l.rstrip() for l in f.readlines()]
f.close()

rfile = open("results.txt","w")	
#results = []

w = ch_model.index("(define null-cost 20)")

parameters = range(21)

#print parameters[0]
print len(parameters)

for p in parameters:
	ch_model[w] = "(define null-cost %s)"%p
	print p
#	print ch_model[w]
	ofile = open("m.church","w")
	ofile.write("\n".join(ch_model))
	ofile.close()
#	print ofile.name
	subresults = subprocess.Popen(['church',ofile.name], stdout=subprocess.PIPE)
	subresults.communicate()[0]
#		print "".join(open("results_simulation/raw/test.txt").readlines())
	rfile.write("".join(open("results/results_simulation/raw_results.txt").readlines()))
	
#rfile = open("results.txt","w")	
#rfile.write("".join(results))
rfile.close()