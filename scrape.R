library(tidyverse)
install.packages('rtweet')
library(rtweet)
install.packages('tidyr')
library(tidyr)
install.packages('topicmodels')
library(topicmodels)
library(lubridate)
library(stringr)
install.packages('tidytext')
library(tidytext)
data(stop_words)


# set up users 
politicians <- c( 'GovMikeDewine', 
                 'GovPritzker', 'JoeBiden', 'BernieSanders', 
                 'CDCgov')

raw_tweets <- rtweet::get_timeline(politicians, n = 1500)


cols = names(raw_tweets)
for(i in 1:length(cols)){
  if(class(raw_tweets[[i]]) == 'list'){
    raw_tweets[[i]] <- vapply(raw_tweets[[i]], paste, collapse = ", ", character(1L))
  }
}
write.csv(raw_tweets, 'pols_tweets.csv')

# need to wait a day for api requests 
trump_tweets <- rtweet::get_timeline('realDonaldTrump', n=3200)
cols = names(trump_tweets)
for(i in 1:length(cols)){
  if(class(trump_tweets[[i]]) == 'list'){
    trump_tweets[[i]] <- vapply(trump_tweets[[i]], paste, collapse = ", ", character(1L))
  }
}
write.csv(trump_tweets, 'trumps_tweets.csv')


all_data = raw_tweets %>% bind_rows(trump_tweets) %>%  distinct()

# filter to key words 
# make into tidyformat 
# document (twitter), words
s_dttm = lubridate::as_datetime('2020-02-01')
test = trump_tweets %>% mutate(r = row_number()) %>%  filter(r <= 150)

clean_n_tidy <- function(words = c('covid', 'coronavirus', 'virus', 
                                  'pandemic', 'flu', 'quarantine', 'social distance', 'social distancing', 
                                  'covid19', 'covid-19', 'epidemic', 'illness', 'sick', 'sickness', 
                                  'corona'), 
                        start_date = s_dttm, 
                        other_stops = tibble('word' = c('https', 't.co', 'amp')),
                        data = test){
  
  tidy_fmt = all_data %>% 
                  filter(created_at >= s_dttm) %>% 
                  mutate(text = tolower(text)) %>% 
                  filter(stringr::str_detect(text, paste(words, collapse = '|'))) %>% 
                  select(screen_name, text) %>% 
                  unnest_tokens(word,text) %>% 
                  anti_join(stop_words, by = 'word') %>% 
                  anti_join(other_stops, by = "word") %>% 
                  group_by(screen_name, word) %>% 
                  summarize(count = n())
  
  doc_term_mtx = cast_dtm(tidy_fmt, screen_name, word, count)
  
  
  return_list = list('tidy' =tidy_fmt, 'dtm' = doc_term_mtx)
  
  return(return_list)
  
          }

test_list = clean_n_tidy(data = all_data)  



test_lda = LDA(test_list[[2]], k=4,  control = list(seed = 123))


tidy(test_lda, matrix = 'beta') %>% 
              group_by(topic) %>% 
              top_n(10, beta) %>% 
              ungroup() %>% 
              arrange(topic, desc(beta)) %>% 
  View()




