library(dplyr)

##Preparation by loading data into workspace
  features<-read.table(".\\UCI HAR Dataset\\features.txt")
  activities<-read.table(".\\UCI HAR Dataset\\activity_labels.txt")
  x_train<-read.table(".\\UCI HAR Dataset\\train\\x_train.txt")
  y_train<-read.table(".\\UCI HAR Dataset\\train\\y_train.txt")
  subject_train<-read.table(".\\UCI HAR Dataset\\train\\subject_train.txt")
  x_test<-read.table(".\\UCI HAR Dataset\\test\\x_test.txt")  
  y_test<-read.table(".\\UCI HAR Dataset\\test\\y_test.txt")
  subject_test<-read.table(".\\UCI HAR Dataset\\test\\subject_test.txt")

##Step1:Merges the training and the test sets to create one data set.
  
  x<-rbind(x_train,x_test)
  y<-rbind(y_train,y_test)
  subject<-rbind(subject_train,subject_test)

##Step2:Extracts only the measurements on the mean and standard deviation 
##for each measurement. 
  
  a<-strsplit(as.character(features[ ,2]),"-")
  result<-NULL
  for (i in 1:length(a)) ##for each list like  a[[1]]=("tBodyAcc" "mean()"   "X") 
  {
    if(!is.na(charmatch("mean",a[[i]]))) ##find out if "mean" exists
    {
      result<-c(result,i)
    }
    if(!is.na(charmatch("std",a[[i]]))) ##find out if "std" exists
    {
      result<-c(result,i)
    }
  }
  
  subX<-x[,result] ##Substrat only the "mean" and "std" variables
  
##Step3:Uses descriptive activity names to name the activities in the data set
 
  for (i in 1:nrow(y)){
    y[i,1]<-as.character(activities[y[i,1],2])
  }
  y<-rename(y,activities=V1)

##Step4:Appropriately labels the data set with descriptive variable names
  subFeatures<-features[result,]
  colnames(subX)<-subFeatures[ ,2]

  ##Merge subjects, activites and variables into final tidy data set
  finalData<-cbind(subject,y,subX)
  colnames(finalData)[1]="Subject"

##Step5:From the data set in step 4, creates a second, independent 
##tidy data set with the average of each variable for each activity 
##and each subject.
  
  temp<-NULL
  temp2<-NULL
  for (i in 1:30){
    temp<-NULL
    subFData<-finalData[(finalData[ ,1]==i),]
    for (j in 1:nrow(subFeatures)){
      temp<-cbind(temp,(tapply(subFData[,j+2],subFData[,2],mean)))
    }
    temp<-cbind(rep(i,6),as.character(sort(activities[ ,2])),temp)
    temp2<-rbind(temp2,temp)

  }
  temp2<-data.frame(temp2)
  colnames(temp2)<-colnames(finalData)
  ##Write result into file
  write.table(temp2,"result.txt",row.name=FALSE) 
  
