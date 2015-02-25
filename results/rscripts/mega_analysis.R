setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/results/")

# create data.frame d with one item per row and columns of empirical, model prediction, and prior values

# load prior dataset (with 100 objects)
r = read.table("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/1_sinking-marbles-prior/results/data/sinking-marbles-prior.tsv", sep="\t", header=T)

#' initialize megaframe
d = data.frame(Item = factor(unique(paste(r$effect,r$object))))
row.names(d) = d$Item

#' get items and priors
r$Item = paste(r$effect,r$object)
r$AllState = as.factor(ifelse(r$response == 100,1,0))
t = as.data.frame(prop.table(table(r$AllState,r$Item),mar=2))
t = t[t$Var1 == 1,]
row.names(t) = t$Var2

#' add prior all-state probability to megaframe
d$prior_allprob_100 = t[as.character(d$Item),]$Freq
  
#' get unsmoothed prior expectation
t = as.data.frame(prop.table(table(r$response,r$Item),mar=2))
exps = ddply(t, .(Var2), summarise, expectation=sum(as.numeric(as.character(Var1))*Freq))  
row.names(exps) = exps$Var2

#' add prior expectation to megaframe
d$prior_expectation_unsmoothed_100 = exps[as.character(d$Item),]$expectation/100

plot(d$prior_allprob_100,d$prior_expectation_unsmoothed_100)
#' correlation between prior all probability and unsmoothed expectation 
cor(d$prior_allprob_100,d$prior_expectation_unsmoothed_100)

#' smooth prior with default binwidth and binwidth == 5

## CONTINUE HERE
expectations = ddply(r, .(effect,object), summarize, expectation=sum(density(response,n=101,from=0,to=100)$x*density(response,n=101,from=0,to=100)$y))

expectations5 = ddply(r, .(effect,object), summarize, expectation=sum(density(response,n=101,from=0,to=100,bw=5)$x*density(response,n=101,from=0,to=100,bw=5)$y))
mean(expectations$expectation)
median(expectations$expectation)
mean(expectations5$expectation)
median(expectations5$expectation)

ggplot(expectations, aes(x=expectation)) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,100))

ggplot(expectations5, aes(x=expectation)) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,100))

head(expectations)
nrow(priors)
nrow(expectations)
write.table(expectations,row.names=F,sep="\t",quote=F,file="data/expectations.txt")
write.table(expectations5,row.names=F,sep="\t",quote=F,file="data/expectations5.txt")


# get smoothed priors for model, separately for 15 and 100 objects
smoothed_dist100 = ddply(r, .(effect,object), summarize, State = density(response,n=101,from=0,to=100)$x,SmoothedProportion = density(response,n=101,from=0,to=100)$y)
smoothed_dist100$SmoothedProportion = smoothed_dist100$SmoothedProportion + 0.000001
#smoothed_dist100$Proportion = round(smoothed_dist100$SmoothedProportion,5)
smoothed_dist15 = ddply(r, .(effect,object), summarize, State = density(response,n=16,from=0,to=100)$x,SmoothedProportion = density(response,n=16,from=0,to=100)$y)
#smoothed_dist15$Proportion = round(smoothed_dist15$SmoothedProportion,5)
smoothed_dist15$SmoothedProportion = smoothed_dist15$SmoothedProportion + 0.000001

smoothed_dist15_bw5 = ddply(r, .(effect,object), summarize, State = density(response,n=16,from=0,to=100,bw=5)$x,SmoothedProportion = density(response,n=16,from=0,to=100,bw=5)$y)
#smoothed_dist15$Proportion = round(smoothed_dist15$SmoothedProportion,5)
smoothed_dist15_bw5$SmoothedProportion = smoothed_dist15_bw5$SmoothedProportion + 0.000001

smoothed_dist15_bw5$ProportionForComputingExpectation = ddply(smoothed_dist15_bw5, .(effect,object), summarize, Proportion = SmoothedProportion/sum(SmoothedProportion))$Proportion

# for testing:

# plot(head(smoothed_dist15,16)$State,head(smoothed_dist15,16)$SmoothedProportion)
# plot(head(smoothed_dist15_bw5,16)$State,head(smoothed_dist15_bw5,16)$SmoothedProportion)
# plot(tail(smoothed_dist15,16)$State,tail(smoothed_dist15,16)$SmoothedProportion)
# plot(tail(smoothed_dist15_bw5,16)$State,tail(smoothed_dist15_bw5,16)$SmoothedProportion)
head(smoothed_dist100)
head(smoothed_dist15)
head(smoothed_dist15_bw5)
sum(smoothed_dist100[smoothed_dist100$object == "birds",]$SmoothedProportion)
sum(smoothed_dist15_bw5[smoothed_dist15_bw5$object == "birds",]$SmoothedProportion)
sum(smoothed_dist15_bw5[smoothed_dist15_bw5$object == "birds",]$ProportionForComputingExpectation)

plot(seq(0,100,by=1),smoothed_dist100[smoothed_dist100$object == "birds",]$SmoothedProportion)
plot(seq(0,15,by=1),smoothed_dist15_bw5[smoothed_dist15_bw5$object == "birds",]$SmoothedProportion)
plot(seq(0,15,by=1),smoothed_dist15_bw5[smoothed_dist15_bw5$object == "birds",]$ProportionForComputingExpectation)

library(reshape2)
casted = dcast(smoothed_dist15_bw5, effect + object ~ State, value.var="ProportionForComputingExpectation")
write.table(casted,file="data/smoothed_15marbles_priors_withnames.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,3:length(colnames(casted))],file="data/smoothed_15marbles_priors.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,1:2],file="data/items.txt",row.names=F,quote=F,sep="\t")


# compute prior dist expectations
expectations = ddply(smoothed_dist15_bw5, .(effect,object), summarize, expectation=sum(State*ProportionForComputingExpectation)/sum(ProportionForComputingExpectation))
head(expectations)
write.table(expectations,row.names=F,sep="\t",quote=F,file="data/expectations_15_bw5_prior.txt")
