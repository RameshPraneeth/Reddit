rm(list = ls())
#clearing the global environment
source('./project/src/features/feature1.R')
# running the first feature to build the master table
source('./project/src/features/pca.R')
# Doing the pca
source('./project/src/models/source_code.R')
# Running the xgb model
