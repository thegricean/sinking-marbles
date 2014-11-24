theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance-priordv/results/")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/5_sinking-marbles-nullutterance-priordv/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
load("data/r.RData") # the dataset

# historgram of by-participant responses
ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_grid(quantifier~workerid)
ggsave("graphs/by-subject-variation.pdf",width=100,height=10)

# histogram of trial types
ggplot(r,aes(x=Combination,fill=quantifier)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)

#
ggplot(r, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1))
ggsave(file="graphs/raw_responses.pdf",width=12,height=8)


agr = aggregate(ProportionResponse ~ Prior + quantifier + Combination,data=r,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Combination,data=r, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Combination,data=r,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1))
ggsave(file="graphs/mean_responses.pdf",width=12,height=8)

agr = aggregate(ProportionResponse ~ Prior + quantifier + num_objects + Combination,data=r,FUN=mean)
ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1),limits=c(0,1)) +
  facet_wrap(~num_objects)
ggsave(file="graphs/mean_responses_bynumobjects.pdf",width=12,height=8)

# code participants for whether they are literal "all" and "none" responders -> maybe the ones who aren't responding literally are also not using the scale properly?
all = aggregate(ProportionResponse~workerid, data=r[r$quantifier == "All",], FUN=mean)
nrow(all)
head(all)
sort(all$ProportionResponse)
row.names(all) = all$workerid

none = aggregate(ProportionResponse~workerid, data=r[r$quantifier == "None",], FUN=mean)
nrow(none)
head(none)
sort(none$ProportionResponse)
row.names(none) = none$workerid

r$LiteralAll = (all[as.character(r$workerid),]$ProportionResponse > .85)
r$LiteralNone = (none[as.character(r$workerid),]$ProportionResponse < .15)

agr = aggregate(ProportionResponse ~ Prior + quantifier + Combination + LiteralAll,data=r,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Combination + LiteralAll,data=r, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Combination + LiteralAll,data=r,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1),limits=c(0,1)) +
  facet_wrap(~LiteralAll)
ggsave(file="graphs/mean_responses_litall.pdf",width=12,height=8)



agr = aggregate(ProportionResponse ~ Prior + quantifier + Combination + LiteralNone,data=r,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Combination + LiteralNone,data=r, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Combination + LiteralNone,data=r,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1),limits=c(0,1)) +
  facet_wrap(~LiteralNone)
ggsave(file="graphs/mean_responses_litnone.pdf",width=12,height=8)

# response histograms by prior bin --> are there two populations?
ggplot(r, aes(x=ProportionResponse)) + #,fill=quantifier)) +
  geom_histogram() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1)) +
  facet_grid(quantifier~PriorBin,scales="free_y")
ggsave(file="graphs/priorslice_distributions.pdf",width=20,height=12)

ggplot(r, aes(x=ProportionResponse)) + #,fill=quantifier)) +
  geom_density() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1)) +
  facet_grid(quantifier~PriorBin,scales="free_y")
ggsave(file="graphs/priorslice_densities.pdf",width=20,height=12)

r$Combo = as.factor(paste(r$effect,r$object))
r$PExpectation = r$Expectation/100
some = subset(r, quantifier == "Some")
agr = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation,data=some,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation,data=some, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation,data=some,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=PExpectation,y=ProportionResponse)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin, ymax=YMax)) +
  geom_smooth() +
  scale_x_continuous(limits=c(0,1),name="Prior expectation") +
  scale_y_continuous(limits=c(0,1),name="Empirical mean") +  
  geom_abline(intercept=0,slope=1)


## plot expectations
r$Combo = as.factor(paste(r$effect,r$object))
r$PExpectation = r$Expectation/100
r$PExpectation5 = r$Expectation5/100
some = subset(r, quantifier == "Some")
agr = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation,data=some,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation,data=some, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation,data=some,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=PExpectation,y=ProportionResponse)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin, ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_x_continuous(limits=c(0,1)) +
  geom_abline(intercept=0,slope=1)
ggsave(file="graphs/expectation.pdf")
cor(agr$PExpectation,agr$ProportionResponse) # .35

agr = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation5,data=some,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation5,data=some, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Combo + PExpectation5,data=some,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=PExpectation5,y=ProportionResponse)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin, ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_x_continuous(limits=c(0,1)) +
  geom_abline(intercept=0,slope=1)
ggsave(file="graphs/expectation5.pdf")
cor(agr$PExpectation5,agr$ProportionResponse) # .38
