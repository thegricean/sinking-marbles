library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-production/results/")
source("rscripts/helpers.r")
load("data/priors.RData")
r = read.table("data/sinking_marbles_nullutterance-production.txt", sep="\t", header=T)
nrow(r)
names(r)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("assignmentid","workerid", "rt", "effect", "language","gender.1","age","gender","other_gender", "object_level", "response", "object","slider_id","num_objects","trial","enjoyment","asses","comments","Answer.time_in_minutes","num_objects_affected")]
row.names(priors) = paste(priors$effect, priors$object)
r$Prior = priors[paste(r$effect, r$object),]$response
r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
r$Quantifier = r$slider_id
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Combination = as.factor(paste(r$cause,r$object,r$effect))
table(r$Combination)

# compute normalized probabilities
nr = ddply(r, .(assignmentid,trial), summarize, normresponse=response/(sum(response)),assignmentid=assignmentid,Quantifier=Quantifier)
row.names(nr) = paste(nr$assignmentid,nr$trial,nr$Quantifier)
r$normresponse = nr[paste(r$assignmentid,r$trial,r$Quantifier),]$normresponse
# test: sums should add to 1
sums = ddply(r, .(assignmentid,trial), summarize, sum(normresponse))
colnames(sums) = c("assignmentid","trial","sum")
summary(sums)
sums[is.na(sums$sum),]

r$Proportion = r$num_objects_affected/r$num_objects
r$ProportionBin = 3
r[r$Proportion < 1,]$ProportionBin = cut(r[r$Proportion < 1,]$Proportion,breaks=quantile(r[r$Proportion < 1,]$Proportion, probs=seq(0,1,.5)))

save(r, file="data/r.RData")

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

ggplot(aes(x=Proportion), data=r) +
  geom_histogram()

ggplot(aes(x=age,y=Answer.time_in_minutes,color=gender.1), data=unique(r[,c("assignmentid","age","Answer.time_in_minutes","gender.1")])) +
  geom_point() +
  geom_smooth()

unique(r$comments)

table(r$num_objects_affected,r$num_objects)

########################################
# compute speaker probabilities for model
########################################
# first exclude all the trials on which there were no affected objects
atleastone = subset(r, Proportion > 0)
atleastone = droplevels(atleastone)
nrow(atleastone)
summary(atleastone)

# simplest model:
r$State = as.factor(ifelse(r$Proportion == 1, "all", "not-all"))
table(r$State)

probs = aggregate(normresponse ~ Quantifier + State, FUN=mean, data=r)
probs # probs for model
priors = unique(r$Prior)
sort(unique(round(priors/100,2))) # priors to run model with
length(sort(unique(round(priors/100,2))) ) # 52 unique priors









