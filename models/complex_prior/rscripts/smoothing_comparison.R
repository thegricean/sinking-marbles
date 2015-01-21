setwd("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/models/complex_prior/")

d1 = read.csv("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/models/complex_prior/smoothed_unbinned15_bw5/smoothed_15marbles_bw5_priors.txt",sep="\t",header=F)
d1$Item = rownames(d1)
head(d1)
md1 = melt(d1,id.var="Item")
head(md1)
md1$Smoothing = "bw5"


d2 = read.csv("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/models/complex_prior/smoothed_unbinned15_bwdefault/smoothed_15marbles_priors.txt",sep="\t",header=F)
head(d2)
d2$Item = rownames(d2)
md2 = melt(d2,id.var="Item")
head(md2)
md2$Smoothing = "default"


dd = rbind(md1,md2)
head(dd)
ggplot(dd,aes(x=variable,y=value,color=Smoothing,group=Smoothing)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Item,scales="free")
ggsave("graphs/smoothing_comparison_pairwise.pdf",width=25,height=30)

md1$value1 = md1$value
md2$value2 = md2$value
d = cbind(md1,md2)
head(d)

ggplot(d,(aes(x=value1,y=value2,color=Smoothing))) +
  geom_point() +
  geom_abline(intercept =0,slope=1) +
  scale_x_continuous(name="Smoothed value with bw=5") +
  scale_y_continuous(name="Smoothed value with default bw") +  
  facet_wrap(~variable,scales="free")
ggsave("graphs/smoothing_comparison.pdf",width=11,height=6.5)
