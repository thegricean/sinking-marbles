theme_set(theme_bw(18))
#setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance-priordv/results/")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/9_sinking-marbles-nullutterance-priordv-100/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
load("data/r.RData") # the dataset

# historgram of by-participant responses
ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_grid(quantifier~workerid)
ggsave("graphs/by-subject-variation.pdf",width=40,height=10)

ggplot(subset(r, quantifier == "Some"), aes(x=response)) +
  geom_histogram() +
#  geom_text(aes(label=Prior),y=2) +  
  facet_wrap(~workerid)
ggsave("graphs/by-subject-variation-some.pdf",width=30,height=30)

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

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_smooth() +
  scale_y_continuous(breaks=seq(0,1.2,0.1))
ggsave(file="graphs/mean_responses_errbars.pdf",width=12,height=8)

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
r$Literal = r$LiteralAll & r$LiteralNone

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


agr = aggregate(ProportionResponse ~ Prior + quantifier + Combination + Literal,data=r,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Combination + Literal,data=r, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Combination + Literal,data=r,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1),limits=c(0,1)) +
  facet_wrap(~Literal)
ggsave(file="graphs/mean_responses_litornot.pdf",width=12,height=8)

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point(size=4) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1)) + #,limits=c(0,1)) +
  facet_wrap(~Literal)
ggsave(file="graphs/mean_responses_litornot_errbars.pdf",width=16,height=8)

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point(size=4) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1)) + #,limits=c(0,1)) +
  facet_grid(quantifier~Literal)
ggsave(file="graphs/mean_responses_litornot_errbars_facet.pdf",width=12,height=20)

ggplot(subset(agr, Literal == T), aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point(size=4) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1)) + #,limits=c(0,1)) +
  geom_text(aes(label=Combination),color="black") +
  facet_wrap(~quantifier)
ggsave(file="graphs/mean_responses_litornot_errbars_facet_labeled.pdf",width=40,height=30)


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
cor(agr$PExpectation,agr$ProportionResponse) # .28

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
cor(agr$PExpectation5,agr$ProportionResponse) # .45


## eye-balling the individual subjects variation data (by-subject-variation-some.pdf) 
# suggests that some people just choose one or two values for "some" and stick to it. what
# if you exlucde those/plot means by whether or not they're strategizing?

strategists = c(0, 1, 2, 14, 27, 33, 38, 17, 19, 21, 40, 41, 42, 54, 57, 61, 67, 73, 78, 84, 92, 93, 109) # 17, 19, 21 on the border 
r$Strategist = as.factor(ifelse(r$workerid %in% strategists, 1, 0))
summary(r$Strategist)

agr = aggregate(ProportionResponse ~ Prior + quantifier + Combination + Strategist,data=r,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Combination + Strategist,data=r, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Combination + Strategist,data=r,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  scale_y_continuous(breaks=seq(0,1,0.1)) +
  facet_wrap(~Strategist)
ggsave(file="graphs/mean_responses_bystrategy.pdf",width=12,height=8)

ggplot(agr, aes(x=Prior, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_smooth(method="lm") +
  scale_y_continuous(breaks=seq(0,1,0.1)) +
  facet_grid(quantifier~Strategist)
ggsave(file="graphs/mean_responses_bystrategy_errbar.pdf",width=12,height=20)
