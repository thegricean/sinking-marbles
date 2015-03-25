library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/19_speaker_reliability_withins/results/")
source("rscripts/helpers.r")
load("data/r.RData")
r1 = read.csv("data/sinking_marbles1.csv")
r1$workerid = as.numeric(r1$workerid) + 60
r2 = read.csv("data/sinking_marbles2.csv")
r = rbind(r1,r2)
nrow(r)
head(r)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "response", "object","slider_id","num_objects","slide_number_in_experiment","enjoyment","asses","comments","Answer.time_in_minutes","trial_type","block")]
r$Item = as.factor(paste(r$effect,r$object))
table(r$Item)
r$Trial = r$slide_number_in_experiment - 3
table(r$Trial)
r[r$Trial > 16,]$Trial = r[r$Trial > 16,]$Trial - 1
r[r$Trial > 30,]$Trial = r[r$Trial > 30,]$Trial - 1
r$slider_id = gsub("[123]","",r$slider_id,perl=T)
table(r$slider_id)

table(r$trial_type,r$block)

r$Proportion = factor(ifelse(r$slider_id == "all","100",ifelse(r$slider_id == "lower_half","1-50",ifelse(r$slider_id == "upper_half","51-99","0"))),levels=c("0","1-50","51-99","100"))

## add priors to data.frame
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
r$PriorExpectation = priorexpectations[as.character(r$Item),]$expectation
r$PriorExpectationProportion = r$PriorExpectation/15

priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$effect,mpriorprobs$object,mpriorprobs$variable)
mpriorprobs$Proportion = factor(ifelse(mpriorprobs$variable == "X15","100",ifelse(mpriorprobs$variable == "X0","0",ifelse(mpriorprobs$variable %in% c("X1","X2","X3","X4","X5","X6","X7"),"1-50","51-99"))),levels=c("0","1-50","51-99","100"))
summary(mpriorprobs)
dppbs = ddply(mpriorprobs, .(effect,object,Proportion), summarise, Probability=sum(value))
row.names(dppbs) = paste(dppbs$effect,dppbs$object,dppbs$Proportion)
head(dppbs)
#test: all sums should be 1
ddply(dppbs, .(effect,object), summarise, S=sum(Probability))

r$PriorProbability = dppbs[paste(as.character(r$Item),as.character(r$Proportion),sep=" "),]$Probability
r$AllPriorProbability = priorprobs[paste(as.character(r$Item)),]$X15
head(r,15)


# compute normalized probabilities
r$response = as.numeric(as.character(r$response))
nr = ddply(r, .(workerid,Trial), summarise, normresponse=response/(sum(response)),workerid=workerid,Proportion=Proportion)
row.names(nr) = paste(nr$workerid,nr$Trial,nr$Proportion)
r$normresponse = nr[paste(r$workerid,r$Trial,r$Proportion),]$normresponse
# test: sums should add to 1
sums = ddply(r, .(workerid,Trial), summarise, sum(normresponse))
colnames(sums) = c("workerid","trial","sum")
summary(sums)

agr = aggregate(normresponse~workerid+quantifier+Proportion+trial_type, data=r, FUN=mean)
nrow(agr)
ggplot(agr, aes(x=Proportion,y=normresponse,fill=trial_type)) +
  geom_bar(stat="identity",position="dodge") +
  facet_grid(workerid~quantifier)
ggsave(file="graphs/subject_variability_bytrialtype.pdf",height=40,width=8)

agr = aggregate(normresponse~workerid+quantifier+Proportion, data=r, FUN=mean)
nrow(agr)
ggplot(agr, aes(x=Proportion,y=normresponse)) +
  geom_bar(stat="identity") +
  facet_grid(workerid~quantifier)
ggsave(file="graphs/subject_variability.pdf",height=40,width=5)

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

ggplot(aes(x=quantifier), data=r) +
  geom_histogram()

ggplot(aes(x=Answer.time_in_minutes), data=r) +
  geom_histogram()

ggplot(aes(x=Answer.time_in_minutes,y=as.numeric(as.character(enjoyment))),data=r) +
  geom_point() +
  geom_smooth()

ggplot(aes(x=age,y=Answer.time_in_minutes,color=gender.1), data=unique(r[,c("workerid","age","Answer.time_in_minutes","gender.1")])) +
  geom_point() +
  geom_smooth()

unique(r$comments)

uniqueanswertimes = unique(r[,c("workerid","Answer.time_in_minutes")])
nrow(uniqueanswertimes)
mean(uniqueanswertimes$Answer.time_in_minutes)
sd(uniqueanswertimes$Answer.time_in_minutes)

unique(r[r$workerid %in% c("1","15","39","45","52","61","63","72","90","93","97","104","117"),c("workerid","Answer.time_in_minutes","enjoyment","asses","age","comments")])
unique(r[(r$Answer.time_in_minutes < 8 | r$Answer.time_in_minutes > 23),c("workerid","Answer.time_in_minutes","enjoyment","asses","age","comments")])

excludeduniform = droplevels(subset(r, ! workerid %in% c("1","15","39","45","52","61","63","72","90","93","97","104","117")))
