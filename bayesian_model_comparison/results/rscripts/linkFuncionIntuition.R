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
prob=0.5
p = logit(prob)
sigma = 0.1

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


## prior of 1/gamma(0.001,0.001)

ggplot(data.frame(x=1/rgamma(1000,shape=5, scale=1)),aes(x=x))+
  geom_histogram()+
  xlim(0,5)
 
## prior of lognormal

ggplot(data.frame(x = exp(rnorm(1000,mean=0,sd=0.25))),aes(x=x))+
  geom_histogram()




## logit-space gaussian noise link (to finish)


avoidEnds <- function(x){
 return (if (x > 0.99) {
    0.99
  } else if (x < 0.01) {
    0.01
  } else {
    x
  })
}

makeMarbles <- function(coinWeight){
  return(dbinom(seq(0,15, 1), 15, coinWeight))
}

expectation <- function(normed_probs){
  states <- seq(0, 15, 1)
  return (sum (states * normed_probs))
}

addNoise <- function(probs, sigma){
  logit_slider_probs <- logit(sapply((states/states[16]), avoidEnds))
  expval <- expectation(probs)/15
  logit_ev <- logit(expval)
  linked_probs <- dnorm(logit_slider_probs, 
                        mean = logit_ev, 
                        sd = sigma)
  linked_ev <- expectation(linked_probs/sum(linked_probs))
  return (linked_ev)
  
}


noise_levels<-seq(0.01, 3, 0.25)

simulate.logitNoise <- data.frame()
for (n in noise_levels){
  tmp<- data.frame(base_rates = seq(0.01,0.99,0.01),
                   sigma = n) %>%
              rowwise() %>% 
              mutate(noLink = expectation(makeMarbles(base_rates)),
                     noiseLink = addNoise(makeMarbles(base_rates),n))


expectation(makeMarbles(0.99))
addNoise(makeMarbles(0.99),0)







