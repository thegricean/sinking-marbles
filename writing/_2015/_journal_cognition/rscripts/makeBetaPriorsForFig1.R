setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/_journal_cognition")

d = data.frame(a=c(200,150,100,70,60,50,40,30,20,18,16,14,12,10,9,8,7,6,5,4,3,2.5,2,1.8,1.6,1.4,1.2,1,rep(0.1,28),rep(1,9),seq(.2,1,.1)),b=c(rep(0.1,28),200,150,100,70,60,50,40,30,20,18,16,14,12,10,9,8,7,6,5,4,3,2.5,2,1.8,1.6,1.4,1.2,1,seq(.2,1,.1),rep(1,9)))

agr = d %>% group_by(a,b) %>%
  summarise(p.0=dbeta(x = seq(.03,.99,1/16), a, b)[1]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.1=dbeta(x = seq(.03,.99,1/16), a, b)[2]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.2=dbeta(x = seq(.03,.99,1/16), a, b)[3]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.3=dbeta(x = seq(.03,.99,1/16), a, b)[4]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.4=dbeta(x = seq(.03,.99,1/16), a, b)[5]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.5=dbeta(x = seq(.03,.99,1/16), a, b)[6]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.6=dbeta(x = seq(.03,.99,1/16), a, b)[7]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.7=dbeta(x = seq(.03,.99,1/16), a, b)[8]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.8=dbeta(x = seq(.03,.99,1/16), a, b)[9]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.9=dbeta(x = seq(.03,.99,1/16), a, b)[10]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.10=dbeta(x = seq(.03,.99,1/16), a, b)[11]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.11=dbeta(x = seq(.03,.99,1/16), a, b)[12]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.12=dbeta(x = seq(.03,.99,1/16), a, b)[13]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.13=dbeta(x = seq(.03,.99,1/16), a, b)[14]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.14=dbeta(x = seq(.03,.99,1/16), a, b)[15]/sum(dbeta(x = seq(.03,.99,1/16), a, b)),p.15=dbeta(x = seq(.03,.99,1/16), a, b)[16]/sum(dbeta(x = seq(.03,.99,1/16), a, b)))

agr = as.data.frame(agr)
nrow(agr)
head(agr)

agr = agr %>% gather(state,prob,p.0:p.15,-a,-b)

ggplot(agr, aes(x=state,y=prob,color=as.factor(paste(a,b)),group=as.factor(paste(a,b)))) +
  geom_point() +
  geom_line()

max(agr[agr$state == "p.15",]$prob)
max(agr[agr$state == "p.0",]$prob)

agr$state = gsub("p.","",agr$state)
agr$state = as.numeric(as.character(agr$state))
exps = agr %>% 
  group_by(a,b) %>%
  summarise(exp=sum(state*prob))

ggplot(exps, aes(x=exp)) +
  geom_histogram()

agr$Item = paste(agr$a,agr$b,sep="_")
agr$a=NULL
agr$b=NULL

spred = agr %>%
  spread(state,prob)
head(spred)
nrow(spred)

write.table(spred, file="models/betapriors.txt", row.names=F, sep="\t")

