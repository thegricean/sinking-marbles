# run with one of the following commands:
# 
# python mungeCSV.py wonky_tfbtPosterior_predictiveAnddiscreteParams_mh10000b1000.csv regula
#
# python mungeCSV.py wonky_tfbtPosterior_predictiveAnddiscreteParams_3speakerOptimalities_mh10000b1000.csv 3speakers
#
# python mungeCSV.py wonky_tfbtPosterior_predictiveAnddiscreteParams_softmaxWonky_mh10000b1000.csv wonkysoftmax
#
# python mungeCSV.py wonky_tfbtPosterior_predictiveAnddiscreteParams_3speakerOptimalities_softmaxWonky_mh10000b1000.csv 3sp-ws
#
# python mungeCSV.py wonky_tfbtPosterior_predictiveAnddiscreteParams_3speakerOptimalities_2betas_softmaxWonky_mh10000b1000.csv 3sp-ws-2betas

import sys

f = open(sys.argv[1])
lines = [l.rstrip() for l in f.readlines()]
f.close()

mungetype = sys.argv[2] # can be regular, 3speakers, wonkysoftmax, 3sp-ws, 3sp-ws-2betas
headers = {"regular":["SpeakerOptimality","WonkinessPrior","LinkingBetaConcentration","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"],"3speakers":["SpeakerOptimality1","SpeakerOptimality2","SpeakerOptimality3","WonkinessPrior","LinkingBetaConcentration","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"],"wonkysoftmax":["SpeakerOptimality","WonkinessPrior","LinkingBetaConcentration","WonkySoftmax","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"],"3sp-ws":["SpeakerOptimality1","SpeakerOptimality2","SpeakerOptimality3","WonkinessPrior","LinkingBetaConcentration","WonkySoftmax","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"],"3sp-ws-2betas":["SpeakerOptimality1","SpeakerOptimality2","SpeakerOptimality3","WonkinessPrior","LinkingBetaConcentration_allprob","LinkingBetaConcentration_wonky","WonkySoftmax","PosteriorProbability","Measure","Item","Quantifier","Response","Probability"]}

outfile = open("munged_"+mungetype+".csv","w")
outfile.write(",".join(headers[mungetype]))
outfile.write("\n")

for l in lines[1:]:
	splited = l.split(",")
	if mungetype == "regular":
		speakerOptimality = splited.pop(0).strip("\"")
		wonkinessPrior = splited.pop(0)		
		linkingBetaConcentration = splited.pop(0)	
		posteriorProb = splited.pop().strip("\"")		
		while len(splited) > 0:
			measure = splited.pop(0)
			item = splited.pop(0)
			quantifier = splited.pop(0)
			response = splited.pop(0)
			probability = splited.pop(0).strip("\"")		
			outfile.write(",".join([speakerOptimality, wonkinessPrior,linkingBetaConcentration,posteriorProb,measure,item,quantifier,response,probability]))
			outfile.write("\n")
	elif mungetype == "3speakers":
		speakerOptimality1 = splited.pop(0).strip("\"")
		speakerOptimality2 = splited.pop(0)
		speakerOptimality3 = splited.pop(0)		
		wonkinessPrior = splited.pop(0)		
		linkingBetaConcentration = splited.pop(0)	
		posteriorProb = splited.pop().strip("\"")	
		while len(splited) > 0:
			measure = splited.pop(0)
			item = splited.pop(0)
			quantifier = splited.pop(0)
			response = splited.pop(0)
			probability = splited.pop(0).strip("\"")		
			outfile.write(",".join([speakerOptimality1,speakerOptimality2,speakerOptimality3, wonkinessPrior,linkingBetaConcentration,posteriorProb,measure,item,quantifier,response,probability]))
			outfile.write("\n")
	elif mungetype == "wonkysoftmax":
		speakerOptimality = splited.pop(0).strip("\"")
		wonkinessPrior = splited.pop(0)		
		linkingBetaConcentration = splited.pop(0)
		wonkysoftmax = splited.pop(0)			
		posteriorProb = splited.pop().strip("\"")				
		while len(splited) > 0:
			measure = splited.pop(0)
			item = splited.pop(0).strip("\"")
			quantifier = splited.pop(0)
			response = splited.pop(0)
			probability = splited.pop(0).strip("\"")		
			outfile.write(",".join([speakerOptimality, wonkinessPrior,linkingBetaConcentration,wonkysoftmax,posteriorProb,measure,item,quantifier,response,probability]))
			outfile.write("\n")
	elif mungetype == "3sp-ws":
		speakerOptimality1 = splited.pop(0).strip("\"")
		speakerOptimality2 = splited.pop(0)
		speakerOptimality3 = splited.pop(0)		
		wonkinessPrior = splited.pop(0).strip("\"")		
		linkingBetaConcentration = splited.pop(0)
		wonkysoftmax = splited.pop(0)				
		posteriorProb = splited.pop().strip("\"")				
		while len(splited) > 0:
			measure = splited.pop(0)
			item = splited.pop(0)
			quantifier = splited.pop(0)
			response = splited.pop(0)
			probability = splited.pop(0).strip("\"")		
			outfile.write(",".join([speakerOptimality1,speakerOptimality2,speakerOptimality3, wonkinessPrior,linkingBetaConcentration,wonkysoftmax,posteriorProb,measure,item,quantifier,response,probability]))
			outfile.write("\n")			
	elif mungetype == "3sp-ws-2betas":
		speakerOptimality1 = splited.pop(0).strip("\"")
		speakerOptimality2 = splited.pop(0)
		speakerOptimality3 = splited.pop(0)		
		wonkinessPrior = splited.pop(0).strip("\"")		
		linkingBetaConcentration_allprob = splited.pop(0)
		linkingBetaConcentration_wonky = splited.pop(0)		
		wonkysoftmax = splited.pop(0)				
		posteriorProb = splited.pop().strip("\"")				
		while len(splited) > 0:
			measure = splited.pop(0)
			item = splited.pop(0)
			quantifier = splited.pop(0)
			response = splited.pop(0)
			probability = splited.pop(0).strip("\"")		
			outfile.write(",".join([speakerOptimality1,speakerOptimality2,speakerOptimality3, wonkinessPrior,linkingBetaConcentration_allprob,linkingBetaConcentration_wonky,wonkysoftmax,posteriorProb,measure,item,quantifier,response,probability]))
			outfile.write("\n")			
	else:
		print "something's gone wrong"
			
	
		
outfile.close()		

	
