import csv
import itertools
import random
import ast
import sys


#usage 
# python parseResults.py results.txt

fname = '../results/'+sys.argv[1]
file_names = [fname]

itemfile = open("items.txt")
items = [" ".join(l.rstrip().split()) for l in itemfile.readlines()]
itemfile.close()
#print items

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


headers = ["Item","QUD","State","Alternatives","SpeakerOptimality","PosteriorProbability"]        
k = 0
mcnt = 0
condcnt = 0
priorcnt = -1
while k < len(lines):
	if lines[k] == "alternatives":
		if priorcnt < 89:
			priorcnt = priorcnt+1
		else:
			priorcnt = 0
#		mcnt = mcnt + 1
		k = k + 1
		alts = getReducedAlternatives(lines[k])
		k = k + 1
#		priors = lines[k].split(",")
		k = k + 1
		qud = lines[k].split(",")[1]
		k = k + 1      
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
#		print pairs
#		print k
		ssize = pairs[0].split(",")
		prob = pairs[1].split(",")            
		for j in range(len(ssize)):
#			print priorcnt
#			print len(items)
			results.append([items[priorcnt],qud, ssize[j], alts, spopt, prob[j]])
		k = k + 1
	elif lines[k].startswith("speaker-opt"):
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		#print pairs
		ssize = pairs[0].split(",")
		prob = pairs[1].split(",")            
		for j in range(len(ssize)):
			results.append([items[priorcnt],qud, ssize[j], alts, spopt, prob[j]])
		k = k + 1
	elif lines[k].startswith("qud"):
		qud = lines[k].split(",")[1]
		k = k + 1
		spopt = lines[k].split(",")[1]
		k = k + 1
		pairs = lines[k].split(",,")
		#print pairs
		ssize = pairs[0].split(",")
		prob = pairs[1].split(",")            
		for j in range(len(ssize)):
			results.append([items[priorcnt],qud, ssize[j], alts, spopt, prob[j]])
		k = k + 1
	else:
		#print lines[k]
		print "this shouldn't be happening"		
	print priorcnt
	print items[priorcnt]	
		
#print results
for r in results:
	inner_dict = dict(zip(headers,r))
	wresults.append(inner_dict)

oname = '../results/data/parsed_results.tsv'
w = csv.DictWriter(open(oname, 'wb'),fieldnames=headers,restval="NA",delimiter="\t")

w.writeheader()
w.writerows(wresults)
