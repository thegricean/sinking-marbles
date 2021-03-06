#' ---
#' title: "Prepare dataset for MH to do Bayesian model comparison"
#' author: "Judith Degen"
#' date: "June 19, 2015"
#' Form of dataset for csv:
#' measure | subject | item | utterance | response
#' ---
library(tidyr)

setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/_journal_cognition/data/")
source("../rscripts/helpers.r")

# get empirical comprehension data expectations (comp_state)
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")

#comp_state = r[r$quantifier %in% c("Some","All","None"),] %>% 
comp_state = r %>%   
  select(workerid, Item, quantifier, response) %>%
  rename(subject=workerid, item=Item, utterance=quantifier)
comp_state$measure = "comp_state"
nrow(comp_state)
# 240 subjects

# get empirical comprehension data (comp_allprob)
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")

comp_allprob = r[r$quantifier %in% c("Some","All","None") & r$Proportion == "100",] %>% 
  select(workerid, Item, quantifier, normresponse) %>%
  rename(subject=workerid, item=Item, utterance=quantifier, response=normresponse)
comp_allprob$measure = "comp_allprob"
comp_allprob$subject = comp_allprob$subject + 240 # adjust subject ID so there are no duplicates with the other two experiments
nrow(comp_allprob)
# 240 subjects

# get empirical wonkiness data (wonkiness)
#load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/data/r.RData")
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/11_sinking-marbles-normal/results/data/r.RData")

wonkiness = r[r$quantifier %in% c("Some","All","None"),] %>% 
  select(workerid, Item, quantifier, response) %>%
  rename(subject=workerid, item=Item, utterance=quantifier)
wonkiness$response = ifelse(wonkiness$response == "no",1,0)
wonkiness$measure = "wonkiness"
wonkiness$subject = wonkiness$subject + 480 # adjust subject ID so there are no duplicates with the other two experiments
# 120 subjects

d = droplevels(rbind(comp_state,comp_allprob,wonkiness),na.omit=T)
nrow(d)
str(d)
summary(d)
d = droplevels(d[!is.na(d$response),])
d[d$measure == "comp_allprob",]$response = round(d[d$measure == "comp_allprob",]$response, 1)
d[d$measure == "comp_allprob" & d$response == 0.0,]$response = 0.01
d[d$measure == "comp_allprob" & d$response == 1.0,]$response = 0.99

#write.csv(d,file="empirical.csv",row.names=F,quote=F)
write.csv(d,file="empirical_binarywonky.csv",row.names=F,quote=F)

d_nozero = droplevels(subset(d, !(measure == "comp_state" & utterance == "Some" & response == 0)))
nrow(d_nozero)
#write.csv(d_nozero,file="empirical_nozero.csv",row.names=F,quote=F)
write.csv(d_nozero,file="empirical_binarywonky_nozero.csv",row.names=F,quote=F)

# get prior probabilities from 4-step procedure
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
row.names(priorprobs) = priorprobs$Item
nrow(priorprobs)

write.csv(priorprobs,file="priors.csv",row.names=F,quote=F)

# get prior probabilities from original 1-step procedure
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
row.names(priorprobs) = priorprobs$Item
nrow(priorprobs)

write.csv(priorprobs,file="priors_original.csv",row.names=F,quote=F)

write.csv(priorprobs[c("laughed lawyers","melted ice cubes","stuck to the wall baseballs"),],file="priors_original_samplecases.csv",row.names=F,quote=F)
