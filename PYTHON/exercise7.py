import psycopg2
import pandas as pd
import matplotlib.pyplot as plt

# connect DB
try:
    conn = psycopg2.connect(
        host="linkby-hiring.ckjp7onx6q9c.ap-southeast-2.rds.amazonaws.com",
        port="5432",
        database="linkby",
        user="applicant",
        password="LinkbyHiring2024"
    )
    print("Connected to PostgreSQL database!")
except psycopg2.Error as e:
    print("Error connecting to PostgreSQL database:", e)

# create cursor to execute queries
try:
    cursor = conn.cursor()
except psycopg2.Error as e:
    print("Error creating cursor:", e)


# SQL queries to select data from tables
campaigns_query = "SELECT * FROM campaigns"
campaign_publishers_query  = "SELECT * FROM campaign_publishers"
accounts_query = "SELECT id, type,profile -> 'country' as country  FROM accounts"
# Load data into DataFrames
try:
    # loading campaigns data into df
    c_df = pd.read_sql_query(campaigns_query, conn)
    c_df.rename(columns={'id': 'campaign_id', 'accountId': 'account_id'}, inplace=True)

    # loading campaign_publisher data into df
    cp_df = pd.read_sql_query(campaign_publishers_query, conn)
    cp_df.rename(columns={'campaignId': 'campaign_id'}, inplace=True)

    # loading accounts data into df
    a_df = pd.read_sql_query(accounts_query, conn)
    a_df.rename(columns={'id': 'account_id'}, inplace=True)
    
    # filtering advertiser and publisher data into seperata dfs
    advertiser_df = a_df[a_df['type']==1]
    publisher_df = a_df[a_df['type']==2]
    
    print("Data loaded into DataFrames successfully!")
except pd.errors.DatabaseError as e:
    print("Error loading data into DataFrames:", e)

# Close the database connection
conn.close()


merged_df = pd.merge(c_df, cp_df, on='campaign_id', how='inner')

def Performance_Metrics():
    budget_alocated_by_advertiser_account = merged_df.groupby('account_id')['budget_x'].sum().reset_index()
    budget_accepted_by_publisher_account = merged_df.groupby(['account_id','publisherId'])['budget_y'].sum().reset_index()
     
    budget_alocated_by_advertiser_account.to_csv("../output/exercise_7_budget_allocated_by_advertiser.csv")
    budget_accepted_by_publisher_account.to_csv("../output/exercise_7_budget_accepted_by_publisher.csv")

def Performance_by_Region_and_visualisation():
    df_advertiser = pd.merge(merged_df, a_df, on='account_id', how='left')
    df_advertiser = df_advertiser.rename(columns={'country': 'advertiser_country'})

    # Merge df with df_country for publisher_country
    df_publisher = pd.merge(merged_df, a_df, left_on='publisherId', right_on='account_id', how='left')
    df_publisher = df_publisher.rename(columns={'country': 'publisher_country'})

    advertiser_summary = df_advertiser.groupby('advertiser_country').agg(
        total_budget=('budget_x', 'sum'),  # Assuming 'advertiser_id' represents budget
        num_campaigns=('campaign_id', 'count')
    ).reset_index()

    publisher_summary = df_publisher.groupby('publisher_country').agg(
        total_budget=('budget_y', 'sum'),  # Assuming 'advertiser_id' represents budget
        num_campaigns=('campaign_id', 'count')
    ).reset_index()

    # advertiser_summary.to_csv("../output/exercise_7_advertiser_summary.csv")
    # publisher_summary.to_csv("../output/exercise_7_publisher_summary.csv")


    advertiser_summary.plot(kind='bar', x='advertiser_country', y='total_budget', title='Total Budget by Country')
    plt.xlabel('advertiser_country')
    plt.ylabel('total_budget')
    plt.show()

    
    publilsher_budget_accross_regions = merged_df.groupby(['publisher_country', 'publisherId'])['budget_y'].sum().reset_index()

    # Sort the publishers within each country by total budget in descending order
    publilsher_budget_accross_regions['rank'] = publilsher_budget_accross_regions.groupby('publisher_country')['budget_y'].rank(method='dense', ascending=False)
    top_publishers = publilsher_budget_accross_regions[publilsher_budget_accross_regions['rank'] <= 10]
    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(12, 4))

    for i, (country, ax) in enumerate(zip(top_publishers['Country'].unique(), axes)):
        data_country = top_publishers[top_publishers['Country'] == country]
        ax.bar(data_country['Publisher'], data_country['Budget'])
        ax.set_title(f'Top 10 Publishers in {country}')
        ax.set_xlabel('Publisher')
        ax.set_ylabel('Total Budget')

    plt.tight_layout()
    plt.show()