import csv
import itertools
import random
import ast
import sys


#usage 
# python parseResults.py 

fname = 'modelresults/results_uniform_untruthful.txt.tmp.results'
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


headers = ["Item","QUD","State","Alternatives","WonkyWorldPrior","Quantifier","SpeakerOptimality","PosteriorProbability"]        
k = 0
wwcnt = -1
condcnt = 0
priorcnt = 0
numww = 5
while k < len(lines):
	if lines[k] == "alternatives":
#		if priorcnt < 89:
#			if wwcnt < numww:
#				wwcnt = wwcnt + 1							
#			else:
#				priorcnt = priorcnt+1		
#				wwcnt = 0
#		else:
#			if wwcnt < numww:
#				wwcnt = wwcnt + 1							
#			else:		
#				priorcnt = 0
#				wwcnt = 0
#
#		print items[priorcnt]
#		print priorcnt
#		print wwcnt

		k = k + 1
		alts = getReducedAlternatives(lines[k])	
		k = k + 2
		item = lines[k][:-1].replace(","," ")
		k = k + 4
		wonkyworldprior = lines[k]	
		k = k  + 1			
		quantifier = lines[k].split(",")[1]
		k = k + 1
		qud = lines[k].split(",")[1]
		k = k + 1      
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		states = pairs[0].split(",")
		probs = pairs[1].split(",")
#		print pairs
#		print k
		for j,s in enumerate(states):
			prob = probs[j]
			print prob
			results.append([item,qud,s,alts,wonkyworldprior,quantifier,spopt,prob])
		k = k + 1
		priorcnt = priorcnt + 1		
	elif lines[k].startswith("quantifier"):
		quantifier = lines[k].split(",")[1]
		k = k + 1
		qud = lines[k].split(",")[1]
		k = k + 1		
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		states = pairs[0].split(",")
		probs = pairs[1].split(",")
#		print pairs
#		print k
		for j,s in enumerate(states):
			prob = probs[j]
			results.append([item,qud,s,alts,wonkyworldprior,quantifier,spopt,prob])
		k = k + 1
		priorcnt = priorcnt + 1		
	elif lines[k].startswith("speaker-opt"):
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		states = pairs[0].split(",")
		probs = pairs[1].split(",")
#		print pairs
#		print k
		for j,s in enumerate(states):
			prob = probs[j]
			results.append([item,qud,s,alts,wonkyworldprior,quantifier,spopt,prob])
		k = k + 1
		priorcnt = priorcnt + 1		
	elif lines[k].startswith("qud"):
		qud = lines[k].split(",")[1]
		k = k + 1
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		states = pairs[0].split(",")
		probs = pairs[1].split(",")
#		print pairs
#		print k
		for j,s in enumerate(states):
			prob = probs[j]
			results.append([item,qud,s,alts,wonkyworldprior,quantifier,spopt,prob])
		k = k + 1
		priorcnt = priorcnt + 1		
	else:
		#print lines[k]
		print "this shouldn't be happening"			
	print priorcnt		
	

for r in results:
	inner_dict = dict(zip(headers,r))
	wresults.append(inner_dict)

oname = 'modelresults/parsed_uniform_untruthful_results.tsv'
w = csv.DictWriter(open(oname, 'wb'),fieldnames=headers,restval="NA",delimiter="\t")

w.writeheader()
w.writerows(wresults)
