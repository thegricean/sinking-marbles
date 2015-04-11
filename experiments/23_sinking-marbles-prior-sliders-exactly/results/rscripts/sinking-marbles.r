library(ggplot2)
library(plyr)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/23_sinking-marbles-prior-sliders-exactly/results/")
source("rscripts/helpers.r")

load("data/r.RData")

# write dataset for mh's bayesian prior in the sky inference
# subjID, itemID, bin0, bin2, …, bin15
d = r[,c("workerid","Item","slider_id","normresponse")]
spreaded = d %>% spread(slider_id,normresponse)
write.table(spreaded,file="data/inferpriorinsky_binnedhistogram.txt",row.names=F,quote=F,sep="\t")

load("../../1_sinking-marbles-prior/results/data/priors.RData")
r = read.csv("data/sinking_marbles.csv", header=T)
nrow(r)
head(r)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("assignmentid","workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender", "response", "object","slider_id","num_objects","trial","enjoyment","asses","comments","Answer.time_in_minutes","slider_id","order")]
r$Item = as.factor(paste(r$effect,r$object))
table(r$Item)
table(r$Item,r$order)

## add old priors to data.frame
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
head(mpriorprobs)
row.names(mpriorprobs)= paste(mpriorprobs$variable, mpriorprobs$effect,mpriorprobs$object)
head(mpriorprobs)

r$PriorProbability = mpriorprobs[paste(paste("X",r$slider_id,sep=""),as.character(r$Item), sep=" "),]$value

# compute normalized probabilities
nr = ddply(r, c("workerid","trial"), summarise, 
           sumresponse=sum(response))
row.names(nr) = paste(nr$workerid, nr$trial)

r$normresponse = r$response/nr[paste(r$workerid, r$trial),]$sumresponse

# test: sums should add to 1
sums = ddply(r, .(workerid,trial), summarise, sum(normresponse))
colnames(sums) = c("workerid","trial","sum")
summary(sums)
sums[is.na(sums$sum),]

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

ggplot(aes(x=age,y=Answer.time_in_minutes,color=gender.1), data=unique(r[,c("assignmentid","age","Answer.time_in_minutes","gender.1")])) +
  geom_point() +
  geom_smooth()

unique(r$comments)

## write to file for use in models
head(r)
towrite = r[,c("Item","workerid","normresponse","slider_id")] %>% spread(slider_id, normresponse)
head(towrite)
str(towrite)
towrite$Item = as.factor(gsub(" ","_", towrite$Item))
towrite[,3:18] = towrite[,3:18] + .000000001
towrite = na.omit(towrite)

for (item in levels(towrite$Item)) {
  write.table(towrite[towrite$Item == item,3:18], file=paste("data/priors/",item,".txt",sep=""),quote=F,row.names=F,col.names=F)
}

# histogram of number of cases for each item
ggplot(as.data.frame(table(towrite$Item)),aes(x=Freq)) +
  geom_histogram()
ggsave("graphs/histogram_cases_per_item.pdf")
