metric.value <- function(query_m) {
  # MCC, Acc, F1 and Precision
  acc <- sum(diag(query_m))/sum(query_m) # ACC
  pcs <- diag(query_m)/colSums(query_m) # precision for multi-class
  rcl <- diag(query_m)/rowSums(query_m) # recall for multi-class
  ave.pcs <- mean(pcs) # Macro-averaging precision
  f1 <- 2*pcs*rcl/(pcs+rcl)
  ave.f1 <- mean(f1) # Macro-averaging f1
  # (TP*TN – FP*FN) / √(TP+FP)(TP+FN)(TN+FP)(TN+FN)
  tp <- diag(query_m)
  fn <- rowSums(query_m) - diag(query_m)
  fp <- colSums(query_m) - diag(query_m)
  tn <- sum(query_m) - tp - fn - fp
  mcc <- (tp*tn-fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn))
  ave.mcc <- mean(mcc) # Macro-averaging mcc
  c(ave.mcc, acc, ave.f1, ave.pcs)
}
setwd("D:/../scHiCStackL")
df <- read.table('mouse/178/pca_cell_file.txt')
lb <- read.table('mouse/178/label.txt')

dat <- df
dat$label <- lb

# select subset of the data
foldn <- 9
set.seed(65)
idx <- sample(foldn, nrow(dat), replace = TRUE)#, prob = foldn)
#initial
require(ranger)
require(pROC)
res_set <- c()
res_train <- c()
res_valid <- c()
res_test <- c()
res_auc <- c()
for (i in 1:foldn) {
  j <- i+1 #2,3,4,5,6
  if(j>foldn){j <- j-foldn}
  test <- dat[idx==i,]
  valid <- dat[idx==j,]
  train <- dat[idx!=i&idx!=j,]
  #prediction in ranger
  model <- ranger(label ~ .,
                  data=train)
  pred_train <- predict(model, train[,!(names(train)=="label")])
  pred_test <- predict(model, test[,!(names(test)=="label")])
  pred_valid <- predict(model, valid[,!(names(valid)=="label")])
  
  #handle confusion matrix and logLikelihood
  cm <- c(cm.make(query_m, d$reference, d$pred.score, thrsd))
  tp_d <- cm[1]
  tn_d <- cm[2]
  fn_d <- cm[3]
  fp_d <- cm[4]
  snsty <- tp_d/(tp_d+fn_d)
  spcty <- tn_d/(tn_d+fp_d)
  pcsn <- tp_d/(tp_d+fp_d)
  f1 <- (2*snsty*pcsn)/(snsty+pcsn)
  lglkhd <- cm[5]
  nlglkhd <- sum(log(ifelse(d$reference == query_m, (tp_d+fn_d)/dim(d)[[1]], (tn_d+fp_d)/dim(d)[[1]])))
  psudR2 <- 1-(-2*lglkhd)/(-2*nlglkhd)
  cm_train <- table(truth=train$label$V1, pred=pred_train[["predictions"]])
  cm_test <- table(truth=test$label$V1, pred=pred_test[["predictions"]])
  cm_valid <- table(truth=valid$label$V1, pred=pred_valid[["predictions"]])
  
  
  auc_train <- multiclass.roc(train$label$V1, pred_train[["predictions"]])
  auc_test <- multiclass.roc(test$label$V1, pred_test[["predictions"]])
  auc_valid <- multiclass.roc(valid$label$V1, pred_valid[["predictions"]])
  res_train <- c(res_train, round(auc_train$auc,2))
  res_test <- c(res_test, round(auc_test$auc,2))
  res_valid <- c(res_valid, round(auc_valid$auc,2))
  res_set <- c(res_set, paste0("fold",i))
}


out_data<-data.frame(set=res_set, training=res_train, 
                     validation=res_valid, testing=res_test, 
                     stringsAsFactors = F)
out_data<-rbind(out_data,c('ave.', round(mean(res_train),2), 
                           round(mean(res_valid),2), 
                           round(mean(res_test),2)))
print(out_data)

#make testing performance
pidx <- which.max(out_data$validation)
ptrain <- dat[idx!=pidx,]
ptest <- dat[idx==pidx,]
model_prodc <- ranger(label ~ .,
                      data=ptrain)
pred_ptest <- predict(model_prodc, ptest[,!(names(ptest)=="label")])
auc_ptest <- multiclass.roc(ptest$label$V1, pred_ptest[["predictions"]])
print(auc_ptest)
