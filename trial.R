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
      require(ranger)
      model <- ranger(label ~ .,
                      data=t, classification = TRUE)
      pred <- predict(model, d[,!(names(d)=="label")])[["predictions"]]
    },
    rpart = {
      require(rpart)
      model <- rpart(t$label$V1 ~ .,
                     data=t, control=rpart.control(minsplit = 3, minbucket = 2, maxcompete = 3, maxdepth = 11),
                     method="class")
      pred <- predict(model, newdata = d, type="class")
    },
    glm = {
      require(glmnet)
      num.t <- sapply(t, unlist)
      num.d <- sapply(d, unlist)
      model <- glmnet(num.t[, 1:50], num.t[, 51], family = "multinomial")
      pred <- predict(model, newx = num.d[, 1:50], type = "class")[, which.min(model$lambda)]
    }
  )
  truth <- d$label$V1
  return(value.metric(truth, pred, m))
}
setwd("D:/../scHiCStackL")
df <- read.table('human/2655/pca_cell_file.txt')
lb <- read.table('human/2655/label.txt')

dat <- df
dat$label <- lb

# select subset of the data
foldn <- 18
# set.seed(65)
idx <- sample(foldn, nrow(dat), replace = TRUE)#, prob = foldn)

res.set.mg <- c()
t <- Sys.time()
for (i in 1:foldn) {
  j <- i+1 #2,3,4,5,6
  if(j>foldn){j <- j-foldn}
  test <- dat[idx==i,]
  valid <- dat[idx==j,]
  train <- dat[idx!=i&idx!=j,]
  
  res.train.ranger <- model.ctrl("ranger", train, train)
  res.test.ranger <- model.ctrl("ranger", train, test)
  res.valid.ranger <- model.ctrl("ranger", train, valid)
  res.train.rpart <- model.ctrl("rpart", train, train)
  res.test.rpart <- model.ctrl("rpart", train, test)
  res.valid.rpart <- model.ctrl("rpart", train, valid)
  res.train.glm <- model.ctrl("glm", train, train)
  res.test.glm <- model.ctrl("glm", train, test)
  res.valid.glm <- model.ctrl("glm", train, valid)
  
  res.set.ranger <- rbind(res.train.ranger, res.test.ranger, res.valid.ranger)
  res.set.raprt <- rbind(res.train.rpart, res.test.rpart, res.valid.rpart)
  res.set.glm <- rbind(res.train.glm, res.test.glm, res.valid.glm)
  res.set <- cbind(res.set.ranger, res.set.raprt, res.set.glm)
  set.name <- paste0("fold.", i, c("_train","_test","_valid"))
  rownames(res.set) <- set.name
  res.set.mg <- rbind(res.set.mg, res.set)
  print(difftime(Sys.time(), t))
}

res.data <- data.frame(round(res.set.mg, 6))
res.data[which(res.data$glm.MCC != 1),]
which.max(res.data[which(res.data$ranger.MCC != 1),"rpart.MCC"])
res.data.dof <- res.data[which(res.data$ranger.MCC != 1),]
t(head(res.data.dof[order(res.data.dof[,"ranger.MCC"], decreasing = TRUE),],5))

out.data <- cbind(round=rownames(res.data), res.data)
write.table(out.data, file = paste0("human2655_res_10fold.csv"), 
            sep = ",", quote = FALSE, row.names = FALSE)
