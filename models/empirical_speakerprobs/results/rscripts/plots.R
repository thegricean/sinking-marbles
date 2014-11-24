theme_set(theme_bw())
#setwd("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/models/empirical_speakerprobs/results")
#source("~/cogsci/qp_linguistics/projectfiles/rscripts/helperfunctions.R")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/models/empirical_speakerprobs/results")

# model with empirical spekaer probabilities
d = read.csv("parsed_simplest_model.txt.tsv",sep="\t")
head(d)
ggplot(d, aes(x=PriorAllProbability,y=PosteriorAllProbability)) +
  geom_point()
ggsave(file="graphs/predictions_with_empirical_speakerprobs.pdf")

# base model with number terms and some/all/none, no utterance cost
d = data.frame(Prior=rep(c(.1,.2,.3,.4,.5, .6, .7, .8, .85, .9, .95, .99),3),SpeakerOptimality=rep(c(0,1,2),each=12),Posterior=c(0.07604562737642585, 0.15624999999999997, 0.24096385542168688, 0.3305785123966942, 0.4255319148936169, 0.5263157894736842, 0.6334841628959273, 0.7476635514018692, 0.8076009501187646, 0.8695652173913044, 0.9336609336609336, 0.9865470852017937, 0.038373905744094, 0.15624999999999997, 0.3343782654127483, 0.5302402651201327, 0.7032967032967035, 0.8333333333333331, 0.919270680658967, 0.96932979931844, 0.984054863612422, 0.9934460158675404, 0.9984830870690735, 0.9999428981184786, 0.01829158603854346, 0.15624999999999997, 0.4402303656447676, 0.7198492815566742, 0.8876560332871012, 0.9619238476953907, 0.9892893450840607, 0.9978243800607525, 0.9992307552381848, 0.999807432625898, 0.999979505254446, 0.9999998550723167))

ggplot(d, aes(x=Prior,y=Posterior,color=as.factor(SpeakerOptimality))) +
  geom_point()
ggsave(file="graphs/predictions_base_model.pdf")
