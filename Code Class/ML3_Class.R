rm(list = ls())
getwd()
library(caret)
library(caretEnsemble)
{
  ml3_res = read.csv("P3-Class Original Data/Yes_Bank_Test_int.csv")
  dim(ml3_res)
  sum(is.na(ml3_res))
  names(ml3_res)
  str(ml3_res)
  
  
  ml3_ca = read.csv("P3-Class Original Data/Yes_Bank_Train.csv")
  dim(ml3_ca)
  sum(is.na(ml3_ca))
  names(ml3_ca)
  str(ml3_ca)
  ml3_ca$serial.number = NULL
  
  
  ml3_ca$credit_amount = ifelse(ml3_ca$credit_amount < 1500,"3",
                                ifelse(ml3_ca$credit_amount > 1500 & ml3_ca$credit_amount < 4000,"2",
                                       ifelse(ml3_ca$credit_amount > 4000 & ml3_ca$credit_amount < 20000,"1",NA)))
  ml3_ca$credit_amount = as.factor(ml3_ca$credit_amount)
#prop.table(table(ml3_ca$credit_amount))
}
names(ml3_res)[!(names(ml3_res) %in% names(ml3_ca))]
names(ml3_ca)[!(names(ml3_ca) %in% names(ml3_res))]

#######################################################
######## Possible Datasets##########
ca_int = c("poi","resident_since", "credits_no", "liables")
{
  ## Train
  ca_trainset = ml3_ca
  ca_trainset[ca_int] = lapply(ca_trainset[ca_int], factor)
  sapply(ca_trainset, class)
  
  ## Test
  ca_testset = ml3_res
  ca_testset[ca_int] = lapply(ca_testset[ca_int], factor)
  sapply(ca_testset, class)
}

########## Train and Test-set ##########
set.seed(11102018)
ind = createDataPartition(ca_trainset$credit_amount, p = 3/4,list = F)
ctrain = ca_trainset[ind,]
ctest = ca_trainset[-ind,]
prop.table(table(ctrain$credit_amount))
prop.table(table(ctest$credit_amount))


########## Model Development (All Variables)###########

new_control = trainControl(method = 'repeatedcv',
                       number = 10,
                       repeats = 5)


names(ctrain)
seed = 11102018
metric = "Accuracy"

##### Boosting Algo
## C5.0
set.seed(seed)
new_fit_c50 = train(credit_amount ~.,
                data = ctrain,
                method = "C5.0",
                metric = metric,
                trControl = new_control)

## Stochastic Gradient Boosting (GBM)
set.seed(seed)
new_fit_gbm = train(credit_amount ~.,
                data = ctrain,
                method = "gbm",
                metric = metric,
                trControl = new_control)

#Summary
new_boosting_results = resamples(list(new_C5.0 = new_fit_c50, new_GBM = new_fit_gbm))
summary(new_boosting_results)
dotplot(new_boosting_results)

##### Bagging Algo
## Bagged CART
set.seed(seed)
new_fit_bag = train(credit_amount ~.,
                data = ctrain,
                method = "treebag",
                metric = metric,
                trControl = new_control)

##
set.seed(seed)
new_fit_rf = train(credit_amount ~.,
               data = ctrain,
               method = "rf",
               metric = metric,
               trControl = new_control)

#Summary
new_bagging_results = resamples(list(new_BAG_CART = new_fit_bag, new_RF = new_fit_rf))
summary(new_bagging_results)
dotplot(new_bagging_results)

{
  new_pred_rf = predict(new_fit_rf, ctest)
  new_acc_rf = mean(new_pred_rf == ctest$credit_amount)*100
  
  new_pred_bag = predict(new_fit_bag, ctest)
  new_acc_bag = mean(new_pred_bag == ctest$credit_amount)*100
  
  new_pred_gbm = predict(new_fit_gbm, ctest)
  new_acc_gbm = mean(new_pred_gbm == ctest$credit_amount)*100
  
  new_pred_c50 = predict(new_fit_c50, ctest)
  new_acc_c50 = mean(new_pred_c50 == ctest$credit_amount)*100
}
# Accuracy Result on Hold-out Data
# c(new_RF = new_acc_rf, new_BAG = new_acc_bag, new_GBM = new_acc_gbm, new_C50 = new_acc_c50)
acc_res = data.frame(new_RF = new_acc_rf, new_BAG = new_acc_bag, new_GBM = new_acc_gbm, new_C50 = new_acc_c50)
write.csv(acc_res, "test_acc_res.csv", row.names = F)


## GBM Predit #######
pred_res_gbm = predict(new_fit_gbm, ca_testset[,-1])
pred_res_c50 = predict(new_fit_c50, ca_testset[,-1])
pred_res_bag = predict(new_fit_bag, ca_testset[,-1])
pred_res_rf = predict(new_fit_rf, ca_testset[,-1])

ca_testset$cluster_number_gbm = pred_res_gbm
ca_testset$cluster_number_c50 = pred_res_c50
ca_testset$cluster_number_bag = pred_res_bag
ca_testset$cluster_number_rf = pred_res_rf
names(ca_testset)
write.csv(ca_testset[, c('serial.number', 'cluster_number_gbm', 'cluster_number_c50', 'cluster_number_bag', 'cluster_number_rf')], "sample_clusters_all.csv",row.names = F)

