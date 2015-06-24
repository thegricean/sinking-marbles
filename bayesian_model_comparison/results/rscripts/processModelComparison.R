library(tidyr)

setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_model_comparison/results/")
#source("../rscripts/helpers.r")

d = read.csv("munged.csv",sep=",",quote="")
head(d)
summary(d)

ggplot(d, aes(SpeakerOptimality)) +
  geom_histogram() +
  facet_grid(PosteriorProbability~Measure)
