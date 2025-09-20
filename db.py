from sqlalchemy import create_engine # using: pip install sqlalchemy==1.4.46
import pandas as pd
from config import HOST, USER, PASSWORD, DB


if __name__ == '__main__':

    # Config loaded on locally from config.py.
    # This is only the config required to power up the DB.

    # Further Config:
    # Table Name of labeled / tagged metadata table
    output_table_name = 'metadata_labeled'
    tag_file_name = 'qlet_topics_assigned_v2.csv'

    # Load metadata table from mysqldb
    engine = create_engine("mysql+pymysql://{user}:{pw}@localhost/{db}"
                    .format(user=USER,
                            pw=PASSWORD,
                            db=DB))

    # Connect and load metadata table
    query = ("select * from metadata;")
    metadata_table = pd.read_sql(query, con = engine)
    
    # Load LDA output (with tags/labels)
    tag_df = pd.read_csv(tag_file_name)

    # Keep tag/label and join keys
    tag_sub = tag_df[['id','assigned_topic']]

    # Merge on ID
    # Alternatively: Merge on name_of_quantlet and repo_name
    tagged = metadata_table.merge(tag_sub, on = ['id'], how = 'left')

    # Save to MySQL
    # OVERWRITING table if it exists already
    tagged.to_sql(name = output_table_name, con = engine, if_exists='replace', index=False)



