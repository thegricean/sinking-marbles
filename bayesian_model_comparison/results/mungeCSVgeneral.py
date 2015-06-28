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
headers = [s.strip("\"") for s in lines[0].split(",")]
pp = headers.pop(-2)
numheaders = len(headers)
nheaders = headers + ["Measure","Item","Quantifier","Response","Probability"]
print headers

outfile = open("munged_"+mungetype+".csv","w")
outfile.write(",".join(nheaders))
outfile.write("\n")

for l in lines[1:]:
	splited = l.split(",")
	resultline = []
	for i in range(numheaders):
		resultline.append(splited.pop(0).strip("\""))
		resultline.append(splited.pop().strip("\""))
		while len(splited) > 0:
			resultline.append(splited.pop(0).strip("\""))		
			outfile.write(",".join(resultline))
			outfile.write("\n")
				
		
outfile.close()		

	
