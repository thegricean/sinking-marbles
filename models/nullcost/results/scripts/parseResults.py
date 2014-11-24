import csv
import itertools
import random
import ast
import sys


#usage 
# python parseResults.py results.txt

fname = '../../'+sys.argv[1]
file_names = [fname]

lines = []
headers = ["TotalMarbles","NullUtteranceCost","SpeakerOptimality","PriorAllProbability","PosteriorAllProbability"]
results = []
wresults = []

files = [open(fn) for fn in file_names]

for f in files:
	lines.extend([l.rstrip() for l in f.readlines()])
	
#print lines	

k = 0
mcnt = 0
condcnt = 0
while k < len(lines):
	if lines[k] == "null-cost":
		mcnt = mcnt + 1
		k = k + 1
		nullcost = lines[k]
		k = k + 1
		priors = [l for l in lines[k].split(",")]	
		k = k + 1
		spopt = lines[k].split(",")[1]
		k = k + 1
		marbles = lines[k].split(",")[1]
		k = k + 1
		for j in range(25): # 20 is the number of unique speaker optimality & total marbles parameters. change as necessary
			probs = lines[k].split(",")
			for i in range(len(probs)):
				results.append([marbles, nullcost, spopt, priors[i], probs[i]])
			if j != 24: # adjust this depending on parameter above	
				k = k + 1
#				print lines[k]
				spopt = lines[k].split(",")[1]
				k = k + 1
				marbles = lines[k].split(",")[1]
				k = k + 1
			else:
				k = k + 1
	else:
		print "this shouldn't be happening"			


#print results
for r in results:
	inner_dict = dict(zip(headers,r))
	wresults.append(inner_dict)

oname = '../results_simulation/parsed_results.tsv'
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-uniform.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-simple.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-partitive.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
w = csv.DictWriter(open(oname, 'wb'),fieldnames=headers,restval="NA",delimiter="\t")

w.writeheader()
w.writerows(wresults)
