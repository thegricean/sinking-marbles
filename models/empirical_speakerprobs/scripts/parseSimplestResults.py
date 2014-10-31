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
headers = ["PriorAllProbability","PosteriorAllProbability"]
results = []
wresults = []

files = [open(fn) for fn in file_names]

for f in files:
	lines.extend([l.rstrip() for l in f.readlines()])

priors = lines[0].split(",")	
posteriors = lines[1].split(",")	

print priors
print posteriors

for i in range(len(posteriors)):
	results.append([priors[i],posteriors[i]])

#print results
for r in results:
	inner_dict = dict(zip(headers,r))
	wresults.append(inner_dict)

oname = '../results/parsed_'+sys.argv[1]+'.tsv'

w = csv.DictWriter(open(oname, 'wb'),fieldnames=headers,restval="NA",delimiter="\t")

w.writeheader()
w.writerows(wresults)
