theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/")
load("data/r.RData")
source("rscripts/helpers.r")

# histogram of by-participant responses
p=ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_grid(workerid~quantifier)
ggsave("graphs/by-subject-variation.pdf",width=10,height=45)

# histogram of trial types
ggplot(r,aes(x=Item,fill=quantifier)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)


agr = aggregate(response~quantifier+Item, data=r, FUN=mean)
agr$CILow = aggregate(response~quantifier+Item,data=r, FUN=ci.low)$response
agr$CIHigh = aggregate(response~quantifier+Item,data=r,FUN=ci.high)$response
agr$YMin = agr$response - agr$CILow
agr$YMax = agr$response + agr$CIHigh

ggplot(agr, aes(x=quantifier,y=response,)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~Item) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/wonky_probability_byitem.pdf",width=20,height=15)


agr = aggregate(response~quantifier+Item+PriorExpectationProportion, data=r, FUN=mean)
agr$CILow = aggregate(response~quantifier+Item+PriorExpectationProportion,data=r, FUN=ci.low)$response
agr$CIHigh = aggregate(response~quantifier+Item+PriorExpectationProportion,data=r,FUN=ci.high)$response
agr$YMin = agr$response - agr$CILow
agr$YMax = agr$response + agr$CIHigh

ggplot(agr, aes(x=PriorExpectationProportion,y=response,)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~quantifier) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/wonky_probability_bypriorexp_errbars.pdf",width=20,height=15)

ggplot(agr, aes(x=PriorExpectationProportion,y=response,)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~quantifier) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/wonky_probability_bypriorexp_errbars.pdf",width=20,height=15)


# COGSCI PLOT
ans = droplevels(subset(agr, quantifier %in% c("All","Some","None")))
ggplot(ans, aes(x=PriorExpectationProportion,y=response,group=quantifier,color=quantifier)) +
  geom_point() +
#  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  scale_color_manual(values=c("#F8766D", "#00BF7D", "#00B0F6")) +
  geom_smooth()+#method="lm",formula = y~x + I(x^2)) +
  scale_x_continuous(breaks=seq(0,1,.2), name="Prior mean proportion of objects") +
  scale_y_continuous(breaks=seq(0,1,.2), name="Mean wonkiness probability")  
ggsave(file="../../../writing/_2015/cogsci_2015/paper/pics/probwonky-empirical.pdf",width=5,height=3.7)
ggsave(file="graphs/probwonky-empirical.pdf",width=5,height=3.7)

ggplot(ans, aes(x=PriorExpectationProportion,y=response,group=quantifier,color=quantifier)) +
  geom_point() +
  scale_color_manual(values=c("#F8766D", "#00BF7D", "#00B0F6")) +
  geom_smooth() +
  scale_x_continuous(breaks=seq(0,1,.2), name="Prior mean proportion of objects") +
  scale_y_continuous(breaks=seq(0,1,.2), name="Mean wonkiness probability")  
ggsave(file="graphs/probwonky-empirical-freesmooth.pdf",width=6.5,height=5.2)

ggplot(agr, aes(x=PriorExpectationProportion,y=response,group=1)) +
  geom_point() +
  geom_smooth() +
  geom_text(aes(label=Item)) +
  facet_wrap(~quantifier)
ggsave(file="graphs/wonky_probability_bypriorexp_annotated.pdf",width=30,height=20)



t = as.data.frame(prop.table(table(r$AllPrior,r$quantifier,r$response),mar=c(1,2)))
head(t)
colnames(t) = c("AllPrior","Quantifier","Response","Proportion")
t = subset(t, Response == "no")
t = droplevels(t)

ggplot(t, aes(x=as.numeric(as.character(AllPrior)),y=Proportion,group=1)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Quantifier)
ggsave(file="graphs/proportion_wonky_byallprior.pdf",width=11,height=7)
