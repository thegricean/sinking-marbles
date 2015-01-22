theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/11_sinking-marbles-normal/results/")
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

# COGSCI PLOT
ans = droplevels(subset(t, Quantifier %in% c("All","Some","None")))
ans$PriorExpectation = as.numeric(as.character(ans$PriorExpectation))/15
ggplot(ans, aes(x=as.numeric(as.character(PriorExpectation)),y=Proportion,group=Quantifier,color=Quantifier)) +
  geom_point() +
  scale_color_manual(values=c("#F8766D", "#00BF7D", "#00B0F6")) +
  geom_smooth(method="lm",formula = y~x + I(x^2)) +
  scale_x_continuous(breaks=seq(0,1,.2), name="Prior mean proportion of objects") +
  scale_y_continuous(breaks=seq(0,1,.2), name="Proportion of 'wonky' ratings")  
ggsave(file="~/cogsci/conferences_talks/_2015/2_cogsci_pasadena/wonky_marbles/paper/pics/proportionwonky-empirical.pdf",width=6.5,height=5.2)
ggsave(file="graphs/proportionwonky-empirical.pdf",width=6.5,height=5.2)




ggplot(t, aes(x=as.numeric(as.character(PriorExpectation)),y=Proportion,group=1)) +
  geom_point() +
  geom_smooth() +
  geom_text(aes(label=Item)) +
  facet_wrap(~Quantifier)
ggsave(file="graphs/proportion_wonky_bypriorexp_annotated.pdf",width=30,height=20)



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
