theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance-priordv/results/")
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

