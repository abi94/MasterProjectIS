# Install necessary packages if not already installed
if (!requireNamespace("arules", quietly = TRUE)) {
  install.packages("arules")
}
if (!requireNamespace("arulesViz", quietly = TRUE)) {
  install.packages("arulesViz")
}
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}

# Load the libraries
library(arules)
library(arulesViz)
library(ggplot2)

library(tidyverse)
library(knitr)
library(readr)
library(dplyr)

#---------------------------------------------------------------------------------------------
#BEGIN
#A-Priori rules definitions and metrics
#RULE X-> Y
#Support = Frequency(X,Y)/N
#Confidence = Freuency(X,Y)/Frequecny(X) -> 
#Lift = Support/Support(X)*Support(Y) -> Ratio of Confidence to Expected Confidence
#Coverage = probability for the antecedent alone in the entire dataset
#END
#---------------------------------------------------------------------------------------------

# Read the dataset
data_posts <- read.csv("Apriorimodel/data/FinalAnnotationSheet.csv")

# Remove duplicates based on the 'Post_ID' column
data_posts <- data_posts %>% distinct(Post_ID, .keep_all = TRUE)

# Remove the ethical_Issue "only one issue" from both ethical issue label post 1 and ethical issue label post 2
data_posts <- data_posts %>%
  filter(!(data_posts$`ethical.issue.label.post.1` == "13. only one issue" & data_posts$`ethical.issue.label.post.2` != "13. only one issue") &
           !(data_posts$`ethical.issue.label.post.1` != "13. only one issue" & data_posts$`ethical.issue.label.post.2` == "13. only one issue"))

#Write the new filtered dataset into a new CSV File
write.csv(data_posts, "Apriorimodel/data/FinalAnnotationSheet_OnlyOneIssueRemoved_posts.csv", row.names = FALSE)

#Read the new filtered CSV File
data_posts <- read.csv("Apriorimodel/data/FinalAnnotationSheet_OnlyOneIssueRemoved_posts.csv")

#Print the data to see the new csv file
print(data_posts)

# Remove numbers and leading/trailing spaces from the column values
ethical_issue_label_post_1 <- gsub("^\\d+\\.\\s*", "", data_posts$`ethical.issue.label.post.1`)
ethical_issue_label_post_2 <- gsub("^\\d+\\.\\s*", "", data_posts$`ethical.issue.label.post.2`)

# Create a list of vectors combining the values of both columns
EthicalIssuesPostslist <- lapply(1:length(ethical_issue_label_post_1), function(i) {
  c(ethical_issue_label_post_1[i], ethical_issue_label_post_2[i])
})

# Set transaction names
names(EthicalIssuesPostslist) <- paste("T", c(1:length(ethical_issue_label_post_1)), sep = "")

# Print names to verify
print(names(EthicalIssuesPostslist))

# Convert the list to transactions
TransactionEthicalIssuesPosts <- as(EthicalIssuesPostslist, "transactions")

# Print the transactions to verify
print(TransactionEthicalIssuesPosts)

# Print the dimensions of the transactions
print(dim(TransactionEthicalIssuesPosts))

# Print the item labels of the transactions
print(itemLabels(TransactionEthicalIssuesPosts))

# Print the summary of the transactions
print(summary(TransactionEthicalIssuesPosts))

# Plot the image of the transactions
image(TransactionEthicalIssuesPosts)

# Custom frequency counts considering non-distinct items
all_items <- unlist(EthicalIssuesPostslist)

# Count the frequency of each item
item_counts <- table(all_items)

# Print the item counts
print(item_counts)

# Convert the item counts to a dataframe for better visualization
item_freq_dataframe <- data.frame(
  Nr_EthicalIssues = names(item_counts),
  count = as.numeric(item_counts)
)

# Print the item frequency dataframe sorted by count
print(item_freq_dataframe[order(item_freq_dataframe$count, decreasing = TRUE),])

# Frequency plots
item_freq_sorted <- sort(item_counts, decreasing = TRUE)
barplot(item_freq_sorted, las = 2, cex.names = 0.7, main = "Item Frequency Plot", col = "lightblue")

# Print top items
top_items <- names(item_freq_sorted)
print(top_items)

# Calculate the absolute frequencies
EthicalIssues_Labels <- c(top_items)
print(EthicalIssues_Labels)
EthicalIssues_count <- c(as.numeric(item_freq_sorted))
print(EthicalIssues_count)

barplt <- barplot(EthicalIssues_count, main = "",
                  ylab = "Frequency", col = "deepskyblue", border = "White",
                  ylim = c(0, 60), names.arg = rep("", length(EthicalIssues_count)), las = 2)

text(
  x = barplt, 
  y = EthicalIssues_count + 0.1, # - 0.1,
  labels = EthicalIssues_count, #top_items,
  pos = 3,
  xpd = TRUE,
  cex = 1,
  font = 2
)


text(
  x = barplt,
  y = -0.5,  # Adjust the vertical position below the plot
  labels = EthicalIssues_Labels,
  srt = 25,  # Rotate the text 45 degrees to the right
  adj = c(1, 1),  # Adjust text alignment
  xpd = TRUE,  # Allow text to be drawn outside the plot region
  cex = 1,  # Adjust the size of the text
  font = 2
)


# Calculate the relative frequencies
relative_freq <- sort(as.numeric(item_freq_sorted/length(TransactionEthicalIssuesPosts)),decreasing = TRUE)

relative_freq

barplt <- barplot(relative_freq,
                  main = "Ethical Issues by Relative Frequency",
                  ylab = "Relative Frequency",
                  col = "deepskyblue",
                  border = "black",
                  ylim = c(0, 0.6),
                  names.arg = rep("", length(relative_freq)))  


text(
  x = barplt,
  y = relative_freq - 0.002,  # Adjust the vertical position slightly above each bar
  labels = paste0(round(relative_freq * 100, 1), "%"),  # Convert to percentages and add %
  pos = 3,  
  col = "black",
  cex = 1,
  font = 2
)

text(
  x = barplt,
  y = -0.002,  # Adjust the vertical position below the plot
  labels = EthicalIssues_Labels,
  srt = 25,  # Rotate the text 45 degrees to the right
  adj = c(1, 1),  # Adjust text alignment
  xpd = TRUE,  # Allow text to be drawn outside the plot region
  cex = 1,  # Adjust the size of the text
  col = "black",  # Set the color of the text to a bold color
  font = 2  # Make the text bold
)


# Absolute and Relative Frequency plots with different colors
if (!require("RColorBrewer")) {
  # install color package of R
  install.packages("RColorBrewer")
  #include library RColorBrewer
  library(RColorBrewer)
}

itemFrequencyPlot(TransactionEthicalIssuesPosts,topN=length(item_freq_sorted),type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot",ylim = c(0, 1000))

itemFrequencyPlot(TransactionEthicalIssuesPosts,topN=length(item_freq_sorted),type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot",ylim = c(0, 500))

itemFrequencyPlot(TransactionEthicalIssuesPosts,topN=length(item_freq_sorted),type="relative",col=brewer.pal(8,'Pastel2'),main="Relative Item Frequency Plot",ylim = c(0, 1))

itemFrequencyPlot(TransactionEthicalIssuesPosts,topN=length(item_freq_sorted),type="relative",col=brewer.pal(8,'Pastel2'),main="Relative Item Frequency Plot",ylim = c(0, 0.5))

TransactionEthicalIssuesPosts <- as(TransactionEthicalIssuesPosts, "transactions")

# Apriori model and Association rules
rules <- apriori(TransactionEthicalIssuesPosts, 
                 parameter = list(supp=0.0, conf=0.0, 
                                  maxlen=100,  
                                  minlen=2,
                                  target= "rules"))


sorted_rules <- sort(rules[quality(rules)$count > 0], by = "count", decreasing = TRUE)

inspect(sorted_rules)

#Create Barcharts for the arpiori rules
rule_labels <- labels(sorted_rules)
rule_freq <- quality(sorted_rules)$support

rule_freq_sorted <- sort(rule_freq, decreasing = TRUE)
rule_labels_sorted <- rule_labels[order(rule_freq, decreasing = TRUE)]

barplt <- barplot(rule_freq_sorted,
                  main = "Association Rules by Frequency",
                  ylab = "Support",
                  col = "lightblue",
                  border = "black",
                  ylim = c(0, 0.3), 
                  names.arg = rep("", length(rule_freq_sorted)),  # Empty names.arg to manually add rotated labels
                  las = 2)  # Rotate x-axis labels for better visibility

text(
  x = barplt,
  y = rule_freq_sorted + 0.006,  # Adjust the vertical position slightly above each bar
  labels = round(rule_freq_sorted, 4),  # Display the frequency values
  srt = 90,  # Rotate the text 45 degrees to the right
  pos = 3,  # Position the text above the bars
  col = "black",  # Set the color of the text
  cex = 0.8,  # Adjust the size of the text
  font = 2
)

text(
  x = barplt,
  y = -0.0005,  # Adjust the vertical position below the plot
  labels = rule_labels_sorted,
  srt = 25,  # Rotate the text 45 degrees to the right
  adj = c(1, 1),  # Adjust text alignment
  xpd = TRUE,  # Allow text to be drawn outside the plot region
  cex = 0.55,  # Adjust the size of the text
  col = "black",  # Set the color of the text to a bold color
  font = 2  # Make the text bold
)


#Apriori rules for the right side
Rule_EthicalIssue_misinformation_RHS <- apriori(TransactionEthicalIssuesPosts, 
                                                parameter = list(supp=0.0, conf=0.0, 
                                                                 maxlen=100, 
                                                                 minlen=2),
                                                appearance = list(default="lhs", rhs="misinformation"))

sorted_Rule_EthicalIssue_misinformation_RHS <- sort(Rule_EthicalIssue_misinformation_RHS[quality(Rule_EthicalIssue_misinformation_RHS)$count > 0], by = "count", decreasing = TRUE)

inspect(sorted_Rule_EthicalIssue_misinformation_RHS)


Rule_EthicalIssue_misinformation_LHS <- apriori(TransactionEthicalIssuesPosts, parameter=list(supp=0.0, conf=0.0, maxlen=100, 
                                                                      minlen=2),
                                                appearance = list(lhs="misinformation", default="rhs"))

sorted_Rule_EthicalIssue_misinformation_LHS <- sort(Rule_EthicalIssue_misinformation_LHS[quality(Rule_EthicalIssue_misinformation_LHS)$count > 0], by = "count", decreasing = TRUE)

inspect(sorted_Rule_EthicalIssue_misinformation_LHS)


library(arulesViz)
install.packages("plotly")
library(plotly)

# Convert the apriori rules to a data frame
rules_dataframe <- as(sorted_rules, "data.frame")

# Add the rule labels to the data frame
rules_dataframe$rule <- labels(sorted_rules)

# Create a scatter plot using plotly
fig <- plot_ly(
  data = rules_dataframe,
  x = ~support,
  y = ~confidence,
  text = ~paste("Rule:", rule, "<br>Support:", support, "<br>Confidence:", confidence, "<br>Lift:", lift, "<br>Count:", count),
  type = 'scatter',
  mode = 'markers',
  marker = list(size = 10)
)

fig <- fig %>%
  layout(
    title = "Scatter Plot of apriori Rules",
    xaxis = list(title = "Support"),
    yaxis = list(title = "Confidence")
  )

# Display the plot
fig

# Filter rules with confidence greater than 0.5 or 50%
subRules<-sorted_rules[quality(sorted_rules)$confidence>0.5]

inspect(subRules)

rules_dataframe <- as(subRules, "data.frame")

# Add the rule labels to the data frame
rules_dataframe$rule <- labels(subRules)

set.seed(123) # for reproducibility
rules_dataframe$jittered_support <- jitter(rules_dataframe$support)
rules_dataframe$jittered_confidence <- jitter(rules_dataframe$confidence)

# Create a scatter plot using plotly with jitter and transparency
fig <- plot_ly(
  data = rules_dataframe,
  x = ~jittered_support,
  y = ~jittered_confidence,
  text = ~paste("Rule:", rule, "<br>Support:", support, "<br>Confidence:", confidence, "<br>Lift:", lift, "<br>Count:", count),
  type = 'scatter',
  mode = 'markers',
  marker = list(size = 10, opacity = 0.7) # Adding transparency
)

# Add titles and labels
fig <- fig %>%
  layout(
    title = "Scatter Plot of apriori Rules",
    xaxis = list(title = "Support"),
    yaxis = list(title = "Confidence")
  )

# Display the plot
fig


top10subRules <- head(subRules, n = 22, by = "confidence")
plot(top10subRules, method = "graph",  engine = "htmlwidget")

# Filter top n rules with highest lift
subRules2<-head(subRules, n=5, by="lift")
plot(subRules2, method="paracoord")

