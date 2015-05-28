library(ggplot2)
library(plyr)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/")
source("rscripts/helpers.r")

load("data/r.RData")

# r1 = read.csv("data/sinking_marbles1.csv", header=T)
# r1$workerid = r1$workerid + 60
# 
# r = rbind(r1,read.csv("data/sinking_marbles2.csv", header=T))
nrow(r)
head(r)
summary(r$workerid)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("assignmentid","workerid", "rt", "cause", "effect","language","gender.1","age","gender", "response", "object","num_objects","trial","enjoyment","asses","comments","Answer.time_in_minutes","responsetype")]
r$Item = as.factor(paste(r$effect,r$object))
table(r$Item)/4

## add old priors to data.frame
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = priorprobs$Item
mpriorprobs = melt(priorprobs, id.vars=c("Item"))
head(mpriorprobs)
row.names(mpriorprobs)= paste(mpriorprobs$variable, mpriorprobs$Item)
head(mpriorprobs)

r$PriorAllProbabilityNum = mpriorprobs[paste("X15",as.character(r$Item), sep=" "),]$value


# figure out if people understood the task
spr = r %>% 
  select(responsetype,response,Item,workerid) %>%
  spread(responsetype,response) 

nrow(spr)
head(spr)
spr$interval = spr$ci_high - spr$ci_low
summary(spr)
# are there cases where people reversed low and high ci value?
spr[spr$interval < 0,]
# exclude these 10 trials, and also exclude subject 49 who reversed on 7 trials
r = droplevels(subset(r, workerid != 49))
r = droplevels(subset(r, workerid != 110 | Item != "dissolved oreos"))
r = droplevels(subset(r, workerid != 72 | Item != "melted pencils"))
r = droplevels(subset(r, workerid != 43 | Item != "popped eggs"))
nrow(r) # 7128 cases left

save(r, file="data/r.RData")

spr = r %>% 
  select(responsetype,response,Item,workerid) %>%
  spread(responsetype,response) 

nrow(spr)
head(spr)
spr$interval = spr$ci_high - spr$ci_low
summary(spr)

ggplot(spr, aes(x=interval,y=confidence)) +
  geom_point() +
  geom_smooth() #+
  #facet_wrap(~Item,scale="free")

best_guesses = droplevels(subset(r, responsetype == "best_guess"))
library(np)
library(plyr)
smoothed_dist15 = ddply(best_guesses, .(Item), summarise, State = c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),SmoothedProportion = (npudens(tdat=ordered(response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001)/sum(npudens(tdat=ordered(response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001))
smoothed_dist15$SmoothedProportion = format(round(smoothed_dist15$SmoothedProportion,7), scientific=F)
casted = dcast(smoothed_dist15, Item ~ State, value.var="SmoothedProportion")
head(casted)
write.table(casted,file="data/smoothed_15marbles_priors_withnames.txt",row.names=F,quote=F,sep="\t")
write.table(casted,file="../../../models/wonky_world/fourstep_15marbles_priors_withnames.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,2:length(colnames(casted))],file="data/smoothed_15marbles_priors.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,1],file="data/items.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,2:length(colnames(casted))],file="../../../models/wonky_world/fourstep_15marbles_priors.txt",row.names=F,quote=F,sep="\t")


head(smoothed_dist15)
summary(smoothed_dist15)
sum(smoothed_dist15[smoothed_dist15$Item == "ate the seeds birds",]$SmoothedProportion)

expectations = ddply(r, .(Item), summarise, expectation=sum(npudens(tdat=ordered(response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens*seq(0,15)),densitysum=sum(npudens(tdat=ordered(response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens))
expectations$expectation_corr = expectations$expectation/expectations$densitysum
head(expectations)

mean(expectations$expectation_corr)
median(expectations$expectation_corr)

ggplot(expectations, aes(x=expectation_corr)) +
  geom_histogram() +
  scale_x_continuous()

head(expectations)
write.table(expectations[,c("Item","expectation_corr")],row.names=F,sep="\t",quote=F,file="data/expectations.txt")
ordered = expectations[order(expectations[,c("expectation_corr")]),c("Item","expectation_corr")]
write.table(ordered[,c("Item","expectation_corr")],row.names=F,sep="\t",quote=F,file="data/ordered_expectations.txt")
t = table(r$Item)
t

priors = as.data.frame(prop.table(table(best_guesses$Item,best_guesses$response),mar=c(1)))
head(priors)
priors[priors$Var1 == "ate the seeds butterflies",]$Freq
colnames(priors) = c("Item","State","EmpiricalProportion")
row.names(smoothed_dist15) = paste(smoothed_dist15$State,smoothed_dist15$Item)
priors$SmoothedProportion = smoothed_dist15[paste(priors$State, priors$Item),]$SmoothedProportion
head(priors)
plot(priors$SmoothedProportion,priors$EmpiricalProportion)

# add previous priors
## add old priors to data.frame
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = priorprobs$Item
mpriorprobs = melt(priorprobs, id.vars=c("Item"))
head(mpriorprobs)
row.names(mpriorprobs)= paste(mpriorprobs$variable, mpriorprobs$Item)
head(mpriorprobs)
priors$OriginalSmoothedProportion = mpriorprobs[paste(paste("X",priors$State,sep=""), priors$Item, sep=" "),]$value
head(priors)

## add slider priors to data.frame
spriorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/23_sinking-marbles-prior-sliders-exactly/results/data/aggregated_priors.csv",sep="\t", header=T, quote="")
head(spriorprobs)
nrow(spriorprobs)
row.names(spriorprobs) = paste(spriorprobs$slider_id,spriorprobs$Item)

priors$SliderPrior = spriorprobs[paste(priors$State,as.character(priors$Item), sep=" "),]$normresponse
priors$SliderPriorYMin = spriorprobs[paste(priors$State,as.character(priors$Item), sep=" "),]$YMin
priors$SliderPriorYMax = spriorprobs[paste(priors$State,as.character(priors$Item), sep=" "),]$YMax
head(priors)
summary(priors)

save(priors, file="data/priors.RData")


##################

ggplot(aes(x=gender.1), data=r) +
  geom_histogram()

ggplot(aes(x=rt), data=r) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,50000))

ggplot(aes(x=age), data=r) +
  geom_histogram()

ggplot(aes(x=age,fill=gender.1), data=r) +
  geom_histogram()

ggplot(aes(x=enjoyment), data=r) +
  geom_histogram()

ggplot(aes(x=asses), data=r) +
  geom_histogram()

ggplot(aes(x=Answer.time_in_minutes), data=r) +
  geom_histogram()

ggplot(aes(x=age,y=Answer.time_in_minutes,color=gender.1), data=unique(r[,c("assignmentid","age","Answer.time_in_minutes","gender.1")])) +
  geom_point() +
  
  geom_smooth()

unique(r$comments)

