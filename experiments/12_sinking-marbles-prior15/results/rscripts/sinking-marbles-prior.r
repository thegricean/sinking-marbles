library(ggplot2)
library(np)
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/")
#setwd("~/Dropbox/thegricean_sinking-marbles/experiments/1_sinking-marbles-prior/results/")
source("rscripts/summarySE.r")
r = read.table("data/sinking_marbles.tsv", sep="\t", header=T)
r = r[,c("workerid", "rt", "effect", "cause", "object_level", "response", "object")]

r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
#s = summarySE(r, measurevar="response", groupvars=c("effect", "object_level", "object"))
#priors = s
#save(priors, file="data/priors.RData")
load("data/priors.RData")
load("data/r.RData")

# write data for bayesian data analysis (fitting binomials to data in church)
tmp = ddply(r, .(Item), summarise, Responses=paste("(list ",paste(response,collapse=" "),")",sep=""))
head(tmp)
write.table(r[,c("Item","")])

## plot subject variability
ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~workerid)
ggsave(file="graphs/subject_variability.pdf",width=20,height=15)

# person 53 gave only one response -- exclude
r = droplevels(subset(r, workerid != "53"))

# how many judgments per item
min(table(r$Item))
max(table(r$Item))
t = as.data.frame(table(r$Item))
t[order(t[,c("Freq")]),]

## plot individual items
r$Item = as.factor(paste(r$effect,r$object))
ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~Item)
ggsave(file="graphs/item_variability.pdf",width=20,height=15)


r$Bin = as.factor(ifelse(r$response == 0, 0, ifelse(r$response < 8, 50, ifelse(r$response < 15, 99, 100))))
ggplot(r, aes(x=Bin)) +
  geom_histogram() +
  facet_wrap(~Item)
ggsave(file="graphs/item_variability_binned.pdf",width=20,height=15)

save(r, file="data/r.RData")

sank = subset(r, effect == "sank" & object == "balloons")
sank
ds = density(sank$response,n=16,from=0,to=15)#,bw=5)#,bw=2)
plot(ds$x,ds$y)
sum(ds$x*ds$y)
str(ds)

ds = density(sank$response,n=16,from=0,to=15)#,bw=5)#,bw=2)
plot(ds$x,ds$y)

seeds = subset(r, effect == "ate the seeds" & object == "birds")
seeds
d = density(seeds$response,n=16,from=0,to=15)#,bw=2)
plot(d$x,d$y)
sum(d$x*d$y)

# playing around, figuring out np package
# tmp = data.frame(Response=ordered(seeds[,c("response")]))
# #tmp = ordered(tmp,levels=c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15))
# bw = npudensbw(tmp)
# summary(bw)
# dens = npudens(tdat=tmp,edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))
# dens$dens
# sum(dens$dens)

ds = density(seeds$response,n=16,from=0,to=15)#,bw=5)#,bw=2)
plot(ds$x,ds$y)

felldown = subset(r, effect == "fell down" & object == "card towers")
felldown
df = density(felldown$response,n=16,from=0,to=15)#,bw=2)
plot(df$x,df$y)
sum(df$x*df$y)


expectations = ddply(r, .(effect,object), summarise, expectation=sum(density(response,n=16,from=0,to=15)$x*density(response,n=16,from=0,to=15)$y),densitysum=sum(density(response,n=16,from=0,to=15)$y))
expectations$expectation_corr = expectations$expectation/expectations$densitysum

# compute expectations; still need to normalize in the end because sum of density typically isn't 1
cexpectations = ddply(r, .(effect,object), summarise, expectation=sum(npudens(tdat=ordered(response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens*seq(0,15)),densitysum=sum(npudens(tdat=ordered(response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens))

cexpectations$expectation_corr = cexpectations$expectation/cexpectations$densitysum
head(cexpectations)

plot(cexpectations$expectation_corr,expectations$expectation_corr)
cor(cexpectations$expectation_corr,expectations$expectation_corr)
cexpectations$old_expectation = expectations$expectation_corr
plot(cexpectations$expectation_corr,cexpectations$old_expectation)

cexpectations[cexpectations$expectation_corr > 14.5 & cexpectations$old_expectation < 10,]
# OK so this test definitely suggests the npudens function is better for these data than the density function: for the two items "sugar cubes dissolved" and "white shirts got stained", where everyone says all of them dissolved/got stained, the expectation with density is only 9.6, and with npudens it's 15 (after correcting, ie normalizing by sum of density)

mean(cexpectations$expectation_corr)
median(cexpectations$expectation_corr)


ggplot(cexpectations, aes(x=expectation_corr)) +
  geom_histogram() +
  scale_x_continuous()

head(cexpectations)
nrow(priors)
nrow(cexpectations)
write.table(cexpectations[,c("effect","object","expectation_corr")],row.names=F,sep="\t",quote=F,file="data/expectations.txt")
ordered = cexpectations[order(cexpectations[,c("expectation_corr")]),c("effect","object","expectation_corr")]
write.table(ordered[,c("effect","object","expectation_corr")],row.names=F,sep="\t",quote=F,file="data/ordered_expectations.txt")
t = table(r$Item)
t

# get smoothed priors for model
smoothed_dist15 = ddply(r, .(effect,object), summarise, State = c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),SmoothedProportion = (npudens(tdat=ordered(response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001)/sum(npudens(tdat=ordered(response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001))

head(smoothed_dist15)
summary(smoothed_dist15)
sum(smoothed_dist15[smoothed_dist15$object == "birds",]$SmoothedProportion)

plot(seq(0,15,by=1),smoothed_dist15[smoothed_dist15$object == "birds",]$SmoothedProportion)

# add smoothed values to data.frame with empirical values

# get empirical unsmoothed priors
priors = as.data.frame(prop.table(table(r$Item,r$response),mar=c(1)))
head(priors)
priors[priors$Var1 == "ate the seeds butterflies",]$Freq
colnames(priors) = c("Item","State","EmpiricalProportion")
row.names(smoothed_dist15) = paste(smoothed_dist15$State,smoothed_dist15$effect,smoothed_dist15$object)
priors$SmoothedProportion = smoothed_dist15[paste(priors$State, priors$Item),]$SmoothedProportion
head(priors)

save(priors, file="data/priors.RData")

meltedpriors = melt(priors, measure.var=c("EmpiricalProportion","SmoothedProportion"),variable="ProportionType")
head(meltedpriors)

ggplot(meltedpriors, aes(x=State, y=value, color=ProportionType, group=ProportionType)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)
ggsave(file="graphs/empirical-vs-smoothed-priors.pdf",width=20,height=15)

library(reshape2)
smoothed_dist15$SmoothedProportion = format(round(smoothed_dist15$SmoothedProportion,7), scientific=F)
casted = dcast(smoothed_dist15, effect + object ~ State, value.var="SmoothedProportion")
write.table(casted,file="data/smoothed_15marbles_priors_withnames.txt",row.names=F,quote=F,sep="\t")
write.table(casted,file="../../../models/wonky_world/smoothed_15marbles_priors_withnames.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,3:length(colnames(casted))],file="data/smoothed_15marbles_priors.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,1:2],file="data/items.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,3:length(colnames(casted))],file="../../../models/wonky_world/smoothed_15marbles_priors_withnames.txt",row.names=F,quote=F,sep="\t")

ordered = casted[order(casted[,c("15")]),c("effect","object","15")]
write.table(ordered,file="data/ordered_allstateprobs.txt",row.names=F,quote=F,sep="\t")

## plot individual items
r$Item = as.factor(paste(r$effect,r$object))
row.names(cexpectations) = paste(cexpectations$effect,cexpectations$object)
r$Expectation = cexpectations[as.character(r$Item),]$expectation_corr
ggplot(r, aes(x=response)) +
  geom_histogram() +
  geom_vline(aes(xintercept=Expectation),color="red",size=1) +
  facet_wrap(~Item)
ggsave(file="graphs/item_variability.pdf",width=20,height=15)


##### SMOOTH PRIORS WITH LAPLACE (ie add-1)
resps = seq(0,15)
rred = r[,c("response","Item")]
head(rred)
rred = rbind(rred,data.frame(response = rep(resps,90), Item = rep(levels(rred$Item),each=16)))
nrow(rred)
nrow(r[,c("response","Item")])

t = as.data.frame(table(rred$Item, rred$response))
head(t)
colnames(t) = c("Item","State","Frequency")
nrow(t)

smoothed_dist15 = ddply(t, .(Item), summarise, State=State, SmoothedProportion=Frequency/sum(Frequency))
head(smoothed_dist15,17)

# compute expectations; still need to normalize in the end because sum of density typically isn't 1
expectations = ddply(smoothed_dist15, .(Item), summarise, expectation=sum(as.numeric(as.character(State))*SmoothedProportion))
head(expectations)

mean(expectations$expectation)
median(expectations$expectation)


ggplot(expectations, aes(x=expectation)) +
  geom_histogram() +
  scale_x_continuous()

head(expectations)
nrow(expectations)
write.table(expectations[,c("Item","expectation")],row.names=F,sep="\t",quote=F,file="data/expectations_laplace.txt")

# add smoothed values to data.frame with empirical values

# get empirical unsmoothed priors
priors = as.data.frame(prop.table(table(r$Item,r$response),mar=c(1)))
head(priors)
priors[priors$Var1 == "ate the seeds butterflies",]$Freq
colnames(priors) = c("Item","State","EmpiricalProportion")
row.names(smoothed_dist15) = paste(smoothed_dist15$State,smoothed_dist15$Item)
priors$SmoothedProportion = smoothed_dist15[paste(priors$State, priors$Item),]$SmoothedProportion
head(priors)

save(priors, file="data/priors_laplace.RData")

meltedpriors = melt(priors, measure.var=c("EmpiricalProportion","SmoothedProportion"),variable="ProportionType")
head(meltedpriors)

ggplot(meltedpriors, aes(x=State, y=value, color=ProportionType, group=ProportionType)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)
ggsave(file="graphs/empirical-vs-smoothed-priors-laplace.pdf",width=20,height=15)

library(reshape2)
smoothed_dist15$SmoothedProportion = format(round(smoothed_dist15$SmoothedProportion,7), scientific=F)
casted = dcast(smoothed_dist15, Item ~ State, value.var="SmoothedProportion")
write.table(casted,file="data/smoothed_15marbles_priors_withnames_laplace.txt",row.names=F,quote=F,sep="\t")
write.table(casted,file="../../../models/wonky_world/smoothed_15marbles_priors_withnames_laplace.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,2:length(colnames(casted))],file="data/smoothed_15marbles_priors_laplace.txt",row.names=F,quote=F,sep="\t")
#write.table(casted[,1:2],file="data/items.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,2:length(colnames(casted))],file="../../../models/wonky_world/smoothed_15marbles_priors_laplace.txt",row.names=F,quote=F,sep="\t")

## plot individual items
row.names(expectations) = expectations$Item
r$ExpectationLaplace = expectations[as.character(r$Item),]$expectation
ggplot(r, aes(x=response)) +
  geom_histogram() +
  geom_vline(aes(xintercept=ExpectationLaplace),color="red",size=1) +
  facet_wrap(~Item)
ggsave(file="graphs/item_variability_laplace.pdf",width=20,height=15)




