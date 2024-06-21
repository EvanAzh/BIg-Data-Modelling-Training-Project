# Load required libraries
library(readxl)
library(lattice)
library(ggplot2)
library(corrplot)

###################################################
# Data import, exploration, and selection
###################################################

# Loading the data
data_matrix <- read.csv("data_matrix.csv")
turnover_data <- read.csv("Chapter_6_Turnover_team_DATA.csv")

# A summary of the datasets
summary(data_matrix)
summary(turnover_data)

# Display the first few rows of each dataset
head(data_matrix)
head(turnover_data)

# Outlier Analysis for the turnover_data variables

# Boxplot
par(mfrow=c(2, 4), mar=c(3, 3, 2, 1))  # Adjust the layout based on the number of variables
boxplot(turnover_data$TeamSize, main="Team Size", col="lightblue", pch=19)
boxplot(turnover_data$TeamSeparation, main="Team Separation", col="lightgreen", pch=19)
boxplot(turnover_data$Engagement, main="Engagement", col="lightcoral", pch=19)
boxplot(turnover_data$TeamLeader, main="Team Leader", col="lightyellow", pch=19)
boxplot(turnover_data$SociallyResponsible, main="Socially Responsible", col="lightpink", pch=19)
boxplot(turnover_data$DriveForPerformance, main="Drive For Performance", col="lightgray", pch=19)
boxplot(turnover_data$PerfDevReward, main="Perf Dev Reward", col="lightcyan", pch=19)
boxplot(turnover_data$WLB, main="Work–Life Balance", col="lightgoldenrodyellow", pch=19)

# Reset the layout
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)

# Histogram
par(mfrow=c(2, 4), mar=c(3, 3, 2, 1))  # Adjust the layout based on the number of variables
hist(turnover_data$TeamSize, main = "Team Size", col = "lightblue")
hist(turnover_data$TeamSeparation, main = "Team Separation", col = "lightgreen")
hist(turnover_data$Engagement, main = "Engagement", col = "lightcoral")
hist(turnover_data$TeamLeader, main = "Team Leader", col = "lightyellow")
hist(turnover_data$SociallyResponsible, main = "Socially Responsible", col = "lightpink")
hist(turnover_data$DriveForPerformance, main = "Drive For Performance", col = "lightgray")
hist(turnover_data$PerfDevReward, main = "Perf Dev Reward", col = "lightcyan")
hist(turnover_data$WLB, main = "Work–Life Balance", col = "lightgoldenrodyellow")

# Reset the layout
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)

# Log-standardization for Drive For Performance
turnover_data1 = turnover_data
turnover_data1$DriveForPerformance = log(turnover_data1$DriveForPerformance)
boxplot(turnover_data1$DriveForPerformance, main="Drive For Performance", col="lightgray", pch=19)

# Transformation of dummies to binary
print(sapply(turnover_data, class))
turnover_data$UKdummy <- as.logical(turnover_data$UKdummy)
turnover_data$USAdummy <- as.logical(turnover_data$USAdummy)
turnover_data$CanadaDummy <- as.logical(turnover_data$CanadaDummy)
turnover_data$SpainDummy <- as.logical(turnover_data$SpainDummy)

# Data selection
# The following rows are irrelevant: TeamNumber, Country
regr_data = subset(turnover_data, select = -c(TeamNumber, Country))
summary(regr_data)

print(colnames(regr_data))

###################################################
# Exploration of relationships between variables
###################################################

# Pair-wise relationships of the variables: the scatterplot matrix
exploration_data = subset(regr_data, select = -c(UKdummy, USAdummy, CanadaDummy, SpainDummy))
splom(~exploration_data, groups=NULL, data=exploration_data)

corr_matrix <- cor(regr_data[, c("TeamSize", "TeamSeparation", "Engagement", "TeamLeader",
                                 "SociallyResponsible", "DriveForPerformance",
                                 "PerfDevReward", "WLB", "UKdummy", "USAdummy",
                                 "CanadaDummy", "SpainDummy")])
corrplot(corr_matrix, method = "color")

###################################################
# Model 0: Country differences (log reg)
###################################################

# UK
modelUK = glm (UKdummy ~ TeamSize + TeamSeparation + Engagement + TeamLeader + SociallyResponsible + DriveForPerformance + PerfDevReward + WLB,
               data = regr_data,
               family = binomial(link="logit")
)
summary(modelUK)

# USA
modelUSA = glm (USAdummy ~ TeamSize + TeamSeparation + Engagement + TeamLeader + SociallyResponsible + DriveForPerformance + PerfDevReward + WLB,
                data = regr_data,
                family = binomial(link="logit")
)
summary(modelUSA)

# Canada
modelCanada = glm (CanadaDummy ~ TeamSize + TeamSeparation + Engagement + TeamLeader + SociallyResponsible + DriveForPerformance + PerfDevReward + WLB,
                   data = regr_data,
                   family = binomial(link="logit")
)
summary(modelCanada)

# Spain
modelSpain = glm (SpainDummy ~ TeamSize + TeamSeparation + Engagement + TeamLeader + SociallyResponsible + DriveForPerformance + PerfDevReward + WLB,
                  data = regr_data,
                  family = binomial(link="logit")
)
summary(modelSpain)

# Plots for country differences
uk_data <- subset(regr_data, UKdummy == 1)
usa_data <- subset(regr_data, USAdummy == 1)
spain_data <- subset(regr_data, SpainDummy == 1)
canada_data <- subset(regr_data, CanadaDummy == 1)

# Team Size
par(mfrow=c(1, 4), mar=c(3, 3, 2, 1))
boxplot(usa_data$TeamSize, main="USA", col="lightblue", pch=19)
boxplot(uk_data$TeamSize, main="UK", col="lightcoral", pch=19)
boxplot(spain_data$TeamSize, main="Spain", col="lightgreen", pch=19)
boxplot(canada_data$TeamSize, main="Canada", col="yellow", pch=19)

# Engagement
par(mfrow=c(1, 4), mar=c(3, 3, 2, 1))
boxplot(usa_data$Engagement, main="USA", col="lightblue", pch=19)
boxplot(uk_data$Engagement, main="UK", col="lightcoral", pch=19)
boxplot(spain_data$Engagement, main="Spain", col="lightgreen", pch=19)
boxplot(canada_data$Engagement, main="Canada", col="yellow", pch=19)

# Team Leader
par(mfrow=c(1, 4), mar=c(3, 3, 2, 1))
boxplot(usa_data$TeamLeader, main="USA", col="lightblue", pch=19)
boxplot(uk_data$TeamLeader, main="UK", col="lightcoral", pch=19)
boxplot(spain_data$TeamLeader, main="Spain", col="lightgreen", pch=19)
boxplot(canada_data$TeamLeader, main="Canada", col="yellow", pch=19)

par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1)

###################################################
# Model 1: Performance and turnover prediction
###################################################

# 1. Check for multi-collinearity
correlation_matrix <- cor(regr_data[, c("TeamSize", "TeamSeparation", "Engagement", "TeamLeader",
                                        "SociallyResponsible", "DriveForPerformance", "PerfDevReward", "WLB")])
print(correlation_matrix)

# Exclude "Team Leader" due to high multicollinearity

# 2. Prediction of Team Performance
regr_data_standardized <- regr_data
regr_data_standardized$TeamSeparation <- log(regr_data_standardized$TeamSeparation)
regr_data_standardized$Engagement <- log(regr_data_standardized$Engagement)
regr_data_standardized$DriveForPerformance <- log(regr_data_standardized$DriveForPerformance)
regr_data_standardized$PerfDevReward <- log(regr_data_standardized$PerfDevReward)
regr_data_standardized$WLB <- log(regr_data_standardized$WLB)
regr_data_standardized$SociallyResponsible <- log(regr_data_standardized$SociallyResponsible)

# Train-test split: 70% train, 30% test
set.seed(123)  # Set seed for reproducibility
train_indices <- sample(1:nrow(regr_data_standardized), 0.7 * nrow(regr_data_standardized))
train_data <- regr_data_standardized[train_indices, ]
test_data <- regr_data_standardized[-train_indices, ]

# Remove rows with NA, NaN, or Inf values in the response variable
train_data <- train_data[complete.cases(train_data$TeamSeparation), ]
test_data <- test_data[complete.cases(test_data$TeamSeparation), ]

# Training the model
model_performance <- lm(TeamSeparation ~ TeamSize + Engagement + SociallyResponsible + DriveForPerformance + PerfDevReward + WLB,
                        data = train_data)
summary(model_performance)

# Evaluation on test data
predictions_performance <- predict(model_performance, newdata = test_data)
test_mse_performance <- mean((predictions_performance - test_data$TeamSeparation)^2)
print(test_mse_performance)

# 3. Turnover prediction
# Using same standardized data and split

# Training the model
model_turnover <- lm(TeamSeparation ~ TeamSize + Engagement + SociallyResponsible + DriveForPerformance + PerfDevReward + WLB,
                     data = train_data)
summary(model_turnover)

# Evaluation on test data
predictions_turnover <- predict(model_turnover, newdata = test_data)
test_mse_turnover <- mean((predictions_turnover - test_data$TeamSeparation)^2)
print(test_mse_turnover)

###################################################
# Conclusion
###################################################

# We have identified key variables that significantly impact team performance and turnover.
# Further analysis could explore multi-level modeling to account for country-specific differences and other hierarchical structures within the data.
