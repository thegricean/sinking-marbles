theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
load("data/priors.RData")
load("data/r.RData")
nu = r
nu$Experiment = "null-utterance"

load("../../sinking-marbles/results/data/r.RData")
basic = r
basic$Experiment = "basic"

names(nu)
names(basic)

d = merge(basic,nu,all=T)
names(d)
head(d)

agrnu = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier, data = nu, FUN=mean)
agrnu$CIHigh = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier, data = nu, FUN=ci.high)$normresponse
agrnu$CILow = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier, data = nu, FUN=ci.low)$normresponse

agrbasic = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier, data = basic, FUN=mean)
agrbasic$CIHigh = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier, data = basic, FUN=ci.high)$normresponse
agrbasic$CILow = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier, data = basic, FUN=ci.low)$normresponse

row.names(agrbasic) = paste(agrbasic$object, agrbasic$effect, agrbasic$Proportion, agrbasic$quantifier)
agrnu$normresponseBasic = agrbasic[paste(agrnu$object, agrnu$effect, agrnu$Proportion,agrnu$quantifier),]$normresponse
agrnu$CIHighBasic = agrbasic[paste(agrnu$object, agrnu$effect, agrnu$Proportion,agrnu$quantifier),]$CIHigh
agrnu$CILowBasic = agrbasic[paste(agrnu$object, agrnu$effect, agrnu$Proportion,agrnu$quantifier),]$CILow

agrnu$YMin = agrnu$normresponse - agrnu$CILow
agrnu$YMax = agrnu$normresponse + agrnu$CIHigh
agrnu$YMinBasic = agrnu$normresponseBasic - agrnu$CILowBasic
agrnu$YMaxBasic = agrnu$normresponseBasic + agrnu$CIHighBasic

save(agrnu, file="data/agrnu.RData")

agrsome = subset(agrnu, ! agrnu$quantifier %in% c("short_filler","long_filler") & agrnu$quantifier == "Some" & Proportion == 100)
agrsome = droplevels(agrsome)
head(agrsome)
nrow(agrsome)

ggplot(agrsome, aes(x=normResponseBasic,y=normresponse, color=Prior)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,0.3)) +
  scale_x_continuous(limits=c(0,0.3))  
  #facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-vs-basic.pdf",height=4,width=5)

ggplot(agrsome, aes(x=normResponseBasic,y=normresponse, color=Prior)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,0.3)) +
  scale_x_continuous(limits=c(0,0.3)) +
  geom_text(aes(label=paste(object,effect)))
#facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-vs-basic-annotated.pdf",height=4,width=5)

ggplot(agrsome, aes(x=normresponseBasic,y=normresponse, color=Prior)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),alpha=.5) +
  geom_errorbarh(aes(xmin=YMinBasic,xmax=YMaxBasic),alpha=.5) +
  scale_y_continuous(limits=c(0,0.5)) +
  scale_x_continuous(limits=c(0,0.5))
#facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-vs-basic-errorbars.pdf",height=5,width=6)


#### "all" -- see if you can exclude the people who didn't even do the literal interpretation right

agrall = subset(agrnu, ! agrnu$quantifier %in% c("short_filler","long_filler") & agrnu$quantifier == "All" & Proportion == 100)
agrall = droplevels(agrall)

ggplot(agrall, aes(x=normresponseBasic,y=normresponse, color=Prior)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),alpha=.5) +
  geom_errorbarh(aes(xmin=YMinBasic,xmax=YMaxBasic),alpha=.5) +
ggsave("graphs/nullutterance-vs-basic-errorbars-allcontrol.pdf",height=5,width=6)

# plot by-subject variability
ggplot(nu[nu$quantifier == "All" & nu$Proportion == 100,],aes(x=normresponse)) +
  geom_histogram() +
  facet_wrap(~workerid)

ggsave(file="graphs/subject-variation-all.pdf",width=20,heigh=20)


# code participants for whether they are literal "all" and "none" responders -> maybe the ones who aren't responding literally are also not using the scale properly?
all = aggregate(normresponse~workerid, data=nu[nu$quantifier == "All" & nu$Proportion == 100,], FUN=mean)
nrow(all)
head(all)
sort(all$normresponse)
row.names(all) = all$workerid

none = aggregate(normresponse~workerid, data=nu[nu$quantifier == "None" & nu$Proportion == 0,], FUN=mean)
nrow(none)
head(none)
sort(none$normresponse)
row.names(none) = none$workerid


nu$LiteralAll = (all[as.character(nu$workerid),]$normresponse > .85)
nu$LiteralNone = (none[as.character(nu$workerid),]$normresponse > .85)

agnu = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier + LiteralAll, data = nu, FUN=mean)
agnu$CIHigh = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier  + LiteralAll, data = nu, FUN=ci.high)$normresponse
agnu$CILow = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier + LiteralAll, data = nu, FUN=ci.low)$normresponse
agnu$YMin = agnu$normresponse - agnu$CILow
agnu$YMax = agnu$normresponse + agnu$CIHigh

save(agnu, file="data/agnu.RData")

agsome = subset(agnu, ! agnu$quantifier %in% c("short_filler","long_filler") & agnu$quantifier == "Some" & Proportion == 100)
agsome = droplevels(agsome)
head(agsome)
nrow(agsome)

# plot responses by whether participant responded literally to "all"
ggplot(agsome, aes(x=Prior,y=normresponse)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,0.3)) +
  #scale_x_continuous(limits=c(0,0.3))  +
  facet_wrap(~LiteralAll)
#facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-litall.pdf",height=4,width=5)

ggplot(agsome, aes(x=Prior,y=normresponse)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,0.3)) +
  #scale_x_continuous(limits=c(0,0.3)) +
  geom_text(aes(label=paste(object,effect)))  +
  facet_wrap(~LiteralAll)
#facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-annotated-litall.pdf",height=20,width=24)

ggplot(agsome, aes(x=Prior,y=normresponse)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),alpha=.5) +
  #geom_errorbarh(aes(xmin=YMinBasic,xmax=YMaxBasic),alpha=.5) +
  scale_y_continuous(limits=c(0,0.5)) +
  #scale_x_continuous(limits=c(0,0.5))  +
  facet_wrap(~LiteralAll)
#facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-vs-basic-errorbars-litall.pdf",height=5,width=6)


agno = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier + LiteralNone, data = nu, FUN=mean)
agno$CIHigh = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier  + LiteralNone, data = nu, FUN=ci.high)$normresponse
agno$CILow = aggregate(normresponse ~ Prior + Proportion + object + effect + quantifier + LiteralNone, data = nu, FUN=ci.low)$normresponse
agno$YMin = agno$normresponse - agno$CILow
agno$YMax = agno$normresponse + agno$CIHigh

save(agno, file="data/agno.RData")

agsome = subset(agno, ! agno$quantifier %in% c("short_filler","long_filler") & agno$quantifier == "Some" & Proportion == 100)
agsome = droplevels(agsome)
head(agsome)
nrow(agsome)

# plot responses by whether participant responded literally to "none"
ggplot(agsome, aes(x=Prior,y=normresponse)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,0.3)) +
  #scale_x_continuous(limits=c(0,0.3))  +
  facet_wrap(~LiteralNone)
#facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-litnone.pdf",height=4,width=5)

ggplot(agsome, aes(x=Prior,y=normresponse)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,0.3)) +
  #scale_x_continuous(limits=c(0,0.3)) +
  geom_text(aes(label=paste(object,effect)))  +
  facet_wrap(~LiteralNone)
#facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-annotated-litnone.pdf",height=15,width=17)

ggplot(agsome, aes(x=Prior,y=normresponse)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),alpha=.5) +
  #geom_errorbarh(aes(xmin=YMinBasic,xmax=YMaxBasic),alpha=.5) +
  scale_y_continuous(limits=c(0,0.5)) +
  #scale_x_continuous(limits=c(0,0.5))  +
  facet_wrap(~LiteralNone)
#facet_wrap(~Proportion, scales="free")
ggsave("graphs/nullutterance-vs-basic-errorbars-litnone.pdf",height=5,width=6)
