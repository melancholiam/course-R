#download and unzip files

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "Dataset.zip", method = "curl")
unzip("Dataset.zip")

#read data from files

ActivityTest  <- read.table("./UCI HAR Dataset/test/Y_test.txt",header = FALSE)
ActivityTrain <- read.table("./UCI HAR Dataset/train/Y_train.txt",header = FALSE)

SubjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt",header = FALSE)
SubjectTest  <- read.table("./UCI HAR Dataset/test/subject_test.txt",header = FALSE)

FeaturesTest  <- read.table("./UCI HAR Dataset/test/X_test.txt",header = FALSE)
FeaturesTrain <- read.table("./UCI HAR Dataset/train/X_train.txt",header = FALSE)

FeaturesNames <- read.table("./UCI HAR Dataset/features.txt",head=FALSE)
ActivityNames <- read.table("./UCI HAR Dataset/activity_labels.txt",header = FALSE)

#merge train and test data
Subject <- rbind(SubjectTrain, SubjectTest)
Activity<- rbind(ActivityTrain, ActivityTest)
Features<- rbind(FeaturesTrain, FeaturesTest)

#set names to variables
names(Subject)<-c("subject")
names(Activity)<- c("activity")
names(Features)<- FeaturesNames[,2]

#combine data (Subject, Activity, Features)
SubjectActivity <- cbind(Subject, Activity)
combined_data <- cbind(Features, SubjectActivity)

#extract only the measurements on the mean and std
extracted_features <- FeaturesNames$V2[grepl("mean\\(\\)|std\\(\\)", FeaturesNames[,2])]
extractedNames<-c(as.character(extracted_features), "subject", "activity" )
data<-subset(combined_data,select=extractedNames)

#assing descriptive variable names
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))
names(data)<-gsub("-mean()", "-Mean", names(data))
names(data)<-gsub("-std()", "-STD", names(data))
data$activity<-mapvalues(data$activity, from=ActivityNames$V1,to=levels(ActivityNames$V2))
data$activity<-as.factor(data$activity)

#create and write down tidy data
tidy_data<-aggregate(. ~subject + activity, data, mean)
tidy_data<-tidy_data[order(tidy_data$subject,tidy_data$activity),]
write.table(tidy_data, file = "tidydata.txt",row.name=FALSE)
