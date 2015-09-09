setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/_journal_cognition")

priors = data.frame(State = rep(seq(0,4),2),Prior = rep(c("left-peaked","right-peaked"),each=5),Probability=c(.96,.01,.01,.01,.01,.01,.01,.01,.01,.96))

ggplot(priors, aes(x=State,y=Probability,color=Prior,group=Prior)) +
  geom_point(size=3,alpha=.6) +
  geom_line(size=3,alpha=.6)
ggsave("pics/hypothetical-priors.png",width=7,height=4)


utts = data.frame(Utterance=factor(x=rep(c("none","some","all"),2),levels=c("none","some","all")),Prior=rep(c("left-peaked","right-peaked"),each=3),Probability=c(.8,.2,.007,.01,.48,.51))

ggplot(utts, aes(x=Utterance,y=Probability,color=Prior,group=Prior)) +
  geom_point(size=3,alpha=.6) +
  geom_line(size=3,alpha=.6)
ggsave("pics/utterance-probabilities.png",width=7,height=4)
