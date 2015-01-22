
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results")


# get empirical wonky probs for each item: p_n(wonky|"some") for n in {1, ..., 90}
load("../../../../experiments/11_sinking-marbles-normal/results/data/r.RData")
head(r)
nrow(r)
r$Item = as.factor(paste(r$effect, r$object))
t = as.data.frame(prop.table(table(r$Item,r$PriorExpectation,r$quantifier,r$response),mar=c(1,2,3)))
head(t)
nrow(t)
t = subset(t, !is.na(Freq))
colnames(t) = c("Item","PriorExpectation","Quantifier","Response","Proportion")
t = subset(t, Response == "no")
t = droplevels(t)
t$PriorExp = as.factor(as.character(round(as.numeric(as.character(t$PriorExpectation)),5)))
some = droplevels(subset(t, Quantifier == "Some"))
nrow(some)
head(some)
row.names(some) = some$Item


# get standard rRSA model outputs:
#   - for each item: p_n(s|"some") for n in {1, ..., 90}
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/mp.RData")
head(mp)
mp = droplevels(subset(mp, Alternatives == "0_basic" & QUD =="how-many" & SpeakerOptimality == 2))
nrow(mp)
mp$WonkyProbability_empirical = some[as.character(mp$Item),]$Proportion
head(mp)
tail(mp)


# get standard rRSA model outputs:
#   - for uniform prior p_uniform(s|"some")
# and add to mp
ursa = c(0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.07140600315955767, 0.0003159557661927334)
length(ursa)
mp$UniformProbability_predicted = rep(ursa, 90)
head(mp, 15)


# compute 
#   1. predicted expectations by taking p_n(wonky)*sum(p_uniform(s|"some")*s) + (1-p_n(wonky))*sum(p_n(s|"some")*s)
exps = ddply(mp, .(Item,PriorExpectation_smoothed,PosteriorExpectation_empirical), summarise, Expectation_predicted=(unique(WonkyProbability_empirical)*sum(UniformProbability_predicted*seq(1,15))+(1-unique(WonkyProbability_empirical))*sum(PosteriorProbability*seq(1,15))))
head(exps)
nrow(exps)

# test
sum(mp[mp$Item == "ate the seeds birds",]$PosteriorProbability*seq(1,15))
sum(mp[mp$Item == "ate the seeds butterflies",]$PosteriorProbability*seq(1,15))*.55 + sum(mp[mp$Item == "ate the seeds butterflies",]$UniformProbability_predicted*seq(1,15))*.45

ggplot(exps, aes(x=PriorExpectation_smoothed, y=Expectation_predicted/15)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(name="Predicted posterior expectation",limits=c(0,1))
ggsave("graphs/model-empiricalwonkiness-expectations.pdf")

ggplot(exps, aes(x=Expectation_predicted/15, y=PosteriorExpectation_empirical)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray60") +
  scale_x_continuous(name="Predicted posterior expectation",limits=c(0,1)) +
  scale_y_continuous(name="Empirical posterior expectation",limits=c(0,1))
ggsave("graphs/model-empirical-empiricalwonkiness-expectations.pdf")


# compute 
#   2. predicted p(s_all|u) by taking p_n(wonky)*p_uniform(s_all|"some") + (1-p_n(wonky))*p_n(s_all|"some")
ub = droplevels(subset(mp, State == 15))
nrow(ub)
head(ub)
ub$AllPosteriorProbability = ub$WonkyProbability_empirical*ub$UniformProbability_predicted + (1-ub$WonkyProbability_empirical)*ub$PosteriorProbability

ggplot(ub, aes(x=AllPriorProbability, y=AllPosteriorProbability)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(name="Predicted posterior all-state probability",limits=c(0,1))
ggsave("graphs/model-empiricalwonkiness-allstateprobs.pdf")

ggplot(ub, aes(x=AllPosteriorProbability, y=PosteriorProbability_empirical)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray60") +  
  scale_x_continuous(name="Predicted posterior all-state probability",limits=c(0,1)) +
  scale_y_continuous(name="Empirical posterior all-state probability",limits=c(0,1))  
ggsave("graphs/model-empirical-empiricalwonkiness-allstateprobs.pdf")


#### NOW NULLUTTERANCE ANALYSIS

# get nullutterance standard rRSA model outputs:
#   - for each item: p_n(s|"some") for n in {1, ..., 90}
 load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/mp-nullutterance.RData")
 head(mp)
 mp = droplevels(subset(mp, Alternatives == "0_basic" & QUD =="how-many" & SpeakerOptimality == 2))
 nrow(mp)
 mp$WonkyProbability_empirical = some[as.character(mp$Item),]$Proportion
 head(mp)
 tail(mp)


# get nullutterance standard rRSA model outputs with nullutterance cost = 5 (ie 5 times as likely to get sampled as other alternatives):
#   - for uniform prior p_uniform(s|"some")
# and add to mp
ursa = c(0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.0709590158895167, 0.006573777546765925)
length(ursa)
mp$NullutteranceUniformProbability_predicted = rep(ursa, 90)
head(mp, 15)


# compute 
#   1. predicted expectations by taking p_n(wonky)*sum(p_uniform(s|"some")*s) + (1-p_n(wonky))*sum(p_n(s|"some")*s)
exps = ddply(mp, .(Item,PriorExpectation_smoothed,PosteriorExpectation_empirical), summarise, Expectation_predicted=(unique(WonkyProbability_empirical)*sum(NullutteranceUniformProbability_predicted*seq(1,15))+(1-unique(WonkyProbability_empirical))*sum(PosteriorProbability*seq(1,15))))
head(exps)
nrow(exps)

# test
sum(mp[mp$Item == "ate the seeds birds",]$PosteriorProbability*seq(1,15))
sum(mp[mp$Item == "ate the seeds butterflies",]$PosteriorProbability*seq(1,15))*.55 + sum(mp[mp$Item == "ate the seeds butterflies",]$NullutteranceUniformProbability_predicted*seq(1,15))*.45

ggplot(exps, aes(x=PriorExpectation_smoothed, y=Expectation_predicted/15)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(name="Predicted posterior expectation",limits=c(0,1))
ggsave("graphs/model-empiricalwonkiness-nullutterance-expectations.pdf")

ggplot(exps, aes(x=Expectation_predicted/15, y=PosteriorExpectation_empirical)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray60") +
  scale_x_continuous(name="Predicted posterior expectation",limits=c(0,1)) +
  scale_y_continuous(name="Empirical posterior expectation",limits=c(0,1))
ggsave("graphs/model-empirical-empiricalwonkiness-nullutterance-expectations.pdf")


# compute 
#   2. predicted p(s_all|u) by taking p_n(wonky)*p_uniform(s_all|"some") + (1-p_n(wonky))*p_n(s_all|"some")
ub = droplevels(subset(mp, State == 15))
nrow(ub)
head(ub)
ub$AllPosteriorProbability = ub$WonkyProbability_empirical*ub$NullutteranceUniformProbability_predicted + (1-ub$WonkyProbability_empirical)*ub$PosteriorProbability

ggplot(ub, aes(x=AllPriorProbability, y=AllPosteriorProbability)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(name="Predicted posterior all-state probability",limits=c(0,1))
ggsave("graphs/model-empiricalwonkiness-nullutterance-allstateprobs.pdf")

ggplot(ub, aes(x=AllPosteriorProbability, y=PosteriorProbability_empirical)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray60") +  
  scale_x_continuous(name="Predicted posterior all-state probability",limits=c(0,1)) +
  scale_y_continuous(name="Empirical posterior all-state probability",limits=c(0,1))  
ggsave("graphs/model-empirical-empiricalwonkiness-nullutterance-allstateprobs.pdf")



