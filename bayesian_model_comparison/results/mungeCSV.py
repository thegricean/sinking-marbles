import sys

f = open(sys.argv[1])
lines = [l.rstrip() for l in f.readlines()]
f.close()

outfile = open("munged.csv","w")
outfile.write(",".join(["SpeakerOptimality","WonkinessPrior","LinkingBetaConcentration","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"]))
outfile.write("\n")

for l in lines[1:]:
	splited = l.split(",")
	speakerOptimality = splited.pop(0).strip("\"")
	wonkinessPrior = splited.pop(0)		
	linkingBetaConcentration = splited.pop(0)	
	posteriorProb = splited.pop()		
#	print speakerOptimality
#	print linkingBetaConcentration
#	print wonkinessPrior
#	print posteriorProb
#	print splited[:10]
#	j = 0
	while len(splited) > 0:
		measure = splited.pop(0)
#			print measure
		item = splited.pop(0)
		quantifier = splited.pop(0)
		response = splited.pop(0)
		probability = splited.pop(0)
		outfile.write(",".join([speakerOptimality, wonkinessPrior,linkingBetaConcentration,posteriorProb,measure,item,quantifier,response,probability]))
		outfile.write("\n")
		
outfile.close()		

	
