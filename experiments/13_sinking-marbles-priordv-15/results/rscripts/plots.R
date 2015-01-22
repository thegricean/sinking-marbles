theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/")
#setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/5_sinking-marbles-nullutterance-priordv/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
r$PriorExpectationProportion = r$PriorExpectation/15
save(r, file="data/r.RData")

# historgram of by-participant responses
p=ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_grid(workerid~quantifier)
ggsave("graphs/by-subject-variation.pdf",width=10,height=45)

# histogram of trial types
ggplot(r,aes(x=Item,fill=quantifier)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)


#COGSCI PLOT
agr = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh

min(agr[agr$quantifier == "Some",]$ProportionResponse)
max(agr[agr$quantifier == "Some",]$ProportionResponse)

ggplot(agr, aes(x=PriorExpectationProportion, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_color_manual(values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")) +
  scale_y_continuous(breaks=seq(0,1,0.1),name="Posterior mean proportion of objects") +
#  geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(breaks=seq(0,1,0.1),name="Prior mean proportion of  objects")  
ggsave(file="graphs/mean_responses.pdf",width=6.5,height=5)
ggsave(file="~/cogsci/conferences_talks/_2015/2_cogsci_pasadena/wonky_marbles/paper/pics/meanresponses.pdf",width=6.5,height=5)


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

agr = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item + LiteralAll,data=r,FUN=mean)
# agr$CILow = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item + LiteralAll,data=r, FUN=ci.low)$ProportionResponse
# agr$CIHigh = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item + LiteralAll,data=r,FUN=ci.high)$ProportionResponse
# agr$YMin = agr$ProportionResponse - agr$CILow
# agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=PriorExpectationProportion, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_y_continuous(breaks=seq(0,1,0.1),limits=c(0,1)) +
  facet_wrap(~LiteralAll)
ggsave(file="graphs/mean_responses_litall.pdf",width=12,height=8)



agr = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item + LiteralNone,data=r,FUN=mean)
#agr$CILow = aggregate(ProportionResponse ~ Prior + quantifier + Item + LiteralNone,data=r, FUN=ci.low)$ProportionResponse
#agr$CIHigh = aggregate(ProportionResponse ~ Prior + quantifier + Item + LiteralNone,data=r,FUN=ci.high)$ProportionResponse
#agr$YMin = agr$ProportionResponse - agr$CILow
#agr$YMax = agr$ProportionResponse + agr$CIHigh

ggplot(agr, aes(x=PriorExpectationProportion, y=ProportionResponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_y_continuous(breaks=seq(0,1,0.1),limits=c(0,1)) +
  facet_wrap(~LiteralNone)
ggsave(file="graphs/mean_responses_litnone.pdf",width=12,height=8)

