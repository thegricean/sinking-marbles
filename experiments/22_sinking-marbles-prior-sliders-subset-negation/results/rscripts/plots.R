setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/22_sinking-marbles-prior-sliders-subset-negation/results/")
source("rscripts/helpers.r")

load("data/r.RData")

# histogram of trial types
ggplot(r,aes(x=Item)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)

# subject variability
r$Half = as.factor(ifelse(r$trial < 5, 1, 2))
ggplot(r,aes(x=slider_id,y=response,color=Half)) +
  geom_point() +
  facet_wrap(~workerid)
ggsave(file="graphs/subject_variability.pdf",width=15,height=10)

# weird people (hardly any variance in responses)
badresponders = c("0","16")#,"6","13","16")

r = droplevels(subset(r, ! workerid %in% badresponders))
nrow(tmp)
nrow(r)

# normalized responses

agr = aggregate(normresponse ~ PriorProbability + slider_id + Item + effecttype,data=r,FUN=mean)
agr$CILow = aggregate(normresponse ~ slider_id + Item + effecttype,data=r, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ slider_id + Item + effecttype,data=r,FUN=ci.high)$normresponse
#save(agrr, file="data/agrr.RData")
head(agr)
agr = agr %>% rename(prior_number = PriorProbability,
                     State = slider_id,
                     Item = Item,
                     prior_slider = normresponse,
                     SentenceForm = effecttype)
agr$YMin = agr$prior_slider - agr$CILow
agr$YMax = agr$prior_slider + agr$CIHigh
gathered = agr %>% gather(Probability, value,-Item,-State,-YMin,-YMax,-CIHigh,-CILow,-SentenceForm)
gathered[gathered$Probability == "prior_number",]$YMin = gathered[gathered$Probability == "prior_number",]$value
gathered[gathered$Probability == "prior_number",]$YMax = gathered[gathered$Probability == "prior_number",]$value
head(gathered)
save(agr, file="data/agr-normresponses.RData")

ggplot(gathered, aes(x=State, y=value, color=Probability)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_grid(SentenceForm~Item) +
  ylab("Prior Probability")
ggsave(file="graphs/norm_means.pdf",width=18,height=6)


agr = aggregate(response ~ PriorProbability + slider_id + Item + effecttype,data=r,FUN=mean)
agr$CILow = aggregate(response ~ slider_id + Item + effecttype,data=r, FUN=ci.low)$response
agr$CIHigh = aggregate(response ~ slider_id + Item + effecttype,data=r,FUN=ci.high)$response
#save(agrr, file="data/agrr.RData")
head(agr)
agr = agr %>% rename(prior_number = PriorProbability,
                     State = slider_id,
                     Item = Item,
                     prior_slider = response,
                     SentenceForm = effecttype)                     
agr$YMin = agr$prior_slider - agr$CILow
agr$YMax = agr$prior_slider + agr$CIHigh
gathered = agr %>% gather(Probability, value,-Item,-State,-YMin,-YMax,-CIHigh,-CILow,-SentenceForm)
gathered[gathered$Probability == "prior_number",]$YMin = gathered[gathered$Probability == "prior_number",]$value
gathered[gathered$Probability == "prior_number",]$YMax = gathered[gathered$Probability == "prior_number",]$value
head(gathered)
save(agr, file="data/agr-rawresponses.RData")

ggplot(gathered, aes(x=State, y=value, color=Probability)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_grid(SentenceForm~Item) +
  ylab("Prior Probability")
ggsave(file="graphs/raw_means.pdf",width=18,height=6)



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
  
load("data/r.RData")
items = levels(r$Item)
r.subset = r
r.subset$Exactly = "exactly"

r.descend = subset(r.descend, Item %in% items)
r.ascend = subset(r.ascend, Item %in% items)

r = merge(r.subset,r.ascend,all=T)
r = merge(r, r.descend, all=T)
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
                     pr_slider_normal_ambiguous = normal_ambiguous                                    )

cilow = cilow %>% rename(pr_number = PriorProbability,
                       State = slider_id,
                       Item = Item,
                       pr_slider_negated_exactly = negated_exactly,
                       pr_slider_normal_exactly = normal_exactly,                     
                       pr_slider_normal_ambiguous = normal_ambiguous                                    )

cihigh = cihigh %>% rename(pr_number = PriorProbability,
                         State = slider_id,
                         Item = Item,
                         pr_slider_negated_exactly = negated_exactly,
                         pr_slider_normal_exactly = normal_exactly,                     
                         pr_slider_normal_ambiguous = normal_ambiguous                                    )

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
                       pr_slider_normal_ambiguous = normal_ambiguous                                    )

cilow = cilow %>% rename(pr_number = PriorProbability,
                         State = slider_id,
                         Item = Item,
                         pr_slider_negated_exactly = negated_exactly,
                         pr_slider_normal_exactly = normal_exactly,                     
                         pr_slider_normal_ambiguous = normal_ambiguous                                    )

cihigh = cihigh %>% rename(pr_number = PriorProbability,
                           State = slider_id,
                           Item = Item,
                           pr_slider_negated_exactly = negated_exactly,
                           pr_slider_normal_exactly = normal_exactly,                     
                           pr_slider_normal_ambiguous = normal_ambiguous                                    )

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


### PLOT ALL NEGATED
negated = droplevels(subset(r, effecttype == "negated"))

ggplot(negated, aes(x=slider_id,y=response,color=as.factor(workerid))) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)
  
crazypeople = c("0","2","6","37","29","13","16","33","14")

negated$Crazy = as.factor(ifelse(negated$workerid %in% crazypeople, "crazy","reasonable"))

ggplot(negated, aes(x=slider_id,y=response,color=as.factor(workerid))) +
  geom_point() +
  geom_line() +
  facet_grid(Item~Crazy)
ggsave(file="graphs/negated.pdf")

agr = aggregate(normresponse ~ Crazy + slider_id + Item, data=negated, FUN=mean)
agr$CILow = aggregate(normresponse ~ Crazy + slider_id + Item, data=negated, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ Crazy + slider_id + Item ,data=negated,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

ggplot(agr, aes(x=slider_id, y=normresponse, color=Crazy)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item)
ggsave(file="graphs/negated_bycrazy.pdf")


### PLOT ALL NON-NEGATED EXACTLY
exactly = droplevels(subset(r, effecttype == "normal" & Exactly == "exactly"))

ggplot(exactly, aes(x=slider_id,y=response,color=as.factor(workerid))) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)

crazypeople = c("1","10","12")

exactly$Crazy = as.factor(ifelse(exactly$workerid %in% crazypeople, "crazy","reasonable"))

ggplot(exactly, aes(x=slider_id,y=response,color=as.factor(workerid))) +
  geom_point() +
  geom_line() +
  facet_grid(Item~Crazy)
ggsave(file="graphs/exactly.pdf")

agr = aggregate(normresponse ~ Crazy + slider_id + Item, data=exactly, FUN=mean)
agr$CILow = aggregate(normresponse ~ Crazy + slider_id + Item, data=exactly, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ Crazy + slider_id + Item ,data=exactly,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

ggplot(agr, aes(x=slider_id, y=normresponse, color=Crazy)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item)
ggsave(file="graphs/exactly_bycrazy.pdf")

