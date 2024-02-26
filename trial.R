value.metric <- function(truth, pred, m) {
  truth <- factor(truth, levels = c(0,1,2))
  pred <- factor(pred, levels = c(0,1,2))
  query_m <- table(truth, pred)
  # MCC, Acc, F1 and Precision
  acc <- sum(diag(query_m))/sum(query_m) # ACC
  pcs <- diag(query_m)/colSums(query_m) # precision for multi-class
  rcl <- diag(query_m)/rowSums(query_m) # recall for multi-class
  ave.pcs <- mean(pcs, na.rm = TRUE) # Macro-averaging precision
  f1 <- 2*pcs*rcl/(pcs+rcl)
  ave.f1 <- mean(f1, na.rm = TRUE) # Macro-averaging f1
  # (TP*TN – FP*FN) / √(TP+FP)(TP+FN)(TN+FP)(TN+FN)
  tp <- diag(query_m)
  fn <- rowSums(query_m) - diag(query_m)
  fp <- colSums(query_m) - diag(query_m)
  tn <- sum(query_m) - tp - fn - fp
  mcc <- (tp*tn-fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn))
  ave.mcc <- mean(mcc, na.rm = TRUE) # Macro-averaging mcc
  res <- c(ave.mcc, acc, ave.f1, ave.pcs)
  names(res) <- paste0(m, c('.MCC', '.Acc', '.F1', '.Precision'))
  return(res)
}
model.ctrl <- function(m, t, d) {
  switch (m,
    ranger = {
      model <- ranger(label ~ .,
                      data=t, classification = TRUE)
      pred <- predict(model, d[,!(names(d)=="label")])[["predictions"]]
    },
    rpart = {
      model <- rpart(t$label$V1 ~ .,
                     data=t, control=rpart.control(minsplit = 3, minbucket = 2, maxcompete = 3, maxdepth = 11),
                     method="class")
      pred <- predict(model, newdata = d, type="class")
    }
  )
  truth <- d$label$V1
  return(value.metric(truth, pred, m))
}
setwd("D:/../scHiCStackL")
df <- read.table('mouse/178/pca_cell_file.txt')
lb <- read.table('mouse/178/label.txt')

dat <- df
dat$label <- lb

# select subset of the data
foldn <- 4
set.seed(65)
idx <- sample(foldn, nrow(dat), replace = TRUE)#, prob = foldn)
#initial
require(ranger)
require(rpart)
# require(pROC)
# res_set <- c()
# res_train <- c()
# res_valid <- c()
# res_test <- c()
res.set.mg <- c()
for (i in 1:foldn) {
  j <- i+1 #2,3,4,5,6
  if(j>foldn){j <- j-foldn}
  test <- dat[idx==i,]
  valid <- dat[idx==j,]
  train <- dat[idx!=i&idx!=j,]
  # #prediction in ranger
  # model <- ranger(label ~ .,
  #                 data=train, classification = TRUE)
  # #predict in dt
  # model <- rpart(train$label$V1 ~ .,
  #                data=train, control=rpart.control(minsplit = 3, minbucket = 2, maxcompete = 3, maxdepth = 11),
  #                method="class")
  # pred_train <- predict(model, train[,!(names(train)=="label")])
  # pred_test <- predict(model, test[,!(names(test)=="label")])
  # pred_valid <- predict(model, valid[,!(names(valid)=="label")])
  
  # res.train <- value.metric(train$label$V1, pred_train[["predictions"]])
  # res.test <- value.metric(test$label$V1, pred_test[["predictions"]])
  # res.valid <- value.metric(valid$label$V1, pred_valid[["predictions"]])
  
  res.train.ranger <- model.ctrl("ranger", train, train)
  res.test.ranger <- model.ctrl("ranger", train, test)
  res.valid.ranger <- model.ctrl("ranger", train, valid)
  res.train.rpart <- model.ctrl("rpart", train, train)
  res.test.rpart <- model.ctrl("rpart", train, test)
  res.valid.rpart <- model.ctrl("rpart", train, valid)
  # cm_train <- table(truth=train$label$V1, pred=pred_train[["predictions"]])
  # cm_test <- table(truth=test$label$V1, pred=pred_test[["predictions"]])
  # cm_valid <- table(truth=valid$label$V1, pred=pred_valid[["predictions"]])
  
  
  # auc_train <- multiclass.roc(train$label$V1, pred_train[["predictions"]])
  # auc_test <- multiclass.roc(test$label$V1, pred_test[["predictions"]])
  # auc_valid <- multiclass.roc(valid$label$V1, pred_valid[["predictions"]])
  # res_train <- c(res_train, round(res.train,2))
  # res_test <- c(res_test, round(res.test,2))
  # res_valid <- c(res_valid, round(res.valid,2))
  res.set.ranger <- rbind(res.train.ranger, res.test.ranger, res.valid.ranger)
  res.set.raprt <- rbind(res.train.rpart, res.test.rpart, res.valid.rpart)
  res.set <- cbind(res.set.ranger, res.set.raprt)
  set.name <- paste0("fold.", i, c("_train","_test","_valid"))
  rownames(res.set) <- set.name
  res.set.mg <- rbind(res.set.mg, res.set)
  
}
round(res.set.mg,2)

# out_data<-data.frame(set=res_set, training=res_train, 
#                      validation=res_valid, testing=res_test, 
#                      stringsAsFactors = F)
# out_data<-rbind(out_data,c('ave.', round(mean(res_train),2), 
#                            round(mean(res_valid),2), 
#                            round(mean(res_test),2)))
# print(out_data)
# 
# #make testing performance
# pidx <- which.max(out_data$validation)
# ptrain <- dat[idx!=pidx,]
# ptest <- dat[idx==pidx,]
# model_prodc <- ranger(label ~ .,
#                       data=ptrain)
# pred_ptest <- predict(model_prodc, ptest[,!(names(ptest)=="label")])
# auc_ptest <- multiclass.roc(ptest$label$V1, pred_ptest[["predictions"]])
# print(auc_ptest)
