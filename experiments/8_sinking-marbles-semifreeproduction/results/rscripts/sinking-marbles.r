library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/8_sinking-marbles-semifreeproduction/results/")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/8_sinking-marbles-semifreeproduction/results/")
source("rscripts/helpers.r")
load("data/priors.RData")
load("data/r.RData")
r = read.table("data/sinking_marbles_freeproduction.tsv", sep="\t", header=T,quote="")
nrow(r)
names(r)

trim <- function (x) gsub("^\\s+|\\s+$", "", x) # trim leading and trailing whitespace


r$trial = r$slide_number_in_experiment - 3
r = r[,c("assignmentid","workerid", "rt", "effect", "language","gender.1","age","gender","other_gender", "object_level", "object","num_objects","trial","enjoyment","asses","comments","Answer.time_in_minutes","num_objects_affected","word1","word2")]
row.names(priors) = paste(priors$effect, priors$object)
r$Prior = priors[paste(r$effect, r$object),]$response
r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Combination = as.factor(paste(r$cause,r$object,r$effect))
r$word1 = as.factor(tolower(as.character(r$word1)))
r$word2 = as.factor(tolower(as.character(r$word2)))
r = droplevels(r)
summary(r)

r$Proportion = r$num_objects_affected/r$num_objects
r$ProportionBin = ifelse(r$Proportion == 0, 0, ifelse(r$Proportion == 1, 4, ifelse(r$Proportion < .51, 1, 2)))
r$PriorBin = ifelse(r$Prior < 26, 1, ifelse(r$Prior < 51, 2, ifelse(r$Prior < 76, 3, 4)))
table(r$ProportionBin, r$PriorBin)
r$word1 = as.character(r$word1)
r$word2 = as.character(r$word2)
melted = melt(r, measure.vars=c("word1","word2"))
melted$value = as.factor(as.character(melted$value))
melted$WordOrder = melted$variable
melted$Quantifier = melted$value
r = melted
r$Quantifier = as.factor(trim(as.character(r$Quantifier)))

# replace all the numbers with number words
r$Quantifier = gsub("10","ten",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("11","eleven",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("12","twelve",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("13","thirteen",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("14","fourteen",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("15","fifteen",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("0","zero",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("1","one",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("2","two",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("3","three",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("4","four",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("5","five",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("6","six",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("7","seven",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("8","eight",as.character(r$Quantifier),fixed=T)
r$Quantifier = gsub("9","nine",as.character(r$Quantifier),fixed=T)
r$Quantifier = as.factor(r$Quantifier)


summary(r)
length(levels(r$Quantifier)) # 266 different expressions
quants = as.data.frame(table(r$Quantifier))
quants = quants[order(quants[,c("Freq")],decreasing=T),]
sum(quants$Freq)
quants
ggplot(quants,aes(x=Freq)) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,10))
quants = quants[quants$Freq > 10,]
nrow(quants)
row.names(quants) = quants$Var1
rred = subset(r, Quantifier %in% row.names(quants))
nrow(rred)
rred = droplevels(rred)
r$redQuantifier = as.character(r$Quantifier)
r[! r$Quantifier %in% levels(rred$Quantifier),]$redQuantifier = "other"
# all quantifiers that occurred fewer than 10 times got "other" label
r$redQuantifier = as.factor(as.character(r$redQuantifier))
length(levels(r$redQuantifier))
save(rred, file="data/rred.RData")
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

t = as.data.frame(table(r$redQuantifier))
head(t[order(t[,c("Freq")],decreasing=T),],30)
