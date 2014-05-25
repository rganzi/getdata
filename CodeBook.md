CodeBook
=============================================================================================
Getting & Cleaning Data, Course Project Write-up
---------------------------------------------------------------------------------------------

This CodeBook outlines my process for completing the Getting & Clearning Data Course Project. The instructions for the Course Project were the following:

You should create one R script called **run_analysis.R** that does the following. 

1. Merges the training and the test sets to create one data set  
2. Extracts only the measurements on the mean and standard deviation for each measurement  
3. Uses descriptive activity names to name the activities in the data set  
4. Appropriately labels the data set with descriptive activity names  
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject

### 1. Merging the Training and Test Sets
#### Reading in the Data
The training and test set files were read into R individually, then combined into a single data frame using `cbind()`. The inertial signal files for each set were read into R by an automated process using `list.files()` to create a vector of the nine file names in the "Inertial Signals" folder then looping read.table across the elements of that vector, binding each to the `train.Set` data frame.

```
for(i in 1:9) {        
        train.Signals <- read.table(paste("UCI HAR Dataset/train/Inertial Signals/", 
                train.SignalsFiles[i], sep=""))        
        train.Set <- cbind(train.Set, train.Signals)
}
```
#### Merging the Data
The training and test sets were merged using `rbind()` and the resulting dataset was sorted according to the first, then second, columns (subject then activity code).
```
#1.Merge datasets
dataset <- rbind(train.Set, test.Set)
dataset.1 <- dataset[order(dataset[, 1], dataset[, 2]), ]
```

### 2. Extracting Measurements for Mean and Standard Deviation
Names including each of the terms "mean" and "std" were extracted from the names vector using `grep()`.  An index for both terms was created and used to subset the data set.

```
#2.Extract mean and standard deviation variables        
index.mean <- grep("mean", names.X, ignore.case = TRUE)
index.std <- grep("std", names.X, ignore.case = TRUE)
index.a <- c(index.mean, index.std)
index <- sort(index.a)
        
dataset.mean.std <- dataset.1[, index + 2]
dataset.mean.std.1 <- cbind(dataset.mean.std, dataset.1["subject"])
```

### 3. Naming the Activities with Descriptive Activity Names
The labels for each activity were extracted from the "activity_labels.txt" file. The activity names were formatted to lower case using `gsubfn()` and from the `{gsubfn package}`, and were used to replace the activity codes using `gsub()` via a "for" loop.

```
for(i in 1:6) {
        dataset.1$activity <- gsub(i, activity.labels.2[i], dataset.1$activity)        
}
```

### 4. Labeling the Data Set with Descriptive Names
The names of the variables were labeled in a two-stage process. 

#### Summary Variables
The names for the summary variables were extracted from the "features.txt" file then formatted usign the `gsub()` function. 

#### Signal Variables
The signal variables were named according to the sensor and the observation number, from 1 to 128. A vector of these signal names was created using a nested "for" loop.

```
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
```

### 5. Creating a Second Data Set of the Average of Each Variable for Each Activity and for Each Subject
#### Interpretation
I interpreted the wording of step five to mean that there should be 180 rows in the second data set, the averages of the 30 subjects for each of the six activities.  All 1715 variables were included in the second dataset.  

#### Procedure
I used a nested "for" loop to create the data set: one loop over the six activites and a second over the 30 subjects. The third loop calculates the mean for each of the 1715 columns of the original data set and is not nested within the second loop.

```
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
```
The output of the function is a txt file named "tidy_dataset2.txt," which is written to the working directory.

Code
----------------------------------------------------------------------------

```r
source("run_analysis.R")
```

```
## Loading required package: proto
```

```r
body(run_analysis)
```

```
## {
##     train.subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
##     train.y <- read.table("UCI HAR Dataset/train/y_train.txt")
##     train.X <- read.table("UCI HAR Dataset/train/X_train.txt")
##     train.Set <- data.frame(cbind(train.subject, train.y, train.X))
##     train.SignalsFiles <- list.files("UCI HAR Dataset/train/Inertial Signals")
##     train.Signals <- data.frame()
##     for (i in 1:9) {
##         train.Signals <- read.table(paste("UCI HAR Dataset/train/Inertial Signals/", 
##             train.SignalsFiles[i], sep = ""))
##         train.Set <- cbind(train.Set, train.Signals)
##     }
##     test.subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
##     test.y <- read.table("UCI HAR Dataset/test/y_test.txt")
##     test.X <- read.table("UCI HAR Dataset/test/X_test.txt")
##     test.Set <- data.frame(cbind(test.subject, test.y, test.X))
##     test.SignalsFiles <- list.files("UCI HAR Dataset/test/Inertial Signals")
##     test.Signals <- data.frame()
##     for (i in 1:9) {
##         test.Signals <- read.table(paste("UCI HAR Dataset/test/Inertial Signals/", 
##             test.SignalsFiles[i], sep = ""))
##         test.Set <- cbind(test.Set, test.Signals)
##     }
##     dataset <- rbind(train.Set, test.Set)
##     dataset.1 <- dataset[order(dataset[, 1], dataset[, 2]), ]
##     names.X.raw <- read.table("UCI HAR Dataset/features.txt")
##     x <- gsub("()", "", names.X.raw[, 2], fixed = TRUE)
##     y <- gsub("-", ".", x, fixed = TRUE)
##     names.X <- gsubfn("\\B.", tolower, y, perl = TRUE)
##     names.Signals <- character()
##     names.Signals.abb <- c("body.acc.x", "body.acc.y", "body.acc.z", 
##         "body.gyro.x", "body.gyro.y", "body.gyro.z", "total.acc.x", 
##         "total.acc.y", "total.acc.z")
##     numbers.Signals <- seq(1, 128, by = 1)
##     for (i in 1:9) {
##         b <- c(rep(names.Signals.abb[1], 128))
##         for (j in 1:128) {
##             c <- paste(b[j], numbers.Signals[j], sep = ".")
##             names.Signals <- c(names.Signals, c)
##         }
##     }
##     names(dataset.1) <- c("subject", "activity", names.X, names.Signals)
##     index.mean <- grep("mean", names.X, ignore.case = TRUE)
##     index.std <- grep("std", names.X, ignore.case = TRUE)
##     index.a <- c(index.mean, index.std)
##     index <- sort(index.a)
##     dataset.mean.std <- dataset.1[, index + 2]
##     dataset.mean.std.1 <- cbind(dataset.mean.std, dataset.1["subject"])
##     activity.labels.raw <- read.table("UCI HAR Dataset/activity_labels.txt")
##     activity.labels.1 <- gsubfn(".", tolower, as.character(activity.labels.raw[, 
##         2]), perl = TRUE)
##     activity.labels.2 <- gsub("_", ".", activity.labels.1, fixed = TRUE)
##     for (i in 1:6) {
##         dataset.1$activity <- gsub(i, activity.labels.2[i], dataset.1$activity)
##     }
##     second.dataset <- data.frame()
##     second.dataset.pre <- data.frame()
##     for (i in 1:6) {
##         activity.set <- dataset.1[dataset.1$activity == activity.labels.2[i], 
##             ]
##         for (j in 1:30) {
##             subject.set <- activity.set[activity.set$subject == 
##                 j, ]
##             mean.unit.1 <- numeric()
##             mean.unit.pre <- numeric()
##             for (k in 3:1715) {
##                 mean.unit.1 <- (mean(subject.set[, k]))
##                 mean.unit.pre <- c(mean.unit.pre, mean.unit.1)
##             }
##             second.dataset <- rbind(second.dataset, mean.unit.pre)
##         }
##     }
##     names(second.dataset) <- c(names.X, names.Signals)
##     subject.col <- c(rep(1:30, 6))
##     activity.col <- c(rep(1:6, 30))
##     activity.col <- sort(activity.col)
##     for (i in 1:6) {
##         activity.col <- gsub(i, activity.labels.2[i], activity.col)
##     }
##     id <- data.frame(cbind(activity.col, subject.col))
##     names(id) <- c("activity", "subject")
##     second.tidy.dataset <- cbind(id, second.dataset)
##     write.table(second.tidy.dataset, file = "tidy_dataset2.txt")
## }
```

