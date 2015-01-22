theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/14_sinking-marbles-wonky/results/")
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


t = as.data.frame(prop.table(table(r$Item,r$quantifier,r$response),mar=c(1,2)))
t[t$Var1 == "backpacks blew away" & t$Var2 == "All",]
t[t$Var1 == "backpacks blew away" & t$Var2 == "Some",]
t[t$Var1 == "backpacks blew away" & t$Var2 == "None",]
head(t)
colnames(t) = c("Item","Quantifier","Response","Proportion")
t = subset(t, Response == "yes")
t = droplevels(t)

ggplot(t, aes(x=Quantifier,y=Proportion,)) +
  geom_bar(stat="identity") +
  facet_wrap(~Item) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/proportion_yes_byitem.pdf",width=20,height=15)


t = as.data.frame(prop.table(table(r$Item,r$PriorExpectation,r$quantifier,r$response),mar=c(1,2,3)))
head(t)
nrow(t)
t = subset(t, !is.na(Freq))
colnames(t) = c("Item","PriorExpectation","Quantifier","Response","Proportion")
t = subset(t, Response == "no")
t = droplevels(t)
t$PriorExp = as.factor(as.character(round(as.numeric(as.character(t$PriorExpectation)),5)))
str(t)

ggplot(t, aes(x=Quantifier,y=Proportion,)) +
  geom_bar(stat="identity") +
  facet_wrap(~PriorExp) +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/proportion_wonky_bypriorexp.pdf",width=20,height=15)

ggplot(t, aes(x=as.numeric(as.character(PriorExpectation)),y=Proportion,group=1)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Quantifier)
ggsave(file="graphs/proportion_wonky_bypriorexp.pdf",width=11,height=7)


ggplot(t, aes(x=as.numeric(as.character(PriorExpectation)),y=Proportion,group=1)) +
  geom_point() +
  geom_smooth() +
  geom_text(aes(label=Item)) +
  facet_wrap(~Quantifier)
ggsave(file="graphs/proportion_wonky_bypriorexp_annotated.pdf",width=30,height=20)
