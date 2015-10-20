dist_mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}


library(np)
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/27_sinking-marbles-prior15_unusual/results/")

r = read.table("data/sinking_marbles.csv", sep=",", header=T)
nrow(r)
r$workerid = as.factor(as.character(r$workerid))
length(levels(r$workerid))
r$Item = as.factor(paste(r$effect,r$object))

unique(r$comments)

r = r %>% select(workerid,Item,response,response_unusual) %>%
  gather(responsetype,response,response:response_unusual)

# load original priors to make correlation scatterplots
priors_original = read.table("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_model_comparison/priors/data/priors.txt",sep=",",header=T)
length(levels(as.factor(priors_original$workerid)))
head(priors_original)

# original exps:
exps_original = priors_original %>%
  group_by(Item) %>%
  summarise(Expectation=mean(response))
exps_original = as.data.frame(exps_original)
row.names(exps_original) = exps_original$Item

# original allprobs:
t = as.data.frame(prop.table(table(priors_original$Item,priors_original$response),mar=c(1)))
colnames(t) = c("Item","State","Probability")
allprobs_original = droplevels(t[t$State == 15,])
row.names(allprobs_original) = allprobs_original$Item
nrow(allprobs_original)

# original modes:
modes_original = priors_original %>%
  group_by(Item) %>%
  summarise(Mode=dist_mode(response))
modes_original = as.data.frame(modes_original)
row.names(modes_original) = modes_original$Item

r$OriginalExpectation = exps_original[as.character(r$Item),]$Expectation
r$OriginalMode = modes_original[as.character(r$Item),]$Mode
r$OriginalAllprob = allprobs_original[as.character(r$Item),]$Probability

# load info on inferred priors based on original priors (measures of "bi-modality")
bimodality= read.csv("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_model_comparison/priors/results/bimodalityMAPs_priorBDA-mix2binomials-fullPosterior_incrMH75000burn37500.csv")
head(bimodality)
row.names(bimodality) = bimodality$Item

r$absMix = bimodality[as.character(r$Item),]$absMix
r$diffTheta = bimodality[as.character(r$Item),]$diffTheta
r$bimodality = bimodality[as.character(r$Item),]$bimodality

save(r, file="data/r.RData")

load("data/r.RData")

## plot subject variability
ggplot(r, aes(x=response,fill=responsetype)) +
  geom_histogram(position="dodge") +
  facet_wrap(~workerid)
ggsave(file="graphs/subject_variability.pdf",width=20,height=15)
table(r$workerid)

# how many judgments per item
min(table(r$Item))
max(table(r$Item))
t = as.data.frame(table(r$Item))
t[order(t[,c("Freq")]),]

exps = r %>% 
  group_by(Item,responsetype) %>%
  summarise(Expectation = mean(response))
exps = as.data.frame(exps)
exps = exps %>% spread(responsetype,Expectation)
row.names(exps) = exps$Item
r$Expectation = exps[as.character(r$Item),]$response
r$Expectation_unusual = exps[as.character(r$Item),]$response_unusual

## plot individual items
r$It = factor(x=as.character(r$Item),levels=unique(r[order(r[,c("Expectation")]),]$Item))

p=ggplot(r, aes(x=response,fill=responsetype,color=responsetype)) +
  geom_histogram(position="dodge") +
  scale_fill_manual(values=c("blue","red")) +
  scale_color_manual(values=c("blue","red")) +  
  geom_vline(aes(xintercept=Expectation),color="blue") +
  geom_vline(aes(xintercept=Expectation_unusual),color="red") +
  facet_wrap(~It)
ggsave(file="graphs/item_variability.pdf",width=20,height=15)

t = as.data.frame(prop.table(table(r$Item,r$responsetype,r$response),mar=c(1,2)))
colnames(t) = c("Item","responsetype","State","Proportion")
head(t)
t$Expectation = exps[as.character(t$Item),]$response
t$Expectation_unusual = exps[as.character(t$Item),]$response_unusual

## plot individual items
t$It = factor(x=as.character(t$Item),levels=unique(t[order(t[,c("Expectation")]),]$Item))

p=ggplot(t, aes(x=State,y=Proportion,fill=responsetype,color=responsetype)) +
  geom_bar(position="dodge",stat="identity") +
  scale_fill_manual(values=c("blue","red")) +
  scale_color_manual(values=c("blue","red")) +  
  geom_vline(aes(xintercept=Expectation),color="blue") +
  geom_vline(aes(xintercept=Expectation_unusual),color="red") +
  scale_y_continuous(limits=c(0,1)) +
  facet_wrap(~It)
ggsave(file="graphs/item_variability_dist.pdf",width=20,height=15)


r$Bin = as.factor(ifelse(r$response == 0, 0, ifelse(r$response < 8, 50, ifelse(r$response < 15, 99, 100))))
ggplot(r, aes(x=Bin,fill=responsetype)) +
  geom_histogram(position="dodge") +
  facet_wrap(~Item)
ggsave(file="graphs/item_variability_binned.pdf",width=20,height=15)

# scatterplot of original vs normal vs unusual expectations
head(r)
exps = r %>%
  group_by(Item, responsetype, OriginalExpectation,absMix,diffTheta,bimodality) %>%
  summarise(Expectation=mean(response))
exps = as.data.frame(exps)

ggplot(exps, aes(x=Expectation,y=OriginalExpectation,color=responsetype)) +
  geom_point() +
  geom_smooth() +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,15)) +  
  geom_abline(intercept=0,slope=1,color="gray50")
ggsave("graphs/correlation_with_original_priors.pdf")

cor(exps[exps$responsetype=="response",]$Expectation,exps[exps$responsetype=="response",]$OriginalExpectation) #.97
cor(exps[exps$responsetype=="response_unusual",]$Expectation,exps[exps$responsetype=="response_unusual",]$OriginalExpectation) #.87

# scatterplot of expectations vs three different measures of bimodality
ggplot(exps, aes(x=Expectation,y=absMix,color=responsetype)) +
  geom_point() +
  geom_smooth() +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,1))
ggsave("graphs/exp_by_absmix.pdf")

ggplot(exps, aes(x=Expectation,y=diffTheta,color=responsetype)) +
  geom_point() +
  geom_smooth() +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,1))
ggsave("graphs/exp_by_difftheta.pdf")

ggplot(exps, aes(x=Expectation,y=bimodality,color=responsetype)) +
  geom_point() +
  geom_smooth() +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,1))
ggsave("graphs/exp_by_bimodality.pdf")

# scatterplot of original vs normal vs unusual allprobs
head(r)
t = as.data.frame(prop.table(table(r$Item,r$response,r$responsetype),mar=c(1,3)))
colnames(t) = c("Item","State","ResponseType","AllProbability")
allprobs = droplevels(t[t$State == 15,])
allprobs$OriginalAllProbability = allprobs_original[as.character(allprobs$Item),]$Probability

ggplot(allprobs, aes(x=AllProbability,y=OriginalAllProbability,color=ResponseType)) +
  geom_point() +
  geom_smooth() +
  scale_x_continuous(limits=c(0,1),breaks=seq(0,1,.2)) +
  scale_y_continuous(limits=c(0,1),breaks=seq(0,1,.2)) +  
  geom_abline(intercept=0,slope=1,color="gray50")
ggsave("graphs/correlation_with_original_priors_allprobs.pdf")

cor(allprobs[allprobs$ResponseType=="response",]$AllProbability,allprobs[allprobs$ResponseType=="response",]$OriginalAllProbability) #.95
cor(allprobs[allprobs$ResponseType=="response_unusual",]$AllProbability,allprobs[allprobs$ResponseType=="response_unusual",]$OriginalAllProbability) #.81

# scatterplot of original vs normal vs unusual mode
modes = r %>%
  group_by(Item, responsetype, OriginalMode) %>%
  summarise(Mode=dist_mode(response))
modes = as.data.frame(modes)
modes$Cases = 

ggplot(modes, aes(x=Mode,y=OriginalMode,color=responsetype)) +
  geom_point() +
  geom_text(aes(label=Item)) +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,15)) +
  geom_abline(intercept=0,slope=1,color="gray50")
ggsave("graphs/correlation_with_original_priors_modes.pdf",height=10,width=13)

modes[modes$Mode > 10 & modes$OriginalMode < 5 & modes$responsetype == "response",]
modes[modes$Mode < 5 & modes$OriginalMode > 10 & modes$responsetype == "response",]
