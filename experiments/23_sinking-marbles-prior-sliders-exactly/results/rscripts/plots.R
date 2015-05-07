setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/23_sinking-marbles-prior-sliders-exactly/results/")
source("rscripts/helpers.r")

load("data/r.RData")

# histogram of trial types
ggplot(r,aes(x=Item)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)

# subject variability
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
ggplot(r,aes(x=slider_id,y=response,color=Half)) +
  geom_point() +
  facet_wrap(~workerid)
ggsave(file="graphs/subject_variability.pdf",width=20,height=20)

# weird people (hardly any variance in responses)
#badresponders = c("0","16")#,"6","13","16")

r = droplevels(subset(r, ! workerid %in% badresponders))
nrow(tmp)
nrow(r)

# normalized responses

agr = aggregate(normresponse ~ PriorProbability + slider_id + Item,data=r,FUN=mean)
agr$CILow = aggregate(normresponse ~ slider_id + Item,data=r, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ slider_id + Item,data=r,FUN=ci.high)$normresponse
#save(agrr, file="data/agrr.RData")
head(agr)
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh
gathered = agr %>% gather(Probability, value,-Item,-slider_id,-YMin,-YMax,-CIHigh,-CILow)
gathered[gathered$Probability == "prior_number",]$YMin = gathered[gathered$Probability == "prior_number",]$value
gathered[gathered$Probability == "prior_number",]$YMax = gathered[gathered$Probability == "prior_number",]$value
head(gathered)
save(agr, file="data/agr-normresponses.RData")
gathered$State = gathered$slider_id
write.table(agr[,c("slider_id","Item","normresponse","YMin","YMax")],file="data/aggregated_priors.csv",sep="\t",row.names=F,quote=F)

ggplot(gathered, aes(x=State, y=value, color=Probability)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item) +
  ylab("Prior Probability")
ggsave(file="graphs/norm_means.pdf",width=18,height=18)


agr = aggregate(response ~ PriorProbability + slider_id + Item,data=r,FUN=mean)
agr$CILow = aggregate(response ~ slider_id + Item,data=r, FUN=ci.low)$response
agr$CIHigh = aggregate(response ~ slider_id + Item,data=r,FUN=ci.high)$response
#save(agrr, file="data/agrr.RData")
head(agr)
agr = agr %>% rename(prior_number = PriorProbability,
                     State = slider_id,
                     Item = Item,
                     prior_slider = response)                     
agr$YMin = agr$prior_slider - agr$CILow
agr$YMax = agr$prior_slider + agr$CIHigh
gathered = agr %>% gather(Probability, value,-Item,-State,-YMin,-YMax,-CIHigh,-CILow)
gathered[gathered$Probability == "prior_number",]$YMin = gathered[gathered$Probability == "prior_number",]$value
gathered[gathered$Probability == "prior_number",]$YMax = gathered[gathered$Probability == "prior_number",]$value
head(gathered)
save(agr, file="data/agr-rawresponses.RData")

ggplot(gathered, aes(x=State, y=value, color=Probability)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item) +
  ylab("Prior Probability")
ggsave(file="graphs/raw_means.pdf",width=18,height=18)



### MERGE WITH PREVIOUS PRIOR EXPERIMENTS

load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/21_sinking-marbles-prior-sliders/results/data/r.RData")
r.descend = r
r.descend$order = "decreasing"
r.descend$effecttype = "normal"
r.descend$Exactly = "ambiguous"

load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/20_sinking-marbles-prior-sliders/results/data/r.RData")
r.ascend = r
r.ascend$order = "increasing"
r.ascend$effecttype = "normal"
r.ascend$Exactly = "ambiguous"
  
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/22_sinking-marbles-prior-sliders-subset-negation/results/data/r.RData")
r.subset = r
r.subset$Exactly = "exactly"
items = levels(r$Item)

load("data/r.RData")
r.exactly = r
r.exactly$Exactly = "exactly"
r.exactly$order = "mixed"
r.exactly$effecttype = "normal_replication"

r.descend = subset(r.descend, Item %in% items)
r.ascend = subset(r.ascend, Item %in% items)
r.exactly = subset(r.exactly, Item %in% items)

r = merge(r.subset,r.ascend,all=T)
r = merge(r, r.descend, all=T)
r = merge(r, r.exactly, all=T)
r$Exactly = as.factor(as.character(r$Exactly))

nrow(r)
summary(r)


# histogram of trial types
ggplot(r,aes(x=Item)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/allexps_trial_histogram.pdf",height=9,width=13)

## NORMALIZED RESPONSES

agr = aggregate(normresponse ~ PriorProbability + slider_id + Item + effecttype + Exactly,data=r,FUN=mean)
agr$CILow = aggregate(normresponse ~ slider_id + Item + effecttype + Exactly,data=r, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ slider_id + Item + effecttype + Exactly,data=r,FUN=ci.high)$normresponse
#save(agrr, file="data/agrr.RData")
head(agr)
agr$Unique = as.factor(paste(agr$effecttype, agr$Exactly, sep="_"))
agr$Exactly = NULL
agr$effecttype = NULL
summary(agr)  
agrr = agr[,c("PriorProbability","Item","Unique","slider_id","normresponse")] %>% spread(Unique, normresponse)
cilow = agr[,c("PriorProbability","Item","Unique","slider_id","CILow")] %>% spread(Unique, CILow)
cihigh = agr[,c("PriorProbability","Item","Unique","slider_id","CIHigh")] %>% spread(Unique, CIHigh)

head(cilow)

agrr = agrr %>% rename(pr_number = PriorProbability,
                     State = slider_id,
                     Item = Item,
                     pr_slider_negated_exactly = negated_exactly,
                     pr_slider_normal_exactly = normal_exactly,                     
                     pr_slider_normal_ambiguous = normal_ambiguous,
                     pr_slider_normal_replication_exactly = normal_replication_exactly                     )

cilow = cilow %>% rename(pr_number = PriorProbability,
                       State = slider_id,
                       Item = Item,
                       pr_slider_negated_exactly = negated_exactly,
                       pr_slider_normal_exactly = normal_exactly,                     
                       pr_slider_normal_ambiguous = normal_ambiguous,
                       pr_slider_normal_replication_exactly = normal_replication_exactly                                            )

cihigh = cihigh %>% rename(pr_number = PriorProbability,
                         State = slider_id,
                         Item = Item,
                         pr_slider_negated_exactly = negated_exactly,
                         pr_slider_normal_exactly = normal_exactly,                     
                         pr_slider_normal_ambiguous = normal_ambiguous,
                         pr_slider_normal_replication_exactly = normal_replication_exactly                         )

gathered = agrr %>% gather(Probability, value,-Item,-State)
gathered.cilow = cilow %>% gather(Probability, value,-Item,-State)
gathered.cilow[gathered.cilow$Probability == "pr_number",]$value = 0
gathered.cihigh = cihigh %>% gather(Probability, value,-Item,-State)
gathered.cihigh[gathered.cihigh$Probability == "pr_number",]$value = 0
tail(gathered.cihigh)

gathered$YMin = gathered$value - gathered.cilow$value
gathered$YMax = gathered$value + gathered.cihigh$value

save(gathered, file="data/gathered-normresponses.RData")

ggplot(gathered, aes(x=State, y=value, color=Probability)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item) +
  ylab("Prior Probability")
ggsave(file="graphs/allexps_norm_means.pdf",width=15,height=12)


## RAW RESPONSES
agr = aggregate(response ~ PriorProbability + slider_id + Item + effecttype + Exactly,data=r,FUN=mean)
agr$CILow = aggregate(response ~ slider_id + Item + effecttype + Exactly,data=r, FUN=ci.low)$response
agr$CIHigh = aggregate(response ~ slider_id + Item + effecttype + Exactly,data=r,FUN=ci.high)$response
#save(agrr, file="data/agrr.RData")
head(agr)
agr$Unique = as.factor(paste(agr$effecttype, agr$Exactly, sep="_"))
agr$Exactly = NULL
agr$effecttype = NULL
summary(agr)  
agrr = agr[,c("PriorProbability","Item","Unique","slider_id","response")] %>% spread(Unique, response)
cilow = agr[,c("PriorProbability","Item","Unique","slider_id","CILow")] %>% spread(Unique, CILow)
cihigh = agr[,c("PriorProbability","Item","Unique","slider_id","CIHigh")] %>% spread(Unique, CIHigh)

head(cilow)

agrr = agrr %>% rename(pr_number = PriorProbability,
                       State = slider_id,
                       Item = Item,
                       pr_slider_negated_exactly = negated_exactly,
                       pr_slider_normal_exactly = normal_exactly,                     
                       pr_slider_normal_ambiguous = normal_ambiguous,
                       pr_slider_normal_replication_exactly = normal_replication_exactly)

cilow = cilow %>% rename(pr_number = PriorProbability,
                         State = slider_id,
                         Item = Item,
                         pr_slider_negated_exactly = negated_exactly,
                         pr_slider_normal_exactly = normal_exactly,                     
                         pr_slider_normal_ambiguous = normal_ambiguous,
                         pr_slider_normal_replication_exactly = normal_replication_exactly)

cihigh = cihigh %>% rename(pr_number = PriorProbability,
                           State = slider_id,
                           Item = Item,
                           pr_slider_negated_exactly = negated_exactly,
                           pr_slider_normal_exactly = normal_exactly,                     
                           pr_slider_normal_ambiguous = normal_ambiguous,
                           pr_slider_normal_replication_exactly = normal_replication_exactly)

gathered = agrr %>% gather(Probability, value,-Item,-State)
gathered.cilow = cilow %>% gather(Probability, value,-Item,-State)
gathered.cilow[gathered.cilow$Probability == "pr_number",]$value = 0
gathered.cihigh = cihigh %>% gather(Probability, value,-Item,-State)
gathered.cihigh[gathered.cihigh$Probability == "pr_number",]$value = 0
tail(gathered.cihigh)

gathered$YMin = gathered$value - gathered.cilow$value
gathered$YMax = gathered$value + gathered.cihigh$value

save(gathered, file="data/gathered-responses.RData")

ggplot(gathered, aes(x=State, y=value, color=Probability)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item) +
  ylab("Prior Probability")
ggsave(file="graphs/allexps_raw_means.pdf",width=15,height=12)



### MERGE WITH PREVIOUS FULL LENGTH PRIOR EXPERIMENTS (WITHOUT "EXACTLY")

load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/21_sinking-marbles-prior-sliders/results/data/r.RData")
r.descend = r
r.descend$order = "decreasing"
r.descend$Exactly = "ambiguous"

load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/20_sinking-marbles-prior-sliders/results/data/r.RData")
r.ascend = r
r.ascend$order = "increasing"
r.ascend$Exactly = "ambiguous"

load("data/r.RData")
r.exactly = r
r.exactly$Exactly = "exactly"

r = merge(r.descend,r.ascend,all=T)
r = merge(r, r.exactly, all=T)
r$Exactly = as.factor(as.character(r$Exactly))
r$order = as.factor(as.character(r$order))

nrow(r)
summary(r)

# plot with and without "exactly" in same plot
agr = aggregate(normresponse ~ slider_id + Item + Exactly,data=r,FUN=mean)
agr$CILow = aggregate(normresponse ~ slider_id + Item + Exactly,data=r, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ slider_id + Item + Exactly,data=r,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

ggplot(agr, aes(x=slider_id, y=normresponse, color=Exactly)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item) +
  ylab("Prior Probability")
ggsave("graphs/full_length_byexactly.pdf",width=18,height=18)

# plot additionally by order and without "exactly" in same plot
agr = aggregate(normresponse ~ slider_id + Item + Exactly + order,data=r,FUN=mean)
agr$CILow = aggregate(normresponse ~ slider_id + Item + Exactly + order,data=r, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ slider_id + Item + Exactly + order,data=r,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

ggplot(agr, aes(x=slider_id, y=normresponse, color=Exactly, shape=order, linetype=order)) +
  geom_point() +
  geom_line() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item) +
  ylab("Prior Probability")
ggsave("graphs/full_length_byexactly_byorder.pdf",width=18,height=18)


# plot individual subjects' responses to get people who were just responding arbitrarily
load("data/r.RData")

r$workerid = as.factor(as.character(r$workerid))
for (i in levels(r$workerid))
{
  p=ggplot(r[r$workerid == i,], aes(x=slider_id,y=response,color=Half)) +
    geom_point() +
    geom_line() +
    facet_wrap(~Item)
  ggsave(plot=p, filename=paste("graphs/individual_subjects/",i,".pdf",sep=""),height=10,width=14)
  
}

for (i in levels(r$workerid))
{
  p=ggplot(r[r$workerid == i,], aes(x=slider_id,y=normresponse)) +
    geom_point() +
    geom_line() +
    facet_wrap(~Item)
  ggsave(plot=p, filename=paste("graphs/individual_subjects/normalized",i,".pdf",sep=""),height=10,width=14)
  
}


