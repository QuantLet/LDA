# https://cran.r-project.org/web/packages/seededlda/seededlda.pdf
# https://quanteda.io/reference/tokens.html
#devtools::install_github("quanteda/quanteda.corpora")
library(quanteda)
require(quanteda.corpora)
library(seededlda)
library(lubridate)
library(readtext)

# We map each quantlet to the Quantinar Target Topics

# Target Topics:
# Data Science
# Fintech
# Blockchain
# Explainable AI
# Machine Learning
# Cryptocurrency

wd = '/Users/Julian/src/LDA'
setwd(wd)

# Static
qlet_data = 'data/Quantlet_Database.json' #Quantlet json



# Define dictionary
dict_topic = dictionary(list(datascience=c("data mining", "analytics", "cluster", "Monte Carlo", "SQL", "predict*", "communication", "data clean*", "data science", "data management", "NLP", "natural language processing", "data visualization", "business intelligence", "BI", "random number", "stationary", "regression"), 
                             fintech=c("api", "regulatory", "regulatory technology", "regtech", "KYC", "AML", "fintech", "fin tech", "3D secure", "Chargeback", "Crowdfunding"),
                             blockchain=c("blockchain", "block chain", "block*", "coin", "consensus", "POW", "POS", "Proof of Work", "Proof of Stake", "Contract", "Smart Contract", "Cryptography", "Decentralization", "Fork", "Node", "Hash", "Mining", "Byzantine"),
                             explainableai=c('Explainable AI', "Explain*","XAI", "Transparency", "Audit*", "Transparent", "Concept*", "Concept Explanation", "Interpretability", "Econometric*"),
                             machinelearning=c("Machine Learning", "ML", "AI", "*Boost", "Tune", "Neural Network", "ARIMA", "NN", "Neural Network", "Deep Learning", "predict*", "LSTM","Supervise", "Classification", "Classifier", "Learner", "Robot", "Overfit*", "SVM", "Support Vector Machine", "Stationarity", "*starionar*", "Gradient Boost", "Boost", "Logistic Regression", "regression", "LDA", "Latent", "Topic Model*"),
                             cryptocurrency=c("crypto*", "Bitcoin", "BTC", "Ether*", "ETH", "Crypto Exchange", "Digital Currency", "Digicash", "Digital Wallet", "Wallet", "FIAT", "NFT", "Non-fundigble Token", "Stable Coin", "Stablecoin", "Tether", "USDT")
))
print(dict_topic)


qj = jsonlite::fromJSON(qlet_data)
#qj_unique = qj[qj$repo_name == unique(qj$repo_name),]

print("attention here")
# Instead of omitting information, we could also just merge the information that we have from the duplicate entries and afterwards select unique relevant_text statements
# So merge keywords and description of all rows where the identifier "repo_name" is the same
# pretty good idea actually.
# The other option would be to go line-by-line and only consider the relevant text of each row for itself. 

for(curr_repo in unique(qj$repo_name)[1:30]){
  print(curr_repo)
  print(qj[qj$repo_name == curr_repo,'keywords'])
  print('---')
}

# quantlet names are not unique!
qj_unique = qj[!duplicated(qj[,'repo_name']),]

# Construct Corpus from Quantlet JSON
qj_unique$relevant_text = paste(qj_unique$description, qj_unique$keywords)
q_corpus = corpus(qj_unique, text_field = 'keywords', docid_field = 'repo_name') #switch back to relevant_text!!
summary(q_corpus, n = 5)
ndoc(q_corpus)

toks_news_raw <- tokens(q_corpus, remove_punct = TRUE, remove_numbers = TRUE, remove_symbol = TRUE)
toks_news <- tokens_remove(toks_news_raw, pattern = c(stopwords("en"), "*-time", "updated-*", "gmt", "bst"))


##


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



# Tests

un_keywords = unique(qj$keywords)


# Inspect outcome for individual topics
tops = topics(tmod_slda)
tops[tops %in% c('cryptocurrency')]

# Save Output
qj_unique$assigned_topic = tops
write.csv(qj_unique, file = 'qlet_topics_assigned.csv')



# For Comparison
#old_results = qj_unique
