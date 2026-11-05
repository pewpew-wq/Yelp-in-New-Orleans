install.packages("arrow")
library(arrow)
library(dplyr)
library(jsonlite)
library(dplyr)

#businesses file
business_df <- stream_in(file("yelp_academic_dataset_business.json"), pagesize = 50000)
nola_businesses <- business_df %>% 
  filter(city == "New Orleans")
nola_checkins <- list()

stream_in(file("yelp_academic_dataset_checkin.json"), handler = function(df) {
  filtered <- df %>% filter(business_id %in% nola_businesses$business_id)
  
  if (nrow(filtered) > 0) {
    nola_checkins[[length(nola_checkins) + 1]] <<- filtered
  }
}, pagesize = 50000)

final_nola_checkins <- bind_rows(nola_checkins)
saveRDS(final_nola_checkins, file = "nola_checkins.rds")


#reviews file
nola_reviews <- list()
stream_in(file("yelp_academic_dataset_review.json"), handler = function(df) {
    filtered <- df %>% filter(business_id %in% nola_businesses$business_id)
    if (nrow(filtered) > 0) {
    nola_reviews[[length(nola_reviews) + 1]] <<- filtered
  }
  
}, pagesize = 50000)

final_nola_reviews <- bind_rows(nola_reviews)
saveRDS(final_nola_reviews, file = "nola_reviews.rds")
rm(nola_reviews)
gc()
# Check that the file exists and check its size
file.exists("nola_reviews.rds")
file.size("nola_reviews.rds")

# Load and inspect
reviews_check <- readRDS("nola_reviews.rds")
dim(reviews_check) # Check number of reviews and columns
head(reviews_check, 2) # Preview top rows

#tip files
nola_tips <- list()
stream_in(file("yelp_academic_dataset_tip.json"), handler = function(df) {
    filtered <- df %>% filter(business_id %in% nola_businesses$business_id)
    if (nrow(filtered) > 0) {
    nola_tips[[length(nola_tips) + 1]] <<- filtered
  }
  
}, pagesize = 50000)
final_nola_tips <- bind_rows(nola_tips)
saveRDS(final_nola_tips, file = "nola_tips.rds")
rm(nola_tips)
gc()

# Verify file exists and check size
file.exists("nola_tips.rds")
file.size("nola_tips.rds")

# Load and inspect
tips_check <- readRDS("nola_tips.rds")
dim(tips_check)
head(tips_check, 2)

#users file
nola_user_ids <- unique(final_nola_reviews$user_id)
nola_users <- list()

stream_in(file("yelp_academic_dataset_user.json"), handler = function(df) {
  
  filtered <- df %>% filter(user_id %in% nola_user_ids)
    if (nrow(filtered) > 0) {
    nola_users[[length(nola_users) + 1]] <<- filtered
  }
  
}, pagesize = 50000)

final_nola_users <- bind_rows(nola_users)
saveRDS(final_nola_users, file = "nola_users.rds")
rm(nola_users)
gc()
# Check that the file exists and check its size
file.exists("nola_users.rds")
file.size("nola_users.rds")

# Load and inspect
users_check <- readRDS("nola_users.rds")
dim(users_check)
head(users_check, 2)