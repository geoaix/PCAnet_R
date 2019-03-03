#######################################
###         NML homework 5          ###
###          calculPCA.r            ###
###           Ian, Fan              ###
###          2019.02.25             ###
#######################################

## clear variables and set work directory
# rm(list = ls())
# setwd("/Users/rcusf/Desktop/NMLh5")


# source
source('loadData.r')
source('initWeights.r')


sd = 1024
set.seed(sd)
########################################

## parameters
# PCA dim
PCA_dim = 4
# weight range
weight_range = c(-0.5, 0.5)
# learning rate
eta = 0.01
# error tolerance
error_toleranc = 0.0000001



## get target data
data_feature_num = 4
data = trainData[,c(1:data_feature_num)]
row_num = nrow(trainData)



## data preprocess
data_mean = apply(data, 2, mean)
zero_mean_data = t( t(data) - data_mean )
# check
# data_mean2 = apply(zero_mean_data, 2, mean)



## get weights
# initWeights(input_size, output_size, range, bias_flag = TRUE)
eigen_weights = initWeights(data_feature_num, PCA_dim, weight_range, bias_flag = FALSE)



## PCA
# original data 
origData = t(zero_mean_data)

# record error
error = data.frame(repairError = c()) 
iter_num = 20000
# updating weights
for (i in c(1:iter_num)) {
  
  ## calculate error
  # get projections
  projectData = eigen_weights %*% origData
  # get repair
  repairData = t(eigen_weights) %*% projectData
  # get data error
  data_error = origData - repairData
  # get eigen error
  eigen_diff = t(eigen_weights) %*% eigen_weights - diag(nrow = data_feature_num)
  eigen_error = sum(eigen_diff^2)
  error = rbind(error, eigen_error)
  
  
  ## upadate weights
  # Oja’s Symmetric Subspace Algorithm
  # delta_weight = eta * projectData %*% t(data_error)
  
  # Sanger’s Generalized Hebbian Algorith
  symmetric_projectData = projectData %*% t(projectData)
  triangle_projectData = symmetric_projectData * !upper.tri(symmetric_projectData)
  delta_weight = eta * projectData %*% t(origData) - eta * triangle_projectData %*% eigen_weights
  # update
  eigen_weights = eigen_weights + delta_weight
  
  
  ## get current error
  if (i %% 100 == 0){
    print(eigen_error)
  }
  
  
  ## early stopping
  if (eigen_error < error_toleranc){
    # record present info.
    stop_iter = i
    print(paste0("Stop at iteration ", i))
    break
  }
  
  
  ## iter update
  i = i + 1
  
}


# print eigen_weights, i.e. eigen_vectors generated by PCA NN
t(-eigen_weights)
  
  
  

