# https://cran.r-project.org/web/packages/seededlda/seededlda.pdf

devtools::install_github("quanteda/quanteda.corpora")
library(quanteda)
require(quanteda.corpora)
library(seededlda)
library(lubridate)


# Define dictionary
dict_topic = dictionary(list(economy=c("market*", "money", "bank*", "stock*", "bond*", "industry", "company", "shop*"), 
                politics=c("lawmaker*", "politician*", "election*", "voter*"),
                society=c("police", "prison*", "school*", "hospital*"),
                diplomacy=c('ambassador*', "diplomat*", "embassy", "treaty"),
                military=c("military", "soldier*", "terrorist*", "marine", "navy", "arymy")
                ))
print(dict_topic)


corp_news <- download("data_corpus_guardian")
corp_news_2016 <- corpus_subset(corp_news, year(date) == 2016)
ndoc(corp_news_2016)

toks_news <- tokens(corp_news_2016, remove_punct = TRUE, remove_numbers = TRUE, remove_symbol = TRUE)
toks_news <- tokens_remove(toks_news, pattern = c(stopwords("en"), "*-time", "updated-*", "gmt", "bst"))
dfmat_news <- dfm(toks_news) %>% 
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")

# Execute seeded LDA
tmod_slda <- textmodel_seededlda(dfmat_news, dictionary = dict_topic)
terms(tmod_slda, 20)
head(topics(tmod_slda), 20)

# assign topics from seeded LDA as a document-level variable to the dfm
dfmat_news$topic2 <- topics(tmod_slda)

# cross-table of the topic frequency
table(dfmat_news$topic2)
