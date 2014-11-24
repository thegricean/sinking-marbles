library(ggplot2)
#setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-prior/results/")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/1_sinking-marbles-prior/results/")
source("rscripts/summarySE.r")
r = read.table("data/sinking-marbles-prior.tsv", sep="\t", header=T)
r = r[,c("workerid", "rt", "effect", "cause", "object_level", "response", "object")]

r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
s = summarySE(r, measurevar="response", groupvars=c("effect", "object_level", "object"))
priors = s
save(priors, file="data/priors.RData")
load("data/priors.RData")

graph_title = "sinking-marbles-prior"
ggplot(s, aes(x=effect, y=response)) +
  geom_point(aes(colour=factor(object_level)), stat="identity") +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci, colour=factor(object_level)), width=.3) +
  ylab("") +
  xlab("") +
  theme_bw(18) +
  theme(
    axis.text.x = element_text(size=10, angle=-45, hjust=0)
    ,plot.background = element_blank()
    ,panel.grid.minor = element_blank()
  )
ggsave(file=paste(c("graphs/",graph_title, ".png"), collapse=""), width=15, height=6, title=graph_title)

graph_title = "sinking-marbles-prior-with-labels"
ggplot(s, aes(x=effect, y=response)) +
  geom_point(aes(colour=factor(object_level)), stat="identity") +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci, colour=factor(object_level)), width=.3) +
  geom_text(aes(label=object), size=3) +
  ylab("") +
  xlab("") +
  theme_bw(18) +
  theme(
    axis.text.x = element_text(size=10, angle=-45, hjust=0)
    ,plot.background = element_blank()
    ,panel.grid.minor = element_blank()
  )
ggsave(file=paste(c("graphs/",graph_title, ".png"), collapse=""), width=15, height=6, title=graph_title)

s$y = 0
s$yobject = as.numeric(ifelse(s$object_level == "object_high",0.25,ifelse(s$object_level =="object_mid",0,-0.25)))
ggplot(s, aes(x=response, y=yobject)) +
  geom_point(aes(colour=factor(object_level)))  +
  geom_text(aes(label=effect,y=yobject-0.05),angle=45) +
  theme_bw(18) +
  theme(
    axis.text.x = element_text(size=10, angle=-45, hjust=0)
    ,plot.background = element_blank()
    ,panel.grid.minor = element_blank()
  )
graph_title = "sinking-marbles-prior-distribution"
ggsave(file=paste(c("graphs/",graph_title, ".png"), collapse=""), width=15, height=6, title=graph_title)

ggplot(s, aes(x=response, fill=factor(object_level))) +
  geom_histogram(position="dodge")  +
  theme_bw(18) +
  theme(
    axis.text.x = element_text(size=10, angle=-45, hjust=0)
    ,plot.background = element_blank()
    ,panel.grid.minor = element_blank()
  )
graph_title = "sinking-marbles-prior-histogram"
ggsave(file=paste(c("graphs/",graph_title, ".png"), collapse=""), width=15, height=6, title=graph_title)

## plot variance histogram
ggplot(priors, aes(x=sd)) +
  geom_histogram()

## plot individual items
r$Combo = as.factor(paste(r$effect,r$object))
ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~Combo)
ggsave(file="graphs/item_variability.pdf",width=20,height=15)


r$Bin = as.factor(ifelse(r$response == 0, 0, ifelse(r$response < 51, 50, ifelse(r$response < 100, 99, 100))))
ggplot(r, aes(x=Bin)) +
  geom_histogram() +
  facet_wrap(~Combo)
ggsave(file="graphs/item_variability_binned.pdf",width=20,height=15)

t = as.data.frame(prop.table(table(r$Bin,r$Combo),mar=2))
colnames(t) = c("Bin","Combo","Proportion")
tail(t)
t$Proportion = round(t$Proportion,digits=3)
t$SmoothedProportion = t$Proportion + 0.001
library(reshape2)
casted = dcast(t, Combo ~ Bin, value.var="Proportion")
write.table(casted,file="data/binned_priors_norownames.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,c("0","50","99","100")],file="data/binned_priors.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,c("0","50","99","100")],file="data/binned_priors.txt",row.names=F,quote=F,sep=" ")
nrow(casted) # 90 different priors
# get smoothed probs (no zero-probs) so model doesn't freak out
casted = dcast(t, Combo ~ Bin, value.var="SmoothedProportion")
write.table(casted[,c("0","50","99","100")],file="data/binned_priors_smoothed.txt",row.names=F,quote=F,sep=" ")
row.names(casted) = as.character(casted$Combo)
head(casted)

head(priors)
row.names(priors) = paste(priors$effect, priors$object)
priors$r_all = casted[paste(priors$effect, priors$object),5]
priors$r_upper_half = casted[paste(priors$effect, priors$object),4]
priors$r_lower_half = casted[paste(priors$effect, priors$object),3]
priors$r_none = casted[paste(priors$effect, priors$object),2]

# plot all-prior mean vs proportion all against each other
priors$resp = priors$response/100
ggplot(priors, aes(x=resp,y=r_all)) +
  geom_point() +
  xlab("all-prior (mean)") +
  ylab("all-prior (proportion)") +
  geom_abline(intercept=0,slope=1)
ggsave("~/Dropbox/sinking_marbles/sinking-marbles/experiments/1_sinking-marbles-prior/results/graphs/mean-vs-proportion-allprior.pdf")

sank = subset(r, effect == "sank" & object == "balloons")
sank
ds = density(sank$response,n=101,from=0,to=100)#,bw=5)#,bw=2)
plot(ds$x,ds$y)
sum(ds$x*ds$y)
str(ds)

ds = density(sank$response,n=16,from=0,to=15)#,bw=5)#,bw=2)
plot(ds$x,ds$y)

seeds = subset(r, effect == "ate the seeds" & object == "birds")
seeds
d = density(seeds$response,n=101,from=0,to=100)#,bw=2)
plot(d$x,d$y)
sum(d$x*d$y)

felldown = subset(r, effect == "fell down" & object == "card towers")
felldown
df = density(felldown$response,n=101,from=0,to=100)#,bw=2)
plot(df$x,df$y)
sum(df$x*df$y)

expectations = ddply(r, .(effect,object), summarize, expectation=sum(density(response,n=101,from=0,to=100)$x*density(response,n=101,from=0,to=100)$y))
expectations5 = ddply(r, .(effect,object), summarize, expectation=sum(density(response,n=101,from=0,to=100,bw=5)$x*density(response,n=101,from=0,to=100,bw=5)$y))
mean(expectations$expectation)
median(expectations$expectation)
mean(expectations5$expectation)
median(expectations5$expectation)

ggplot(expectations, aes(x=expectation)) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,100))

ggplot(expectations5, aes(x=expectation)) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,100))

head(expectations)
nrow(priors)
nrow(expectations)
write.table(expectations,row.names=F,sep="\t",quote=F,file="data/expectations.txt")
write.table(expectations5,row.names=F,sep="\t",quote=F,file="data/expectations5.txt")

smoothedpriors = ddply(r, .(effect,object), summarize, smoothprior=density(response,n=101,from=0,to=100)$x*density(response,n=101,from=0,to=100)$y)
