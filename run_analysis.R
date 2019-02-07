################################
# 1 - Downloading input data   #
# 2 - Extracting data          #
# 3 - Merging data             #
# 4 - Making tidy output data  #
################################

if (!require("reshape2")){
  install.packages("reshape2")
}

require(reshape2)

# 1 - Downloading data

file_name <- "getdata_projectfiles_UCI HAR Dataset.zip"
file_URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file_dir <- "UCI HAR Dataset"

if (!file.exists(file_name)) {
  download.file(file_URL, file_name, method = "curl")
}

if (!file.exists(file_dir)) {
  dir.create(file_dir)
  unzip(file_name)
}

# 2 - Extracting data

activity_labels <- read.table(file.path(file_dir, "activity_labels.txt"))
features <- read.table(file.path(file_dir, "features.txt"))

extract_data <- grep("mean|std", features[,2])
names_vector <- features[extract_data,2]

train <- read.table(file.path(file_dir, "train", "X_train.txt"))[extract_data]
train_subjects <- read.table(file.path(file_dir, "train", "subject_train.txt"))
train_activity <- read.table(file.path(file_dir, "train", "y_train.txt"))

test <- read.table(file.path(file_dir, "test", "X_test.txt"))[extract_data]
test_subject <- read.table(file.path(file_dir, "test", "subject_test.txt"))
test_activity <- read.table(file.path(file_dir, "test", "y_test.txt"))

# 3 - Merging data

train <- cbind(train_subjects, train_activity, train)
test <- cbind(test_subject, test_activity, test)
complete_data <- rbind(train,test)

# 4 - Making tidy output data

names_vector <- as.character(names_vector)
names_vector <- gsub("-mean", "Mean", names_vector)
names_vector <- gsub("-std", "StandardDeviation", names_vector)
names_vector <- gsub("[-()]", "", names_vector)
names_vector <- gsub("\\.|\\..", "", names_vector)

colnames(complete_data) <- c("Subject", "Activity",names_vector)
complete_data$Activity <- factor(complete_data$Activity, levels = activity_labels[,1], labels = activity_labels[,2])
complete_data$Subject <- as.factor(complete_data$Subject)

melt_data <- melt(complete_data, id = c("Subject", "Activity"))
cast_data <- dcast(melt_data, Subject + Activity ~ variable, mean)

write.table(cast_data, file = "./tidy_data.txt", row.names = FALSE)
