import csv
import itertools
import random
import ast
import sys


#usage 
# python parseResults.py results.txt

fname = '../results/'+sys.argv[1]
file_names = [fname]

lines = []
results = []
wresults = []

files = [open(fn) for fn in file_names]

for f in files:
	lines.extend([l.rstrip() for l in f.readlines()])
	
#print lines

def getReducedAlternatives(alts):
	basic = ""
	num = ""
	extra = ""
	if "some,all,none" in alts:
		basic = "basic"
	if "one,two,three" in alts:
		num = "num"
	if "many" in alts:
		extra = "extra"

	return "".join([basic,num,extra])


headers = ["QUD","NumState","Alternatives","SpeakerOptimality","PriorProbability-0","PriorProbability-1to50","PriorProbability-51to99","PriorProbability-100","PosteriorProbability"]        
k = 0
mcnt = 0
condcnt = 0
while k < len(lines):
	if lines[k] == "alternatives":
		mcnt = mcnt + 1
		k = k + 1
		alts = getReducedAlternatives(lines[k])
		k = k + 1
		priors = lines[k].split(",")
		k = k + 1
		qud = lines[k].split(",")[1]
		k = k + 1      
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		print pairs
		print k
		ssize = pairs[0].split(",")
		prob = pairs[1].split(",")            
		for j in range(len(ssize)):
			results.append([qud, ssize[j], alts, spopt, priors[0], priors[1], priors[2], priors[3], prob[j]])
		k = k + 1
	elif lines[k].startswith("speaker-opt"):
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		print pairs
		ssize = pairs[0].split(",")
		prob = pairs[1].split(",")            
		for j in range(len(ssize)):
			results.append([qud, ssize[j], alts, spopt, priors[0], priors[1], priors[2], priors[3], prob[j]])
		k = k + 1
	elif lines[k].startswith("qud"):
		qud = lines[k].split(",")[1]
		k = k + 1
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		print pairs
		ssize = pairs[0].split(",")
		prob = pairs[1].split(",")            
		for j in range(len(ssize)):
			results.append([qud, ssize[j], alts, spopt, priors[0], priors[1], priors[2], priors[3], prob[j]])
		k = k + 1
	else:
		#print lines[k]
		print "this shouldn't be happening"			
		
#print results
for r in results:
	inner_dict = dict(zip(headers,r))
	wresults.append(inner_dict)

oname = '../results/data/parsed_results.tsv'
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-uniform.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-simple.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-partitive.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
w = csv.DictWriter(open(oname, 'wb'),fieldnames=headers,restval="NA",delimiter="\t")

w.writeheader()
w.writerows(wresults)
