# Auto-generating labels for Quantlets based on Metadata specified in a MySQL database. 

1) Either execute "LDA_label.R" or "runR.py". The latter is just a wrapper to execute the former in python.
2) Execute db.py

Afterwards, the labeled data is saved in a new table called "metadata_labeled" in the MySQL database.



# Config
in the R Script, you may specify whether to base the LDA algo on "keywords" specified by the author of the respective quantlet or by a combination of "keywords" and "description". 
Of course, further amendments are possible. 

 
