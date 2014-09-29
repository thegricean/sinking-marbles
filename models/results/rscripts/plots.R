theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/models/results/")
d = read.table("results_simulation/parsed_results.tsv", sep="\t", header=T)
head(d)
nrow(d)
# should be:
21*3*4*25
summary(d)

ggplot(d, aes(x=PriorAllProbability,y=PosteriorAllProbability, color=as.factor(TotalMarbles))) +
  geom_point() +
  geom_line() +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave(file="graphs/modelpredictions.pdf",width=20,height=30)

dlowhigh = subset(d, NullUtteranceCost %in% c(1,10,20))
dlowhigh = droplevels(dlowhigh)

ggplot(dlowhigh, aes(x=PriorAllProbability,y=PosteriorAllProbability, color=as.factor(TotalMarbles))) +
  geom_point() +
  geom_line() +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave(file="graphs/modelpredictions-lowhigh.pdf",width=20,height=7)

## simulation results without lexical uncertainty
d = read.table("results_simulation/parsed_results_no_uncertainty.tsv", sep="\t", header=T)
head(d)
nrow(d)
# should be:
21*3*4*25
summary(d)

ggplot(d, aes(x=PriorAllProbability,y=PosteriorAllProbability, color=as.factor(TotalMarbles))) +
  geom_point() +
  geom_line() +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave(file="graphs/modelpredictions_nouncertainty.pdf",width=20,height=30)

dlowhigh = subset(d, NullUtteranceCost %in% c(1,10,20))
dlowhigh = droplevels(dlowhigh)

ggplot(dlowhigh, aes(x=PriorAllProbability,y=PosteriorAllProbability, color=as.factor(TotalMarbles))) +
  geom_point() +
  geom_line() +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave(file="graphs/modelpredictions-lowhigh_nouncertainty.pdf",width=20,height=7)
