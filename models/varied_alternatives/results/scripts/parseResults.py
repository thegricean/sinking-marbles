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
results = []
wresults = []

files = [open(fn) for fn in file_names]

for f in files:
	lines.extend([l.rstrip() for l in f.readlines()])
	
#print lines

def getReducedAlternatives(alts):
    if alts == "some,all,none,":
        return "basic"
    elif alts == "some,all,none,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,":
        return "basicnum"
    elif alts == "some,all,none,most,many,few,half,several,":
        return "basicextra"    
    elif alts == "some,all,none,most,many,few,half,several,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,":
        return "basicnumextra"
    elif alts == "some,all,none,most,many,few,half,several,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,acouple,afew,almostnone,veryfew,almostall,overhalf,alot,notone,onlyone,everyone,notmany,justone,":
        return "basicnumextratwo"
    elif alts == "some,all,none,most,many,few,half,several,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,acouple,afew,almostnone,veryfew,almostall,overhalf,alot,notone,onlyone,everyone,notmany,justone,morethanhalf,allbutone,lessthanhalf,":
        return "full_alts"
    else:
        print "unknown alternatives"


headers = ["QUD","TotalMarbles","NumState","Alternatives","SpeakerOptimality","PriorAllProbability","PosteriorProbability"]        
k = 0
mcnt = 0
condcnt = 0
while k < len(lines):
	if lines[k] == "alternatives":
		mcnt = mcnt + 1
		k = k + 1
		alts = getReducedAlternatives(lines[k])
		k = k + 1
		priors = [l for l in lines[k].split(",")]	
		k = k + 1
		qud = lines[k].split(",")[1]
		k = k + 1
		marbles = lines[k].split(",")[1]
		k = k + 1        
		spopt = lines[k].split(",")[1]
		k = k + 1
        	pairs = lines[k].split(",,,")
            	print pairs
        	for i,p in enumerate(pairs): # 14 is the number of simulated prior values
            		probs = p.split(",,")
            		ssize = probs[0].split(",")
            		prob = probs[1].split(",")            
            		for j in range(len(ssize)):
				results.append([qud, marbles, ssize[j], alts, spopt, priors[i], prob[j]])
        	k = k + 1
	elif lines[k].startswith("speaker-opt"):
        	spopt = lines[k].split(",")[1]
        	k = k + 1
        	pairs = lines[k].split(",,,")
        	for i,p in enumerate(pairs): # 14 is the number of simulated prior values
            		probs = p.split(",,")
            		ssize = probs[0].split(",")
            		prob = probs[1].split(",")            
			for j in range(len(ssize)):
				results.append([qud, marbles, ssize[j], alts, spopt, priors[i], prob[j]])
        	k = k + 1
    	elif lines[k].startswith("total-marbles"):
		marbles = lines[k].split(",")[1]
		k = k + 1        
		spopt = lines[k].split(",")[1]
		k = k + 1
        	pairs = lines[k].split(",,,")
        	for i,p in enumerate(pairs): # 14 is the number of simulated prior values
			probs = p.split(",,")
            		ssize = probs[0].split(",")
            		prob = probs[1].split(",")            
			for j in range(len(ssize)):
				results.append([qud, marbles, ssize[j], alts, spopt, priors[i], prob[j]])
        	k = k + 1
        elif lines[k].startswith("qud"):
		qud = lines[k].split(",")[1]
		k = k + 1
                marbles = lines[k].split(",")[1]
                k = k + 1
                spopt = lines[k].split(",")[1]
                k = k + 1
                pairs = lines[k].split(",,,")
                for i,p in enumerate(pairs): # 14 is the number of simulated prior values
                        probs = p.split(",,")
                        ssize = probs[0].split(",")
                        prob = probs[1].split(",")
                        for j in range(len(ssize)):
                                results.append([qud, marbles, ssize[j], alts, spopt, priors[i], prob[j]])
                k = k + 1
	else:
		#print lines[k]
		print "this shouldn't be happening"			


#print results
for r in results:
	inner_dict = dict(zip(headers,r))
	wresults.append(inner_dict)

oname = '../data/parsed_results.tsv'
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-uniform.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-simple.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
#w = csv.DictWriter(open('../results-simulation/parsed/pragmatic-speaker-partitive.csv', 'wb'),fieldnames=headers,restval="NA",delimiter="\t")
w = csv.DictWriter(open(oname, 'wb'),fieldnames=headers,restval="NA",delimiter="\t")

w.writeheader()
w.writerows(wresults)
