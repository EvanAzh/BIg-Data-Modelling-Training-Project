# Install useful packages
install.packages('plyr')
install.packages('ggplot2')
install.packages('cluster')
install.packages('lattice')
install.packages('graphics')
install.packages('grid')
install.packages('gridExtra')
install.packages('mltools')
install.packages('data.table')

# Load libraries
library(plyr)
library(ggplot2)
library(cluster)
library(lattice)
library(graphics)
library(grid)
library(gridExtra)
library(mltools)
library(data.table)

###################################################
# Data import and generation of new columns
###################################################

# Import the dataset
data <- read.csv("Different_stores_dataset.csv")

# Create new columns for total sales and total profit
data$total_sales <- data$quantity * data$selling_price_per_unit
data$profit <- data$total_sales - (data$quantity * data$cost_price_per_unit)

###################################################
# Data selection and normalization
###################################################

# Keep only important information (debatable)
# Focus on profit (which is the most important for us?)
# Could also focus on quantity to know what to expect when running an ad campaign
# Only region and profit to avoid distortion

data_selected1 <- data[, c("gender", "age", "category", "state", "profit")]

# Change type to numeric
data_selected1[, c(2, 5)] <- lapply(data_selected1[, c(2, 5)], as.numeric)

# Normalize age and profit
selected_columns <- scale(data_selected1[, c(2, 5)])

# Put it back in data_selected1
data_selected1[, c("age", "profit")] <- selected_columns

###################################################
# Value transformation
###################################################

# Transform strings to numeric
# Binary transformation for gender
data_selected1$gender <- ifelse(data_selected1$gender == "Male", 1, 0)

# One-hot encoding for state and category
# https://datatricks.co.uk/one-hot-encoding-in-r-three-simple-methods

# Transform state and category to factor
data_selected1$state <- as.factor(data_selected1$state)
data_selected1$category <- as.factor(data_selected1$category)

newdata <- one_hot(as.data.table(data_selected1))
print(colnames(newdata))

###################################################
# Matrix transformation
###################################################

# Transform the dataset into a matrix
data_matrix <- as.matrix(newdata[, c("gender", "age", "category_Books", "category_Clothing", "category_Cosmetics", "category_Food & Beverage", "category_Shoes", "category_Souvenir", "category_Technology", "category_Toys", "state_Alabama", "state_Arizona", "state_California", "state_Colorado", "state_Delaware", "state_Florida", "state_Georgia", "state_Idaho", "state_Illinois", "state_Indiana", "state_Iowa", "state_Kentucky", "state_Massachusetts", "state_Michigan", "state_New York", "state_North Carolina", "state_Ohio", "state_Oregon", "state_Pennsylvania", "state_Tennessee", "state_Texas", "state_Virginia", "state_Washington", "profit")])

# Overview of the dataset
# print(data_matrix[1:34, ])

# Export dataset
write.csv(data_matrix, file = "data_matrix.csv", row.names = FALSE)

###################################################
# Clustering with k-means
###################################################

# Determine an appropriate value for k using the k-means algorithm for k = 1 to 30
wss <- numeric(30)
for (k in 1:30) {
  wss[k] <- sum(kmeans(data_matrix, centers = k, nstart = 25, iter.max = 50, trace = TRUE)$withinss)
}
# This one needs some time! Get a coffee.

# Plot WSS against the number of clusters
plot(1:30, wss, type = "b", xlab = "Number of Clusters", ylab = "Within Sum of Squares")

# The WSS is greatly reduced when k increases from one to two. Another substantial reduction in WSS occurs at k = 6.
# However, the improvement in WSS is fairly linear for k > 6. Therefore, the k-means analysis will be conducted for k = 6.
km <- kmeans(data_matrix, 6, nstart = 25)
print(km)

###################################################
# Plotting of results
###################################################

# Return a list of all possible combinations of variables
var_combinations <- combn(names(data_matrix), 2, simplify = TRUE)

# Function to plot a pair of variables with cluster colors
plot_cluster_pair <- function(var1, var2) {
  df <- as.data.frame(data_matrix)
  df$cluster <- factor(km$cluster)
  centers <- as.data.frame(km$centers)
  
  ggplot(data = df, aes_string(x = var1, y = var2, color = "cluster")) +
    geom_point() +
    geom_point(data = centers, aes_string(x = paste0("centers$", var1), y = paste0("centers$", var2)),
               color = c("indianred1", "khaki3", "lightgreen", "lightskyblue", "plum2"), size = 8, show.legend = FALSE) +
    ggtitle(paste("Cluster Analysis for", var1, "vs", var2))
}

# Plot each pair of variables
for (i in 1:ncol(var_combinations)) {
  var1 <- var_combinations[1, i]
  var2 <- var_combinations[2, i]
  g <- plot_cluster_pair(var1, var2)
  print(g)
}
# Needs a long time
# Too time consuming. Therefore we need a better goal for our analysis
# For a single state list the clusters

### Maybe first find out which products have the highest margin, then look for the audience for these products in certain states
### Maybe regression with profit as the dependent variable? -> from this you can deduce who to address most and which products to promote
### Then advertising campaign for the entire country (no states) but how???
### Clusters: to tailor an advertising campaign to a state, you can filter by state and then cluster the customers by profit. You could also perform such clustering for each product category.

