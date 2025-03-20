library(readxl)
library(dplyr)
library(writexl)

# Check available sheet names
file_path <- "data/online_retail.xlsx"
sheets <- excel_sheets(file_path)
print(sheets)  # This will list the names of the two sheets

# # Read both sheets
# data1 <- read_excel(file_path, sheet = sheets[1])
# data2 <- read_excel(file_path, sheet = sheets[2])

# Preview data
head(data1)
head(data2)

# Save as CSV
write.csv(data1, "data/online_retail_1.csv", row.names = FALSE)
write.csv(data2, "data/online_retail_2.csv", row.names = FALSE)

print("CSV files saved successfully!")

combined_data <- bind_rows(data1, data2)

# Save the merged dataset as CSV
write.csv(combined_data, "data/online_retail_combined.csv", row.names = FALSE)

print("Merged CSV file saved successfully!")

