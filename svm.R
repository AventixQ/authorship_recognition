library("readr")
library(e1071)
library(LiblineaR)
library(caret)

#4 sets of data
#1000 features from tf/wtf/rtf

#train data 200
train_data200.tf <- read_csv("4.merge_all_data/merge/merge_data_200.train_tf.csv", col_types = cols(.default = "d"))
train_data200.rtf <- read_csv("4.merge_all_data/merge/merge_data_200.train_rtf.csv", col_types = cols(.default = "d"))
train_data200.wtf <- read_csv("4.merge_all_data/merge/merge_data_200.train_wtf.csv", col_types = cols(.default = "d"))

#train data 1000
train_data1000.tf <- read_csv("4.merge_all_data/merge/merge_data_1000.train_tf.csv", col_types = cols(.default = "d"))
train_data1000.rtf <- read_csv("4.merge_all_data/merge/merge_data_1000.train_rtf.csv", col_types = cols(.default = "d"))
train_data1000.wtf <- read_csv("4.merge_all_data/merge/merge_data_1000.train_wtf.csv", col_types = cols(.default = "d"))

#develop data 200
devel_data200.tf <- read_csv("4.merge_all_data/merge/merge_data_200.devel_tf.csv", col_types = cols(.default = "d"))
devel_data200.rtf <- read_csv("4.merge_all_data/merge/merge_data_200.devel_rtf.csv", col_types = cols(.default = "d"))
devel_data200.wtf <- read_csv("4.merge_all_data/merge/merge_data_200.devel_wtf.csv", col_types = cols(.default = "d"))

#develop data 1000
devel_data1000.tf <- read_csv("4.merge_all_data/merge/merge_data_1000.devel_tf.csv", col_types = cols(.default = "d"))
devel_data1000.rtf <- read_csv("4.merge_all_data/merge/merge_data_1000.devel_rtf.csv", col_types = cols(.default = "d"))
devel_data1000.wtf <- read_csv("4.merge_all_data/merge/merge_data_1000.devel_wtf.csv", col_types = cols(.default = "d"))

#SVM only for length of sentence
len_train_1000.tf <- data.frame(author = train_data1000.tf$author, aveg_len_sen = train_data1000.tf$aveg_len_sen)
len_devel_1000.tf <- data.frame(author = devel_data1000.tf$author, aveg_len_sen = devel_data1000.tf$aveg_len_sen)
len_train_200.tf <- data.frame(author = train_data200.tf$author, aveg_len_sen = train_data200.tf$aveg_len_sen)
len_devel_200.tf <- data.frame(author = devel_data200.tf$author, aveg_len_sen = devel_data200.tf$aveg_len_sen)

train_and_evaluate <- function(train, develop, n){
  c <- LiblineaR(data=train[2:n],
                 target=train$author, type=2, findC = TRUE)
  model <- LiblineaR(data=train[2:n],
                     target=train$author, type=2, cost=c)
  predictions=predict(model,develop[2:n])
  
  actual_values <- develop$author
  actual_values <- factor(develop$author, levels = 1:6)
  predictions <- factor(predictions[[1]], levels = 1:6)
  matrix <- confusionMatrix(predictions, actual_values)
  matrix <- as.matrix(matrix)
  #print(matrix)
  
  accuracy <- sum(diag(matrix)) / sum(matrix)
  precision <- diag(matrix) / colSums(matrix)
  recall <- diag(matrix) / rowSums(matrix)
  f1 <- 2 * (precision * recall) / (precision + recall)
  recall[is.nan(recall)] <- 0
  f1[is.nan(f1)] <- 0
  
  cat("Accuracy: ", round(accuracy,4), "\n")
  #cat("Precision: ", precision, "\n")
  #cat("Recall: ", recall, "\n")
  #cat("F1 Measure: ", f1, "\n")
  
  #macro-averaged
  macro_precision <- mean(precision)
  macro_recall <- mean(recall)
  macro_f1 <- mean(f1)
  
  cat("Macro-Averaged Precision: ", round(macro_precision,4), "\n")
  cat("Macro-Averaged Recall: ", round(macro_recall,4), "\n")
  cat("Macro-Averaged F1 Measure: ", round(macro_f1,4), "\n")
}

#train: 1000, devel: 1000
train_and_evaluate(len_train_1000.tf, len_devel_1000.tf,2)
#train: 1000, devel: 200
train_and_evaluate(len_train_1000.tf, len_devel_200.tf,2)
#train: 200, devel: 1000
train_and_evaluate(len_train_200.tf, len_devel_1000.tf,2)
#train: 200, devel: 200
train_and_evaluate(len_train_200.tf, len_devel_200.tf,2)

#How many features? Data creator
data_creator <- function(train_1000, train_200, devel_1000, devel_200, features){
  train_1000 <- data.frame(author = train_1000$author, train_1000[5:(5 + features - 1)])
  devel_1000 <- data.frame(author = devel_1000$author, devel_1000[5:(5 + features - 1)])
  train_200 <- data.frame(author = train_200$author, train_200[5:(5 + features - 1)])
  devel_200 <- data.frame(author = devel_200$author, devel_200[5:(5 + features - 1)])
  return(list(train_1000, train_200, devel_1000, devel_200))
}

f.1000.tf <- data_creator(train_data1000.tf, train_data200.tf, devel_data1000.tf, devel_data200.tf, 1000)
#train: 1000, devel: 1000
train_and_evaluate(f.1000.tf[[1]], f.1000.tf[[3]], 1000)
#train: 1000, devel: 200
train_and_evaluate(f.1000.tf[[1]], f.1000.tf[[4]], 1000)
#train: 200, devel: 1000
train_and_evaluate(f.1000.tf[[2]], f.1000.tf[[3]], 1000)
#train: 200, devel: 200
train_and_evaluate(f.1000.tf[[2]], f.1000.tf[[4]], 1000)

f.1000.rtf <- data_creator(train_data1000.rtf, train_data200.rtf, devel_data1000.rtf, devel_data200.rtf, 1000)
#train: 1000, devel: 1000
train_and_evaluate(f.1000.rtf[[1]], f.1000.rtf[[3]], 1000)
#train: 1000, devel: 200
train_and_evaluate(f.1000.rtf[[1]], f.1000.rtf[[4]], 1000)
#train: 200, devel: 1000
train_and_evaluate(f.1000.rtf[[2]], f.1000.rtf[[3]], 1000)
#train: 200, devel: 200
train_and_evaluate(f.1000.rtf[[2]], f.1000.rtf[[4]], 1000)

f.1000.wtf <- data_creator(train_data1000.wtf, train_data200.wtf, devel_data1000.wtf, devel_data200.wtf, 1000)
#train: 1000, devel: 1000
train_and_evaluate(f.1000.wtf[[1]], f.1000.wtf[[3]], 1000)
#train: 1000, devel: 200
train_and_evaluate(f.1000.wtf[[1]], f.1000.wtf[[4]], 1000)
#train: 200, devel: 1000
train_and_evaluate(f.1000.wtf[[2]], f.1000.wtf[[3]], 1000)
#train: 200, devel: 200
train_and_evaluate(f.1000.wtf[[2]], f.1000.wtf[[4]], 1000)

f.500.tf <- data_creator(train_data1000.tf, train_data200.tf, devel_data1000.tf, devel_data200.tf, 500)
#train: 1000, devel: 1000
train_and_evaluate(f.500.tf[[1]], f.500.tf[[3]], 500)
#train: 1000, devel: 200
train_and_evaluate(f.500.tf[[1]], f.500.tf[[4]], 500)
#train: 200, devel: 1000
train_and_evaluate(f.500.tf[[2]], f.500.tf[[3]], 500)
#train: 200, devel: 200
train_and_evaluate(f.500.tf[[2]], f.500.tf[[4]], 500)

f.500.rtf <- data_creator(train_data1000.rtf, train_data200.rtf, devel_data1000.rtf, devel_data200.rtf, 500)
#train: 1000, devel: 1000
train_and_evaluate(f.500.rtf[[1]], f.500.rtf[[3]], 500)
#train: 1000, devel: 200
train_and_evaluate(f.500.rtf[[1]], f.500.rtf[[4]], 500)
#train: 200, devel: 1000
train_and_evaluate(f.500.rtf[[2]], f.500.rtf[[3]], 500)
#train: 200, devel: 200
train_and_evaluate(f.500.rtf[[2]], f.500.rtf[[4]], 500)

f.500.wtf <- data_creator(train_data1000.wtf, train_data200.wtf, devel_data1000.wtf, devel_data200.wtf, 500)
#train: 1000, devel: 1000
train_and_evaluate(f.500.wtf[[1]], f.500.wtf[[3]], 500)
#train: 1000, devel: 200
train_and_evaluate(f.500.wtf[[1]], f.500.wtf[[4]], 500)
#train: 200, devel: 1000
train_and_evaluate(f.500.wtf[[2]], f.500.wtf[[3]], 500)
#train: 200, devel: 200
train_and_evaluate(f.500.wtf[[2]], f.500.wtf[[4]], 500)

f.200.tf <- data_creator(train_data1000.tf, train_data200.tf, devel_data1000.tf, devel_data200.tf, 200)
#train: 1000, devel: 1000
train_and_evaluate(f.200.tf[[1]], f.200.tf[[3]], 200)
#train: 1000, devel: 200
train_and_evaluate(f.200.tf[[1]], f.200.tf[[4]], 200)
#train: 200, devel: 1000
train_and_evaluate(f.200.tf[[2]], f.200.tf[[3]], 200)
#train: 200, devel: 200
train_and_evaluate(f.200.tf[[2]], f.200.tf[[4]], 200)

f.200.rtf <- data_creator(train_data1000.rtf, train_data200.rtf, devel_data1000.rtf, devel_data200.rtf, 200)
#train: 1000, devel: 1000
train_and_evaluate(f.200.rtf[[1]], f.200.rtf[[3]], 200)
#train: 1000, devel: 200
train_and_evaluate(f.200.rtf[[1]], f.200.rtf[[4]], 200)
#train: 200, devel: 1000
train_and_evaluate(f.200.rtf[[2]], f.200.rtf[[3]], 200)
#train: 200, devel: 200
train_and_evaluate(f.200.rtf[[2]], f.200.rtf[[4]], 200)

f.200.wtf <- data_creator(train_data1000.wtf, train_data200.wtf, devel_data1000.wtf, devel_data200.wtf, 200)
#train: 1000, devel: 1000
train_and_evaluate(f.200.wtf[[1]], f.200.wtf[[3]], 200)
#train: 1000, devel: 200
train_and_evaluate(f.200.wtf[[1]], f.200.wtf[[4]], 200)
#train: 200, devel: 1000
train_and_evaluate(f.200.wtf[[2]], f.200.wtf[[3]], 200)
#train: 200, devel: 200
train_and_evaluate(f.200.wtf[[2]], f.200.wtf[[4]], 200)

#BEST MODEL (in theory)
train.best.200 <- cbind(f.500.rtf[[2]], f.500.tf[[2]][2:501],f.500.wtf[[2]][2:501])
train.best.1000 <- cbind(f.500.rtf[[1]], f.500.tf[[1]][2:501],f.500.wtf[[1]][2:501])
devel.best.200 <- cbind(f.500.rtf[[4]], f.500.tf[[4]][2:501],f.500.wtf[[4]][2:501])
devel.best.1000 <- cbind(f.500.rtf[[3]], f.500.tf[[3]][2:501],f.500.wtf[[3]][2:501])

#train: 1000, devel: 1000
train_and_evaluate(train.best.1000, devel.best.1000, 1500)
#train: 1000, devel: 200
train_and_evaluate(train.best.1000,devel.best.200, 1500)
#train: 200, devel: 1000
train_and_evaluate(train.best.200, devel.best.1000, 1500)
#train: 200, devel: 200
train_and_evaluate(train.best.200, devel.best.200, 1500)