rm(list = ls())
library(data.table)

#opening library

test <- fread('./project/volume/data/interim/test.csv')
train <- fread('./project/volume/data/interim/train.csv')

#loading data

train_cat <- train$category
train_id <- train$id
test_id <- test$id
train$id <- NULL
test$id <- NULL

train$category <- NULL
# putting the data in a format where we can begin to do pca on it

master_table <- rbind(test, train)
# making a master table
pca_view <- prcomp(master_table)
pca <- data.table(unclass(pca_view)$x)
pca <- pca[,1:97]
# applying dimension reduction
test <- head(pca, 20555)
train <- pca[20556:20755, ]
# remaking the new test and training data

train$category <- train_cat
test$category <- 0















# master_table <- rbind(test, train)
# pca_view <- prcomp(master_table)
# pca <- data.table(unclass(pca_view)$x)
# pca <- pca[,1:95]
# test <- head(pca, 20555)
# train <- pca[20556:20755, ]


fwrite(test, './project/volume/data/interim/test_pca.csv')
fwrite(train, './project/volume/data/interim/train_pca.csv')
