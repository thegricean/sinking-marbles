import sys

f = open(sys.argv[1])
lines = [l.rstrip() for l in f.readlines()]
f.close()

mungetype = sys.argv[2] # can be regular, 3speakers, wonkysoftmax
headers = {"regular":["SpeakerOptimality","WonkinessPrior","LinkingBetaConcentration","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"],"3speakers":["SpeakerOptimality1","SpeakerOptimality2","SpeakerOptimality3","WonkinessPrior","LinkingBetaConcentration","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"],"wonkysoftmax":["SpeakerOptimality","WonkinessPrior","LinkingBetaConcentration","WonkySoftmax","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"]}

outfile = open("munged_"+mungetype+".csv","w")
outfile.write(",".join(headers[mungetype]))
outfile.write("\n")

for l in lines[1:]:
	splited = l.split(",")
	if mungetype == "regular":
		speakerOptimality = splited.pop(0).strip("\"")
		wonkinessPrior = splited.pop(0)		
		linkingBetaConcentration = splited.pop(0)	
		posteriorProb = splited.pop()		
		while len(splited) > 0:
			measure = splited.pop(0)
			item = splited.pop(0)
			quantifier = splited.pop(0)
			response = splited.pop(0)
			probability = splited.pop(0)
			outfile.write(",".join([speakerOptimality, wonkinessPrior,linkingBetaConcentration,posteriorProb,measure,item,quantifier,response,probability]))
			outfile.write("\n")
	elif mungetype == "3speakers":
		speakerOptimality1 = splited.pop(0).strip("\"")
		speakerOptimality2 = splited.pop(0)
		speakerOptimality3 = splited.pop(0)		
		wonkinessPrior = splited.pop(0)		
		linkingBetaConcentration = splited.pop(0)	
		posteriorProb = splited.pop()		
		while len(splited) > 0:
			measure = splited.pop(0)
			item = splited.pop(0)
			quantifier = splited.pop(0)
			response = splited.pop(0)
			probability = splited.pop(0)
			outfile.write(",".join([speakerOptimality1,speakerOptimality2,speakerOptimality3, wonkinessPrior,linkingBetaConcentration,posteriorProb,measure,item,quantifier,response,probability]))
			outfile.write("\n")
	elif mungetype == "wonkysoftmax":
		speakerOptimality = splited.pop(0).strip("\"")
		wonkinessPrior = splited.pop(0)		
		linkingBetaConcentration = splited.pop(0)
		wonkysoftmax = splited.pop(0)			
		posteriorProb = splited.pop()		
		while len(splited) > 0:
			measure = splited.pop(0)
			item = splited.pop(0)
			quantifier = splited.pop(0)
			response = splited.pop(0)
			probability = splited.pop(0)
			outfile.write(",".join([speakerOptimality, wonkinessPrior,linkingBetaConcentration,wonkysoftmax,posteriorProb,measure,item,quantifier,response,probability]))
			outfile.write("\n")
	else:
		print "something's gone wrong"
			
	
		
outfile.close()		

	
