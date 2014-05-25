#Coursera Getting & Cleaning Data, Course Project: UCI HAR Dataset

library(gsubfn)

run_analysis <- function() {

        #Training set
        #Read in subject_train, y_train, and X_train datasets
        
        train.subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
        train.y <- read.table("UCI HAR Dataset/train/y_train.txt")
        train.X <- read.table("UCI HAR Dataset/train/X_train.txt")
        
        #Combine three datasets
        train.Set <- data.frame(cbind(train.subject, train.y, train.X))
        
        #List files in train Inertial Signals directory
        train.SignalsFiles <- list.files("UCI HAR Dataset/train/Inertial Signals")
        
        #Create data frame of train signals datasets
        train.Signals <- data.frame()
        
        for(i in 1:9) {        
                train.Signals <- read.table(paste("UCI HAR Dataset/train/Inertial Signals/", 
                                                  train.SignalsFiles[i], sep=""))        
                train.Set <- cbind(train.Set, train.Signals)
        }
        
        #Test set - repeat of train.Set process
        test.subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
        test.y <- read.table("UCI HAR Dataset/test/y_test.txt")
        test.X <- read.table("UCI HAR Dataset/test/X_test.txt")
        
        test.Set <- data.frame(cbind(test.subject, test.y, test.X))
        
        #List files in train Inertial Signals directory
        test.SignalsFiles <- list.files("UCI HAR Dataset/test/Inertial Signals")
        
        #Create data frame of train signals datasets
        test.Signals <- data.frame()
        
        for(i in 1:9) {        
                test.Signals <- read.table(paste("UCI HAR Dataset/test/Inertial Signals/", 
                                                 test.SignalsFiles[i], sep=""))        
                test.Set <- cbind(test.Set, test.Signals)
        }
        
        #1.Merge datasets
        dataset <- rbind(train.Set, test.Set)
        dataset.1 <- dataset[order(dataset[, 1], dataset[, 2]), ]
        
        #4.Name variables in dataset.1
        
        #Name data.X
        names.X.raw <- read.table("UCI HAR Dataset/features.txt")
        #Format names.X
        x <- gsub("()", "", names.X.raw[, 2], fixed=TRUE)
        y <- gsub("-", ".", x, fixed=TRUE)
        names.X <- gsubfn("\\B.", tolower, y, perl=TRUE)
        
        #Name signal measurements
        names.Signals <- character()
        names.Signals.abb <- c("body.acc.x", "body.acc.y", "body.acc.z", "body.gyro.x", 
                               "body.gyro.y", "body.gyro.z", "total.acc.x", "total.acc.y", 
                               "total.acc.z")
        numbers.Signals <- seq(1, 128, by=1)
        
        for(i in 1:9) {
                b <- c(rep(names.Signals.abb[1], 128))
                for(j in 1:128) {
                        c <- paste(b[j], numbers.Signals[j], sep=".")
                        names.Signals <- c(names.Signals, c)
                }
        }
        
        #Name all variables
        names(dataset.1) <- c("subject", "activity", names.X, names.Signals)
        
        #2.Extract mean and standard deviation variables
        
        index.mean <- grep("mean", names.X, ignore.case = TRUE)
        index.std <- grep("std", names.X, ignore.case = TRUE)
        index.a <- c(index.mean, index.std)
        index <- sort(index.a)
        
        dataset.mean.std <- dataset.1[, index + 2]
        dataset.mean.std.1 <- cbind(dataset.mean.std, dataset.1["subject"])
        
        #3.Label activities with descriptive names
        
        activity.labels.raw <- read.table("UCI HAR Dataset/activity_labels.txt")
        activity.labels.1 <- gsubfn(".", tolower, as.character(activity.labels.raw[, 2]), 
                                    perl=TRUE)
        activity.labels.2 <- gsub("_", ".", activity.labels.1, fixed=TRUE)
        
        for(i in 1:6) {
                dataset.1$activity <- gsub(i, activity.labels.2[i], dataset.1$activity)        
        }
        
        #5.Create a second dataset of the mean of each variable for each activity and 
        #each subject
        second.dataset <- data.frame()
        second.dataset.pre <- data.frame()
                
        for(i in 1:6) {
                activity.set <- dataset.1[dataset.1$activity == activity.labels.2[i], ]
                
                for( j in 1:30) {
                        subject.set <- activity.set[activity.set$subject == j, ]
                        mean.unit.1 <- numeric()
                        mean.unit.pre <- numeric()
                        
                        for(k in 3:1715) {
                                mean.unit.1 <- (mean(subject.set[, k]))
                                mean.unit.pre <- c(mean.unit.pre, mean.unit.1)
                        }
                        
                        second.dataset <- rbind(second.dataset, mean.unit.pre)
                }
        }        
        
        names(second.dataset) <- c(names.X, names.Signals)
        subject.col <- c(rep(1:30, 6))
        activity.col <- c(rep(1:6, 30))
        activity.col <- sort(activity.col)
        
        for(i in 1:6) {
                activity.col <- gsub(i, activity.labels.2[i], activity.col)        
        }
        
        id <- data.frame(cbind(activity.col, subject.col))
        names(id) <- c("activity", "subject")
        
        second.tidy.dataset <- cbind(id, second.dataset)
        
        #write second.dataset to txt file
        write.table(second.tidy.dataset, file="tidy_dataset2.txt")
}