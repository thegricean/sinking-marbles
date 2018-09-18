library(ggplot2)
library(np)

getSmoothedProbability = function(d) {
  return (npudens(tdat=ordered(d$response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001)/sum(npudens(tdat=ordered(d$response),edat=ordered(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)))$dens+0.0000001) 
}

# load replication data
r1 = read.table("../data/sinking_marbles.csv", sep=",", header=T)
r1 = r[,c("workerid", "rt", "effect", "cause", "object_level", "response", "object")]
r1$workerid = r1$workerid + 60

# load original data
r2 = read.table("../../../12_sinking-marbles-prior15/results/data/sinking_marbles.tsv", sep="\t", header=T)
r2 = r[,c("workerid", "rt", "effect", "cause", "object_level", "response", "object")]

# merge the two datasets, should be 7200 data points
r = rbind(r1,r2)

# write the merged datasets to file 
write.csv(r %>% select(workerid,Item,response), file="../data/priors_original_unsmoothed.csv",row.names=F,quote=F)

r$Item = as.factor(paste(r$effect,r$object))

## plot subject variability
ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~workerid)
ggsave(file="graphs/subject_variability.pdf",width=20,height=15)
table(r$workerid)

# how many judgments per item
min(table(r$Item))
max(table(r$Item))
t = as.data.frame(table(r$Item))
t[order(t[,c("Freq")]),]

## plot individual items
r$Item = as.factor(paste(r$effect,r$object))
ggplot(r, aes(x=response)) +
  geom_histogram(stat="count") +
  facet_wrap(~Item)
ggsave(file="../graphs/item_variability.pdf",width=20,height=15)

# get smoothed priors for model -- ARGH STH IS WRONG WITH THE SMOOTHED PROBABILITY FUNCTION, IT'S RETURNING THE SAME THING FOR SMOOTHED AND UNSMOOTHED DISTS
smoothed = r %>%
  group_by(Item) %>%
  nest() %>%
  mutate(SmoothedProportion = map(data,getSmoothedProbability)) %>%
  select(-data) %>%
  unnest() %>%
  mutate(State = rep(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),length(unique(Item))))

sums = smoothed %>%
  group_by(Item) %>%
  summarize(Sum = sum(SmoothedProportion))

smoothed = smoothed %>%
  left_join(sums,by=c("Item")) %>%
  mutate(SmoothedProportion = SmoothedProportion/Sum) %>%
  select(-Sum)

ggplot(smoothed, aes(x=State,y=SmoothedProportion)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)


# get empirical unsmoothed priors
priors = as.data.frame(prop.table(table(r$Item,r$response),mar=c(1)))
colnames(priors) = c("Item","State","EmpiricalProportion")
priors = priors %>% 
  mutate(State = as.numeric(as.character(State))) %>%
  left_join(smoothed,by=c("Item","State"))
head(priors)

gpriors = priors %>%
  gather(Type,Proportion,-Item,-State) 

ggplot(gpriors,aes(State,y=Proportion,color=Type)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)

