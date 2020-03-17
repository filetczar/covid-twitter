library(tidyverse)
install.packages('rtweet')
library(rtweet)
install.packages('tidyr')
library(tidyr)
install.packages('topicmodels')
library(topicmodels)


# set up users 
politicians <- c( 'GovMikeDewine', 
                 'GovPritzker', 'JoeBiden', 'BernieSanders', 
                 'CDCgov')

raw_tweets <- rtweet::get_timeline(politicians, n = 1500)
for(i in 1:length(cols)){
  if(class(raw_tweets[[i]]) == 'list'){
    raw_tweets[[i]] <- vapply(raw_tweets[[i]], paste, collapse = ", ", character(1L))
  }
}
write.csv(raw_tweets, 'pols_tweets.csv')
trump_tweets <- rtweet::get_timeline('realDonaldTrump', n=3200)

cols = names(raw_tweets)


