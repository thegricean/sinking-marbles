setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_data_analysis/")

load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_data_analysis/expval_prits_bothTasks_justInfer_iter1000_burn500_thin0_x1.Rdata")

summary(sky.prior)
str(sky.prior)
tail(sky.prior,10)

sky.prior[sky.prior$item == "sank.marbles",]

sky.prior$Item = gsub("."," ",as.character(sky.prior$item),fixed=T)
summary(sky.prior)

casted = sky.prior %>% 
            select(Item,state,expval) %>%
            spread(state,expval)

summary(casted)
head(casted)

write.table(casted,file="prits_withnames.txt",row.names=F,quote=F,sep="\t")
write.table(casted,file="../models/wonky_world/prits_withnames.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,2:length(colnames(casted))],file="prits.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,1],file="items.txt",row.names=F,quote=F,sep="\t")
write.table(casted[,2:length(colnames(casted))],file="../models/wonky_world/prits.txt",row.names=F,quote=F,sep="\t")

expectations = ddply(sky.prior, .(Item), summarise, expectation=sum(state*expval))
head(expectations)
summary(expectations)

write.table(expectations[,c("Item","expectation")],row.names=F,sep="\t",quote=F,file="/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_data_analysis/expectations.txt")
ordered = expectations[order(expectations[,c("expectation")]),c("Item","expectation")]
write.table(ordered[,c("Item","expectation")],row.names=F,sep="\t",quote=F,file="/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_data_analysis/ordered_expectations.txt")
head(ordered)
tail(ordered)
