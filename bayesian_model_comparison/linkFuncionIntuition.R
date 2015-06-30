logistic<-function(x, offset, scale){
  return (1/(1+exp(-scale*(x-offset))))
}
logit<-function(p){
  return(log(p/(1-p)))
}


bins<-seq(0.00001,0.99999,0.1)
bins<-seq(0,1,0.1)
scale_values<-seq(0,3,0.5)
offset_values<-seq(-5,5,0.5)

res<- data.frame(offset=NA,scale=NA,x=NA,y=NA)
for (k in 1: length(offset_values)){
  for (i in 1:length(scale_values)){
    for (j in 1:length(bins)){
      res[(k-1)*length(bins)*length(scale_values)+(i-1)*length(bins)+j,]$offset = offset_values[k]
      res[(k-1)*length(bins)*length(scale_values)+(i-1)*length(bins)+j,]$scale = scale_values[i]
      res[(k-1)*length(bins)*length(scale_values)+(i-1)*length(bins)+j,]$x = bins[j]
      res[(k-1)*length(bins)*length(scale_values)+(i-1)*length(bins)+j,]$y = logistic(logit(bins[j]),offset_values[k],scale_values[i])
    }
  }
}

res$scale<-factor(res$scale)
res$offset<-factor(res$offset)
ggplot(data=res, aes(x=x,y=y,color=scale))+
  geom_point()+
  geom_line()+
  facet_grid(scale~offset)



logistic(logit(0.9),0,1)
prob=0.9
p = logit(prob)
sigma = .9

hist(logistic(rnorm(1000,mean=p, sd=sigma),0,1))



## to help visualize a slider bar with a specific scale and offset
makeSlider <- function(scale, offset){
  bins<-seq(0,1,0.1)
  res = data.frame(x = NA, y = NA)
  for (j in 1:length(bins)){
    res[j,]$x = bins[j]
    res[j,]$y = logistic(logit(bins[j]),offset,scale)
  }  
  return(res)
}


qplot(data = makeSlider(1.4,0.2), x=x, y=y, geom='line')+
  geom_abline(yintercept=0,slope=1, linetype = 2)



