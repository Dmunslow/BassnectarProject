#####################################
##### Get followers with rtweet #####
#####################################

library(rtweet)

# Get bassnectar info
lorin_info <- lookup_users("bassnectar")

######################### Fetch User IDs #######################################

# retreive initial user ids
basshead_IDs <- get_followers("bassnectar")

# set page for next iteration
page <- next_cursor(basshead_IDs)

# wait for rate limit reset 
Sys.sleep(60)*15


# Initialize loop variables
id_iterations <- (lorin_info$followers_count %/% 75000) + 1
iterations = 1

# Initiate loop to retreive follower ids
while(id_iterations > iterations){

    # Store new data in temporary data frame
    basshead_IDs_temp <- get_followers("bassnectar", page = page)

    # move cursor for next iteration
    page <- next_cursor(basshead_IDs_temp)
    
    # Add new data to existing ID data frame
    basshead_IDs <- rbind(basshead_IDs, basshead_IDs_temp)
    
    # Delete temporary DF
    rm(basshead_IDs_temp)
    
    iterations = iterations + 1
    
    # Retrieve rate limit info and pause loop until reset
    currentRL <- rate_limit(twitter_token)
    Sys.sleep(60 * (currentRL$reset[38]) + 1)
}

# Write the data to CSV
write.csv(basshead_IDs, "./follower_IDs.csv")

######################### Get User Data ########################################

# Get number of columns for user data DF
num_columns <- ncol(lorin_info)

# create bassheads df with 0 rows
bassheads <- data.frame(matrix(nrow = 0, ncol = num_columns))

# Assign column names to basshead DF
colnames(bassheads) <- colnames(lorin_info)

# initialize loop variables
info_interations <- (lorin_info$followers_count %/% 18000) + 1
info_index = 1

for(i in 1:info_interations){

    bassheads_temp <- lookup_users(basshead_IDs[info_index:(i*18000),])

    info_index = info_index + 18000

    # add data to basshead data frame
    bassheads <- rbind(bassheads_temp, bassheads)

    # Remove uneeded DF
    rm(bassheads_temp)

    # Get current RL
    currentRL <- rate_limit(twitter_token)

        # sleep until reset if RL is hit
        if(currentRL$remaining[36] < 180){
        
            # Pause R until ratelimit reset
            Sys.sleep(60* (as.integer(currentRL$reset[36])) + 1)
        }

}

# Write basshead info to CSV
write.csv(bassheads, "./basshead_df_raw.csv")

