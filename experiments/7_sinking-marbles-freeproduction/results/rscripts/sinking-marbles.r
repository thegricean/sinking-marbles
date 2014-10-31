library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/7_sinking-marbles-freeproduction/results/")
source("rscripts/helpers.r")
load("data/priors.RData")
load("data/r.RData")
r = read.table("data/sinking_marbles_freeproduction.tsv",quote="", sep="\t", header=T)
nrow(r)
names(r)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("assignmentid","workerid", "rt", "effect", "language","gender.1","age","gender","other_gender", "object_level", "object","num_objects","trial","enjoyment","asses","comments","Answer.time_in_minutes","num_objects_affected","actual_utterance")]
row.names(priors) = paste(priors$effect, priors$object)
r$Prior = priors[paste(r$effect, r$object),]$response
r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
r$Quantifier = r$slider_id
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Combination = as.factor(paste(r$cause,r$object,r$effect))
table(r$Combination)
utterances = as.data.frame(table(r$actual_utterance))
utterances[utterances$Freq > 1,]

r$Proportion = r$num_objects_affected/r$num_objects
paste(r[order(r[,c("actual_utterance","Proportion")]),]$actual_utterance,r[order(r[,c("actual_utterance","Proportion")]),]$Proportion)
r$ProportionBin = ifelse(r$Proportion == 0, 0, ifelse(r$Proportion == 1, 4, ifelse(r$Proportion < .51, 1, 2)))
r$PriorBin = ifelse(r$Prior < 26, 1, ifelse(r$Prior < 51, 2, ifelse(r$Prior < 76, 3, 4)))
table(r$ProportionBin, r$PriorBin)

r$actual_utterance = as.factor(tolower(r$actual_utterance))
r$actual_utterance = gsub("10","ten",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("11","eleven",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("12","twelve",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("13","thirteen",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("14","fourteen",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("15","fifteen",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("0","zero",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("1","one",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("2","two",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("3","three",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("4","four",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("5","five",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("6","six",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("7","seven",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("8","eight",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = gsub("9","nine",as.character(r$actual_utterance),fixed=T)
r$actual_utterance = as.factor(r$actual_utterance)
length(levels(r$actual_utterance))
unique(r$actual_utterance)

save(r, file="data/r.RData")

# EXAMPLES
# how many cases use the "of the" frame? 1057 of 1800, or 59%
length(grep("of the", as.character(r$actual_utterance),fixed=T))
nrow(r)

# SOME EXAMPLES
# Expectation for "all": Proportion == 1
# Prior > .9
all = subset(r, Proportion == 1 & Prior > 90)
nrow(all) # 53
all = droplevels(all)
levels(all$actual_utterance)
length(grep("(all|All)", as.character(all$actual_utterance))) # 42 of 53 cases have "all" in them (79%)
length(grep("(some|Some)", as.character(all$actual_utterance))) # 1 case has "some" in it, and it's not the use we're interested in
length(grep("(most|Most)", as.character(all$actual_utterance))) # 0 cases have "most"

# Prior > .5 & <= .9
all = subset(r, Proportion == 1 & Prior > 50 & Prior < 91)
nrow(all) # 122
all = droplevels(all)
levels(all$actual_utterance)
length(grep("(all|All)", as.character(all$actual_utterance))) # 96 of 122 cases have "all" in them (79%)
length(grep("(some|Some)", as.character(all$actual_utterance))) # 1 case has "some" in it, and it's not the use we're interested in
length(grep("(most|Most)", as.character(all$actual_utterance))) # 0 cases have "most"

# Prior > .0 & <= .5
all = subset(r, Proportion == 1 & Prior < 51)
nrow(all) # 60
all = droplevels(all)
levels(all$actual_utterance)
length(grep("(all|All)", as.character(all$actual_utterance))) # 45 of 60 cases have "all" in them (75%)
length(grep("(some|Some)", as.character(all$actual_utterance))) # 0 cases has "some" in it, and it's not the use we're interested in
length(grep("(most|Most)", as.character(all$actual_utterance))) # 0 cases have "most"

# Expectation for "most": Proportion > .5 & < 1
# Prior > .9
most = subset(r, Proportion > .5 & Proportion < 1 & Prior > 90)
nrow(most) # 148
most = droplevels(most)
levels(most$actual_utterance)
length(grep("(most|most)", as.character(most$actual_utterance))) # 18 of 148 cases have "most" in them (12%)
length(grep("(some|Some)", as.character(most$actual_utterance))) # 21 of 148  cases have "some" in them (14%)

# Prior > .5 & <= .9
most = subset(r, Proportion > .5 & Proportion < 1 & Prior > 50 & Prior < 91)
nrow(most) # 372
most = droplevels(most)
levels(most$actual_utterance)
length(grep("(most|most)", as.character(most$actual_utterance))) # 43 of 372 cases have "most" in them (12%)
length(grep("(some|Some)", as.character(most$actual_utterance))) # 29 of 372 cases have "most" in them (8%)

# Prior > .0 & <= .5
most = subset(r, Proportion > .5 & Proportion < 1 & Prior < 51)
nrow(most) # 151
most = droplevels(most)
levels(most$actual_utterance)
length(grep("(most|most)", as.character(most$actual_utterance))) # 21 of 151 cases have "most" in them (14%)
length(grep("(some|Some)", as.character(most$actual_utterance))) # 11 of 151 cases have "most" in them (7%)



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
