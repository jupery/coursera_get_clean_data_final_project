## This script loads the data from the experiments and merge them as a single data set (steps 1 to 4 below).
## It then extract the data of mean values and standard deviations (steps 5 and 6) and 
## create another data set that that summarises these two measures by subject and activity (step 7).  
##

## 0. Loading dplyr to later use it for creating a summarised data
library(dplyr)


## 1. Load feature names (i.e. measures in the experiments) from the original data to later use them for the columns
features<-read.table("./UCI HAR Dataset/features.txt",col.names = c("number","features"),colClasses = "character",sep=" ")

# Replace special characters such as '(' with '_'. 
feature_col_names<-sub("\\(","_",features[,2])
feature_col_names<-sub("\\)","_",feature_col_names)
feature_col_names<-sub("\\-","_",feature_col_names)


## 2. Load the test data (subject, activity, and measures). Combine them as a single dataframe. They should all have the same number of records.
test_subject<-read.table("./UCI HAR Dataset/test/subject_test.txt",col.names = "subject",colClasses = "factor")
test_activity<-read.table("./UCI HAR Dataset/test/y_test.txt",col.names = "activity",colClasses = "factor")
test_measures<-read.table("./UCI HAR Dataset/test/X_test.txt",col.names = feature_col_names,colClasses = "numeric") # Use features as column names. 
test_data<-cbind(test_subject,test_activity,test_measures)


## 3. Similarly, Load the train data (subject, activity, and measures) and combine. They all have the same number of records.
train_activity<-read.table("./UCI HAR Dataset/train/y_train.txt",col.names = "activity",colClasses = "factor")
train_subject<-read.table("./UCI HAR Dataset/train/subject_train.txt",col.names = "subject",colClasses = "factor")
train_measures<-read.table("./UCI HAR Dataset/train/X_train.txt",col.names = feature_col_names,colClasses = "numeric")  # Use features as column names.
train_data<-cbind(train_subject,train_activity,train_measures)


## 4. Combine the test data and train data.
full_har_data<-rbind(test_data,train_data)


## 5. From the full data set, extract the columns that represent mean value and standard deviation.

## Use this to check the number of columns in target.
## table(grepl("mean\\_",colnames(full_har_data)) | grepl("std\\_",colnames(full_har_data)))

# Locate the mean and stndard deviation columns and subset from the full data set.
mean_std_columns<-sort(c(grep("mean\\_",colnames(full_har_data)),grep("std\\_",colnames(full_har_data))))
har_mean_std_data<-full_har_data[,c(1,2,mean_std_columns)]


## 6. Add append activity names to the mean and standard deviation data set
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt",col.names = c("number","activity_label"),colClasses = c("factor","character"))
har_mean_std_merged<-merge(har_mean_std_data,activity_labels,by.x="activity",by.y="number")
har_mean_std_merged<-har_mean_std_merged[order(har_mean_std_merged$activity,har_mean_std_merged$subject),]


## 7. Create another file that summarise the mean and stadard deviation data set by subject and activity.
har_summarised_by_sub_act<-har_mean_std_merged %>% group_by(subject,activity_label) %>% summarise_at(.vars = 2:67,.funs = c(mean="mean"))


## 8. Export the two data sets as txt files.
write.table(har_mean_std_merged,"har_merged.txt",row.names = FALSE,col.names=TRUE)
write.table(har_summarised_by_sub_act,"har_summary.txt",row.names = FALSE,col.names=TRUE)
