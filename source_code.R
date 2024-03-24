rm(list = ls())
library(data.table)
library(caret)
library(Metrics)
library(xgboost)
library(Rtsne)
#opening up libraries

test_og <- fread('./project/volume/data/interim/test.csv')
train_og <- fread('./project/volume/data/interim/train.csv')
test <- fread('./project/volume/data/interim/test_pca.csv')
train <- fread('./project/volume/data/interim/train_pca.csv')

#loading data

train_cat <- train_og$category
train_id <- train_og$id
test_id <- test_og$id

#keeping track of the original test data



dummies<- dummyVars(category ~ ., data = train)
x.train <- predict(dummies, newdata = train)
x.test <- predict(dummies, newdata = test)

# creating dummy variable

dtrain <-xgb.DMatrix(x.train,
                     label = train_cat,
                     missing = NA)

dtest <- xgb.DMatrix(x.test,
                     missing = NA)

# making the pointers

hyper_param_tune = NULL

myparam <- list(objective = "multi:softprob",
                gamma = .02,
                booster = "gbtree",
                eval_metric = "mlogloss",
                eta = .04,
                max_depth = 7,
                min_child_weight = 1,
                subsample = 1,
                colsample_bytree = 1,
                tree_method = "hist",
                num_class = 10)

XGBfit <- xgb.cv(params = myparam,
                 nfold = 7,
                 nrounds = 40000,
                 missing = NA,
                 data = dtrain,
                 print_every_n = 1,
                 early_stopping_rounds = 40)

#running the Machine Learning model



best_tree_n <- unclass(XGBfit)$best_iteration
new_row <- data.table(t(myparam))
new_row$best_tree_n <- best_tree_n
test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_mlogloss_mean

new_row$test_error <- test_error
hyper_param_tune<- rbind(new_row, hyper_param_tune)
watchlist <-list(train = dtrain)

#taking the results out

XGBfit <- xgb.train(params = myparam,
                    nrounds = best_tree_n,
                    missing = NA,
                    data = dtrain,
                    watchlist = watchlist,
                    print_every_n = 1)


pred <- predict(XGBfit, newdata = dtest)

#creating the predictions


submission <- matrix(pred, ncol = 10, byrow = T)
submission <- cbind(test_id, submission)
submission <- data.table(submission)



submission <- setnames(submission, old = c("test_id", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11"),
new = c("id", "subredditcars", "subredditCooking", "subredditMachineLearning", "subredditmagicTCG",
"subredditpolitics", "subredditReal_Estate", "subredditscience", "subredditStockMarket",
"subreddittravel", "subredditvideogames"))


#converting the data to the submission format


fwrite(submission, "./project/volume/data/processed/final.csv")

#writing up the data
















































