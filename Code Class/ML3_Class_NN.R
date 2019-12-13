rm(list = ls())
library(nnet)
library(neuralnet)
library(data.table)
library(caret)
getwd()
{
  nnc_res = read.csv("P3-Class Original Data/Yes_Bank_Test_int.csv")
  dim(nnc_res)
  sum(is.na(nnc_res))
  names(nnc_res)
  str(nnc_res)
  
  
  nnc_data = read.csv("P3-Class Original Data/Yes_Bank_Train.csv")
  dim(nnc_data)
  sum(is.na(nnc_data))
  names(nnc_data)
  str(nnc_data)
  nnc_data$serial.number = NULL
  
  
  nnc_data$credit_amount = ifelse(nnc_data$credit_amount < 1500,"3",
                                ifelse(nnc_data$credit_amount > 1500 & nnc_data$credit_amount < 4000,"2",
                                       ifelse(nnc_data$credit_amount > 4000 & nnc_data$credit_amount < 20000,"1",NA)))
  nnc_data$credit_amount = as.factor(nnc_data$credit_amount)
  #prop.table(table(ml3_ca$credit_amount))
}
names(nnc_res)[!(names(nnc_res) %in% names(nnc_data))]
names(nnc_data)[!(names(nnc_data) %in% names(nnc_res))]


########## Train and Test-set ##########
# set.seed(11102018)
# nnind = createDataPartition(nn_data$credit_amount, p = 3/4,list = F)
# nn_ctest = nn_data[-nnind,]
# prop.table(table(nn_ctest$credit_amount))



########## Data Preprocessing
#test_class = nn_ctest$credit_amount
{
  # One-Hot Encoding ---- Dependent Variable
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$credit_amount)))
  names(nnc_data)
  setnames(nnc_data, old = c("1","2","3"), new = c("credit_amount1","credit_amount2","credit_amount3"))
  nnc_data$credit_amount = NULL
  
  
  # One-Hot Encoding ---- Independent Variables
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$account_info)))
  names(nnc_data)
  setnames(nnc_data, old = c("A11","A12","A13","A14"), new = c("account_infoA11","account_infoA12",
                                                               "account_infoA13","account_infoA14"))
  nnc_data$account_info = NULL
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$credit_history)))
  names(nnc_data)
  setnames(nnc_data, old = c("A30","A31","A32","A33","A34"), 
           new = c("credit_historyA30","credit_historyA31", "credit_historyA32",
                   "credit_historyA33","credit_historyA34"))
  
  nnc_data$credit_history = NULL
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$purpose)))
  names(nnc_data)
  setnames(nnc_data, old = c("A40","A41","A410","A42","A43","A44","A45","A46","A48","A49"), 
           new = c("purposeA40","purposeA41", "purposeA410","purposeA42","purposeA43",
                   "purposeA44","purposeA45","purposeA46","purposeA48","purposeA49"))
  
  nnc_data$purpose = NULL
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$savings_account)))
  names(nnc_data)
  setnames(nnc_data, old = c("A61","A62","A63","A64","A65"), 
           new = c("savings_accountA61","savings_accountA62", 
                   "savings_accountA63",
                   "savings_accountA64","savings_accountA65"))
  
  nnc_data$savings_account = NULL
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$employment_st)))
  names(nnc_data)
  setnames(nnc_data, old = c("A71","A72","A73","A74","A75"), 
           new = c("employment_stA71","employment_stA72", 
                   "employment_stA73",
                   "employment_stA74","employment_stA75"))
  
  nnc_data$employment_st = NULL
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$personal_status)))
  names(nnc_data)
  setnames(nnc_data, old = c("A91","A92","A93","A94"), 
           new = c("personal_statusA91","personal_statusA92", 
                   "personal_statusA93",
                   "personal_statusA94"))
  
  nnc_data$personal_status = NULL
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$gurantors)))
  names(nnc_data)
  setnames(nnc_data, old = c("A101","A102","A103"), 
           new = c("gurantorsA101","gurantorsA102","gurantorsA103"))
  
  nnc_data$gurantors = NULL
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$property_type)))
  names(nnc_data)
  setnames(nnc_data, old = c("A121","A122","A123","A124"), 
           new = c("property_typeA121","property_typeA122", 
                   "property_typeA123",
                   "property_typeA124"))
  
  nnc_data$property_type = NULL
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$installment_type)))
  names(nnc_data)
  setnames(nnc_data, old = c("A141","A142","A143"), 
           new = c("installment_typeA141","installment_typeA142", 
                   "installment_typeA143"))
  
  nnc_data$installment_type = NULL
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$housing_type)))
  names(nnc_data)
  setnames(nnc_data, old = c("A151","A152","A153"), 
           new = c("housing_typeA151","housing_typeA152", 
                   "housing_typeA153"))
  
  nnc_data$housing_type = NULL
  
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$job_type)))
  names(nnc_data)
  setnames(nnc_data, old = c("A171","A172","A173","A174"), 
           new = c("job_typeA171","job_typeA172", "job_typeA173",
                   "job_typeA174"))
  
  nnc_data$job_type = NULL
  
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$telephone)))
  names(nnc_data)
  setnames(nnc_data, old = c("A191","A192"), 
           new = c("telephoneA191","telephoneA192"))
  
  nnc_data$telephone = NULL
  
  
  nnc_data = cbind(nnc_data, class.ind(as.factor(nnc_data$foreigner)))
  names(nnc_data)
  setnames(nnc_data, old = c("A201","A202"), 
           new = c("foreignerA201","foreignerA202"))
  
  nnc_data$foreigner = NULL
}

#ifelse(sapply(nnc_data, class) == "integer",sapply(nnc_data, class),NA)
# names(nnc_data)
# str(nnc_data)
# Factors
# c("account_info","credit_history", "purpose",
#   "savings_account","employment_st","personal_status",
#   "gurantors","property_type","installment_type",
#   "housing_type","job_type","telephone","foreigner")

########## Train and Test-set ##########
set.seed(11102018)
nnind = createDataPartition(nnc_data$credit_amount1, p = 3/4,list = F)
nn_ctrain = nnc_data[nnind,]
nn_ctest = nnc_data[-nnind,]

##### Model DevelopMent ##########
set.seed(11102018)
nX = names(nn_ctrain)
nY = c("credit_amount1", "credit_amount2", "credit_amount3")
f = as.formula(paste("credit_amount1 + credit_amount2 + credit_amount3 ~", 
                     paste(nX[!nX %in% nY], collapse = " + ")))
model_nn = neuralnet(f, data = nn_ctrain,
                     linear.output=F,
                     act.fct="logistic",
                     hidden=c(2,5),
                     stepmax=1e+08)

## plot(model_nn)

#### Prediction (Processing) ###########
{
  test = nn_ctest[,nX[!nX %in% nY]]
  Ytest = nn_ctest[,nY]
  nnc_compute = compute(model_nn, test)
  #View(nnc_compute)
  nnc_pred = round(nnc_compute$net.result)
  #nnc_pred
  
  nnc_pred = as.data.frame(nnc_pred)
  names(nnc_pred)
  setnames(nnc_pred, old = c("V1","V2","V3"),
           new = c("credit_amount1","credit_amount2","credit_amount3"))
  
  
  #View(nnc_pred)
  nnc_pred$res = ifelse(nnc_pred$credit_amount1 == 0 & 
                          nnc_pred$credit_amount2 == 0 &
                          nnc_pred$credit_amount3 == 0, 1,
                        ifelse(nnc_pred$credit_amount1 == 0 & 
                                 nnc_pred$credit_amount2 == 1 &
                                 nnc_pred$credit_amount3 == 0, 2,
                               ifelse(nnc_pred$credit_amount1 == 0 & 
                                        nnc_pred$credit_amount2 == 0 &
                                        nnc_pred$credit_amount3 == 1, 3,NA)))
  
  Ytest$res = ifelse(Ytest$credit_amount1 == 1 &
                       Ytest$credit_amount2 == 0 &
                       Ytest$credit_amount3 == 0, 1,
                     ifelse(Ytest$credit_amount1 == 0 &
                              Ytest$credit_amount2 == 1 &
                              Ytest$credit_amount3 == 0, 2,
                            ifelse(Ytest$credit_amount1 == 0 &
                                     Ytest$credit_amount2 == 0 &
                                     Ytest$credit_amount3 == 1, 3,NA)))
  
}
tab = table(Ytest$res, nnc_pred$res)
sum(diag(tab)/sum(tab))

########################################
# RES One-Hot Encoding ---- Independent Variables
{
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$account_info)))
  names(nnc_res)
  setnames(nnc_res, old = c("A11","A12","A13","A14"), 
           new = c("account_infoA11","account_infoA12",
                                                               "account_infoA13","account_infoA14"))
  nnc_res$account_info = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$credit_history)))
  names(nnc_res)
  setnames(nnc_res, old = c("A30","A31","A32","A33","A34"), 
           new = c("credit_historyA30","credit_historyA31", "credit_historyA32",
                   "credit_historyA33","credit_historyA34"))
  
  nnc_res$credit_history = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$purpose)))
  names(nnc_res)
  setnames(nnc_res, old = c("A40","A41","A410","A42","A43","A44","A45","A46","A48","A49"), 
           new = c("purposeA40","purposeA41", "purposeA410","purposeA42","purposeA43",
                   "purposeA44","purposeA45","purposeA46","purposeA48","purposeA49"))
  
  nnc_res$purpose = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$savings_account)))
  names(nnc_res)
  setnames(nnc_res, old = c("A61","A62","A63","A64","A65"), 
           new = c("savings_accountA61","savings_accountA62", 
                   "savings_accountA63",
                   "savings_accountA64","savings_accountA65"))
  
  nnc_res$savings_account = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$employment_st)))
  names(nnc_res)
  setnames(nnc_res, old = c("A71","A72","A73","A74","A75"), 
           new = c("employment_stA71","employment_stA72", 
                   "employment_stA73",
                   "employment_stA74","employment_stA75"))
  
  nnc_res$employment_st = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$personal_status)))
  names(nnc_res)
  setnames(nnc_res, old = c("A91","A92","A93","A94"), 
           new = c("personal_statusA91","personal_statusA92", 
                   "personal_statusA93",
                   "personal_statusA94"))
  
  nnc_res$personal_status = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$gurantors)))
  names(nnc_res)
  setnames(nnc_res, old = c("A101","A102","A103"), 
           new = c("gurantorsA101","gurantorsA102","gurantorsA103"))
  
  nnc_res$gurantors = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$property_type)))
  names(nnc_res)
  setnames(nnc_res, old = c("A121","A122","A123","A124"), 
           new = c("property_typeA121","property_typeA122", 
                   "property_typeA123",
                   "property_typeA124"))
  
  nnc_res$property_type = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$installment_type)))
  names(nnc_res)
  setnames(nnc_res, old = c("A141","A142","A143"), 
           new = c("installment_typeA141","installment_typeA142", 
                   "installment_typeA143"))
  
  nnc_res$installment_type = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$housing_type)))
  names(nnc_res)
  setnames(nnc_res, old = c("A151","A152","A153"), 
           new = c("housing_typeA151","housing_typeA152", 
                   "housing_typeA153"))
  
  nnc_res$housing_type = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$job_type)))
  names(nnc_res)
  setnames(nnc_res, old = c("A171","A172","A173","A174"), 
           new = c("job_typeA171","job_typeA172", "job_typeA173",
                   "job_typeA174"))
  
  nnc_res$job_type = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$telephone)))
  names(nnc_res)
  setnames(nnc_res, old = c("A191","A192"), 
           new = c("telephoneA191","telephoneA192"))
  
  nnc_res$telephone = NULL
  
  nnc_res = cbind(nnc_res, class.ind(as.factor(nnc_res$foreigner)))
  names(nnc_res)
  setnames(nnc_res, old = c("A201","A202"), 
           new = c("foreignerA201","foreignerA202"))
  
  nnc_res$foreigner = NULL
}
