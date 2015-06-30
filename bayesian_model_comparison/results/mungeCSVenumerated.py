# run with one of the following commands:
#
# python mungeCSVenumerated.py FILENAME

import sys

f = open(sys.argv[1])
lines = [l.rstrip() for l in f.readlines()]
f.close()

headers = ["SpeakerOptimality","WonkinessPrior","LinkingBetaConcentration","WonkySoftmax","PosteriorProbability"]

outfile = open("munged_enumerated.csv","w")
outfile.write(",".join(headers))
outfile.write("\n")

for l in lines[1:]:
	splited = l.split(",")
	speakerOptimality = splited.pop(0).strip("\"")
	wonkinessPrior = splited.pop(0)		
	linkingBetaConcentration = splited.pop(0)	
	wonkysoftmax = splited.pop(0).strip("\"")		
	posteriorProb = splited.pop().strip("\"")		
	outfile.write(",".join([speakerOptimality, wonkinessPrior,linkingBetaConcentration,wonkysoftmax,posteriorProb]))
	outfile.write("\n")			
	
		
outfile.close()		

	
