theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/7_sinking-marbles-freeproduction/results/")
source("rscripts/helpers.r")
load("data/r.RData") # the dataset
summary(r)

agr = aggregate()