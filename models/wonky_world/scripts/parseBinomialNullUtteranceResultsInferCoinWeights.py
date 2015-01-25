import csv
import itertools
import random
import ast
import sys


#usage 
# python parseResults.py 

fname = '../results/model_results/results_binomial_nullutterance_infer3coinweights.txt.tmp.results'
file_names = [fname]

itemfile = open("items.txt")
items = [" ".join(l.rstrip().split()) for l in itemfile.readlines()]
itemfile.close()
print items

lines = []
results = []
wresults = []

files = [open(fn) for fn in file_names]

for f in files:
	lines.extend([l.rstrip() for l in f.readlines()])
	
#print lines

def getReducedAlternatives(alts):
	basic = ""
	lownum = ""
	highnum = ""	
	extra = ""
	twowords = ""
	threewords = ""	
	
	if "some,all,none" in alts:
		basic = "0_basic"
	if "one,two,three" in alts:
		lownum = "1_lownum"
	if "eleven" in alts:
		highnum = "3_highnum"
	if "many" in alts:
		extra = "2_extra"
	if "almostall" in alts:
		twowords = "4_twowords"
	if "lessthanhalf" in alts:
		threewords = "5_threewords"

	return "".join([basic,lownum,extra,highnum,twowords,threewords])


headers = ["Item","QUD","CoinWeight","NullUtteranceCost","Alternatives","WonkyWorldPrior","Quantifier","SpeakerOptimality","PosteriorProbability"]        
k = 0
wwcnt = 0
condcnt = 0
priorcnt = 0
nccnt = -1
while k < len(lines):
	if lines[k] == "alternatives":
		if priorcnt < 89:
			if wwcnt < 2:
				if nccnt < 2:
					nccnt = nccnt + 1
				else:
					wwcnt = wwcnt + 1				
					nccnt = 0					
			else:
				if nccnt < 2:
					nccnt = nccnt + 1
				else:			
					priorcnt = priorcnt+1		
					wwcnt = 0
					nccnt = 0
		else:
			if wwcnt < 2:
				if nccnt < 2:
					nccnt = nccnt + 1
				else:
					wwcnt = wwcnt + 1				
					nccnt = 0					
			else:		
				if nccnt < 2:
					nccnt = nccnt + 1
				else:			
					priorcnt = 0
					wwcnt = 0
					nccnt = 0

		print items[priorcnt]
		print priorcnt
		print wwcnt
		print nccnt

		k = k + 1
		alts = getReducedAlternatives(lines[k])
		k = k + 4
		wonkyworldprior = lines[k]	
		k = k  + 2
		nullcost = lines[k]			
		k = k + 1
		quantifier = lines[k].split(",")[1]
		k = k + 1
		qud = lines[k].split(",")[1]
		k = k + 1      
		spopt = lines[k].split(",")[1]
		k = k + 1
		combs = lines[k].split(",,")
		print combs
		pairs = combs[0].split(",")
		print pairs
		probs = combs[1].split(",")
		print probs
#		print pairs
#		print k
		for j,pa in enumerate(pairs):
			ssize = pairs[j]
			prob = probs[j]
			results.append([items[priorcnt],qud, ssize, nullcost, alts, wonkyworldprior,  quantifier, spopt, prob])
		k = k + 1
	elif lines[k].startswith("quantifier"):
		quantifier = lines[k].split(",")[1]
		k = k + 1
		qud = lines[k].split(",")[1]
		k = k + 1		
		spopt = lines[k].split(",")[1]
		k = k + 1
		combs = lines[k].split(",,")
		pairs = combs[0].split(",")
		probs = combs[1].split(",")
#		print pairs
#		print k
		for j,pa in enumerate(pairs):
			ssize = pairs[j]
			prob = probs[j]
			results.append([items[priorcnt],qud, ssize, nullcost, alts, wonkyworldprior, quantifier, spopt, prob])
		k = k + 1
	elif lines[k].startswith("speaker-opt"):
		spopt = lines[k].split(",")[1]
		k = k + 1
		combs = lines[k].split(",,")
		pairs = combs[0].split(",")
		probs = combs[1].split(",")
#		print pairs
#		print k
		for j,pa in enumerate(pairs):
			ssize = pairs[j]
			prob = probs[j]
			results.append([items[priorcnt],qud, ssize, nullcost, alts, wonkyworldprior, quantifier, spopt, prob])
		k = k + 1
	elif lines[k].startswith("qud"):
		qud = lines[k].split(",")[1]
		k = k + 1
		spopt = lines[k].split(",")[1]
		k = k + 1
		combs = lines[k].split(",,")
		pairs = combs[0].split(",")
		probs = combs[1].split(",")
#		print pairs
#		print k
		for j,pa in enumerate(pairs):
			ssize = pairs[j]
			prob = probs[j]
			results.append([items[priorcnt],qud,  ssize, nullcost, alts, wonkyworldprior, quantifier, spopt, prob])
		k = k + 1
	else:
		#print lines[k]
		print "this shouldn't be happening"			
		
#print results
for r in results:
	inner_dict = dict(zip(headers,r))
	wresults.append(inner_dict)

oname = '../results/data/parsed_binomial_nullutterance_3coinweights_results.tsv'
w = csv.DictWriter(open(oname, 'wb'),fieldnames=headers,restval="NA",delimiter="\t")

w.writeheader()
w.writerows(wresults)
