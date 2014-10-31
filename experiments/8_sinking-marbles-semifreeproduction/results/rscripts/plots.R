theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/8_sinking-marbles-semifreeproduction/results/")
source("rscripts/helpers.r")
load("data/r.RData") # the full dataset
load("data/rred.RData") # the reduced dataset

summary(r)
nrow(r)
summary(rred)
nrow(rred)

ggplot(r, aes(x=ProportionBin,fill=Quantifier)) +
  geom_histogram() +
  facet_wrap(~PriorBin, scales="free_y")

summary(rred)
t = as.data.frame(table(rred$Quantifier, rred$ProportionBin, rred$PriorBin))
head(t)
colnames(t) = c("Quantifier","ProportionBin","PriorBin","Freq")
summary(t)

t = as.data.frame(table(r$redQuantifier, r$ProportionBin, r$PriorBin))
head(t)
colnames(t) = c("Quantifier","ProportionBin","PriorBin","Freq")
summary(t)

byproportion = ddply(t, .(Quantifier,PriorBin), summarise, Quantifier=Quantifier,PriorBin=PriorBin,ProportionBin=ProportionBin,ProportionResponse=Freq/sum(Freq),Freq=Freq)

byprior = ddply(t, .(Quantifier,ProportionBin), summarise, Quantifier=Quantifier,PriorBin=PriorBin,ProportionBin=ProportionBin,ProportionResponse=Freq/sum(Freq),Freq=Freq)

byquantifier = ddply(t, .(PriorBin,ProportionBin), summarise, Quantifier=Quantifier,PriorBin=PriorBin,ProportionBin=ProportionBin,ProportionResponse=Freq/sum(Freq),Freq=Freq)

ggplot(byprior, aes(x=PriorBin,y=ProportionResponse,fill=ProportionBin)) +
  geom_bar(stat="identity",position="dodge") +
  scale_x_discrete(name="Prior",breaks=c(1,2,3,4),labels=c("0-.25",".26-.5",".51-.75",".76-1")) + 
  scale_fill_discrete(name="Proportion",breaks=c(0,1,2,4),labels=c("0",".01-.5",".51-.99","1")) +  
  facet_wrap(~Quantifier)
ggsave(file="graphs/byprior.pdf",height=12,width=18)

ggplot(byquantifier, aes(x=Quantifier,y=ProportionResponse,fill=PriorBin)) +
  geom_bar(stat="identity",position="dodge") +
  #scale_x_discrete(name="Prior",breaks=c(1,2,3,4),labels=c("0-.25",".26-.5",".51-.75",".76-1")) + 
  scale_fill_discrete(name="Prior",breaks=c(1,2,3,4),labels=c("0-.25",".26-.5",".51-.75",".76-1")) +  
  facet_wrap(~ProportionBin,scales="free",nrow=4) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/byquantifier.pdf",height=16,width=10)

ggplot(rred, aes(x=PriorBin,fill=as.factor(ProportionBin))) +
  geom_bar(aes(y=(..count..)/sum(..count..)),position="dodge",binwidth=.5) +
  scale_x_continuous(name="Prior",breaks=c(1,2,3,4),labels=c("0-.25",".26-.5",".51-.75",".76-1")) +
  scale_fill_discrete(name="Proportion",breaks=c(0,1,2,4),labels=c("0","1-50","51-99","100")) +
#  scale_y_continuous(labels=percent) +
  facet_wrap(~Quantifier) +#, scales="free_y") +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/rred.pdf",height=12,width=18)
