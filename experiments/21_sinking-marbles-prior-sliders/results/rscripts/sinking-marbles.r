library(tidyverse)
theme_set(theme_bw(18))
source("helpers.r")

getNormalizedProbability = function(d) {
  dd = as.data.frame(d)
  total = sum(dd$MeanResponse)
  smooth = dd %>%
    group_by(slider_id) %>%
    mutate(NormalizedProb = MeanResponse / total)
  return(smooth$NormalizedProb)
}

# load("data/r.RData")
# load("../../1_sinking-marbles-prior/results/data/priors.RData")
r1 = read.csv("../data/sinking_marbles.csv", header=T)
r1$workerid = r1$workerid + 60

r2 = read.csv("../../../20_sinking-marbles-prior-sliders/results/data/sinking_marbles.csv", header=T)

r = rbind(r1,r2)
nrow(r)
head(r)

r$trial = r$slide_number_in_experiment - 2
r = r[,c("assignmentid","workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender", "object_level", "response", "object","slider_id","num_objects","trial","enjoyment","asses","comments","Answer.time_in_minutes","slider_id")]
r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
r$Item = as.factor(paste(r$effect,r$object))
table(r$Item)

# compute normalized probabilities
nr = r %>%
  select(Item,slider_id,response) %>%
  group_by(Item,slider_id) %>%
  summarize(MeanResponse = mean(response)) %>%
  ungroup() %>%
  group_by(Item) %>%
  nest() %>%
  mutate(SmoothedProportion = map(data,getNormalizedProbability)) %>%
  unnest()

ggplot(nr, aes(x=slider_id,y=SmoothedProportion)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item)


# write probabilities (no smoothing required, but we call it smoothed anyway for comparison with the other priors datasets) for model comparison
smoothed_spread = nr %>%
  select(-MeanResponse) %>%
  spread(slider_id,SmoothedProportion)

write.csv(smoothed_spread,file="../data/priors_binnedhistogram_smoothed.csv",row.names=F,quote=F)
write.csv(smoothed_spread,file="../../../../bayesian_model_comparison/data/priors_binnedhistogram_smoothed.csv",row.names=F,quote=F)


##################

ggplot(aes(x=gender.1), data=r) +
  geom_histogram()

ggplot(aes(x=rt), data=r) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,50000))

ggplot(aes(x=age), data=r) +
  geom_histogram()

ggplot(aes(x=age,fill=gender.1), data=r) +
  geom_histogram()

ggplot(aes(x=enjoyment), data=r) +
  geom_histogram()

ggplot(aes(x=asses), data=r) +
  geom_histogram()

ggplot(aes(x=Answer.time_in_minutes), data=r) +
  geom_histogram()

ggplot(aes(x=age,y=Answer.time_in_minutes,color=gender.1), data=unique(r[,c("assignmentid","age","Answer.time_in_minutes","gender.1")])) +
  geom_point() +
  geom_smooth()

unique(r$comments)

