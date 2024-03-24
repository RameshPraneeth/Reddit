rm(list = ls())
library(data.table)

#loading the libraries

train_data <- fread("./project/volume/data/raw/train_data.csv")
train_copy <- fread("./project/volume/data/raw/train_data.csv")
emb <- fread("./project/volume/data/raw/train_emb.csv")
test <- fread("./project/volume/data/raw/test_file.csv")
test_emb <- fread("./project/volume/data/raw/test_emb.csv")
# loading in the data


train_data$text <- NULL
#getting rid of the text since we have the embedding

melt <- melt(train_data, id = c("id"), variable.name = 'category')
melt <- melt[value == 1]
melt <- melt[,.(id, category)]
melt$category <- as.numeric(melt$category)

#melting down the data


order <- match(train_copy$id, melt$id)
melt$id <- melt$id[order]
melt$category <-melt$category[order]
melt$category<- melt$category-1

#making the new data table match the original 

train_data <- setcolorder(melt, c('id', "category"))
train_data <- cbind(train_data, emb)
test$text <- NULL
test <- cbind(test, test_emb)
train <- train_data

# reordering the columns and binding the data

fwrite(train, "./project/volume/data/interim/train.csv")
fwrite(test, "./project/volume/data/interim/test.csv")

#writing up the data




