setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/20_sinking-marbles-prior-sliders/results/")
source("rscripts/helpers.r")

load("data/r.RData")


# histogram of trial types
ggplot(r,aes(x=Item)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)

# subject variability
# ggplot(r,aes(x=slider_id,y=response)) +
#   geom_point() +
#   facet_grid(Item~workerid)
# ggsave(file="graphs/subject_variability",width=30,height=30)

# normalized responses

agr = aggregate(normresponse ~ PriorProbability + slider_id + Item,data=r,FUN=mean)
agr$CILow = aggregate(normresponse ~ slider_id + Item,data=r, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ slider_id + Item,data=r,FUN=ci.high)$normresponse
#save(agrr, file="data/agrr.RData")
head(agr)
agr = agr %>% rename(prior_number = PriorProbability,
                     State = slider_id,
                     Item = Item,
                     prior_slider = normresponse)
agr$YMin = agr$prior_slider - agr$CILow
agr$YMax = agr$prior_slider + agr$CIHigh
gathered = agr %>% gather(Probability, value,-Item,-State,-YMin,-YMax,-CIHigh,-CILow)
gathered[gathered$Probability == "prior_number",]$YMin = gathered[gathered$Probability == "prior_number",]$value
gathered[gathered$Probability == "prior_number",]$YMax = gathered[gathered$Probability == "prior_number",]$value
head(gathered)

ggplot(gathered, aes(x=State, y=value, color=Probability)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item) +
  ylab("Prior Probability")
ggsave(file="graphs/norm_means.pdf",width=12,height=12)


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

ggplot(gathered, aes(x=State, y=value, color=Probability)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Item) +
  ylab("Prior Probability")
ggsave(file="graphs/raw_means.pdf",width=12,height=12)


