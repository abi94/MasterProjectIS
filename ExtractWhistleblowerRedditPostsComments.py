#!/usr/bin/env python
# coding: utf-8

# In[15]:


import praw
import csv
import requests
from datetime import datetime, timedelta
from numba import njit


# In[16]:


#Login with credentials to the App 
#Reddit API
reddit = praw.Reddit(
client_id = 'KEogXJHap1nKNfd1u6IpNA',
client_secret='5dOZZ63Wi57e3YaGNIHJDLAu3pzrjg',   
user_agent = 'my-app by u/Competitive-Shock179'  
)


# In[19]:


import pandas as pd
pd.set_option('max_colwidth', None)


# In[77]:


#Code section to test whether for the keywords in the list with the given subreddits, all the relevant values with their
#respective columns gets added to the WBlist

WBlist = []

#Searching the subriddit first in tech subreddit, then technology subreddit and so on...
subreddit = reddit.subreddit('technology')

#Keywords related to Tech and Whisteblowing
keywords = [
    'Facebook_whistleblower', 'Facebook_whistleblow', 'Facebook_whistleblowing',
    'Twitter_whistleblow', 'twitter_whistleblowing', 'Twitter_whistleblower',
    'google_whistleblow', 'google_whistleblowing', 'Google_whistleblower',
    'Instagram_whistleblow', 'instagram_whistleblowing', 'Instagram_whistleblower',
    'Meta_whistleblow', 'meta_whistleblowing', 'Meta_whistleblower',
    'Alphabet_whistleblow', 'alphabet_whistleblowing', 'Alphabet_whistleblower',
    'Netflix_whistleblow', 'netflix_whistleblowing', 'Netflix_whistleblower',
    'Amazon_whistleblower', 'Amazon_whistleblow', 'Amazon_whistleblowing',
    'Microsoft_whistleblow', 'microsoft_whistleblowing', 'Microsoft_whistleblower',
    'Tech_whistleblow', 'tech_whistleblowing', 'Tech_whistleblower',
    'Software_whistleblow', 'software_whistleblowing', 'Software_whistleblower',
    'Whistleblow_software_industry', 'Whistleblowing_software_industry', 'Whistleblower_software_industry',
    'Uber_whistleblower', 'Uber_whistleblow', 'Uber_whistleblowing',
    'Tiktok_whistleblower', 'Tiktok_whistleblow', 'Tiktok_whistleblowing',
    'Apple_whistleblower', 'Apple_whistleblow', 'apple_whistleblowing'
]


for keyword in keywords:
    for submission in subreddit.search(keyword, time_filter='all', limit=None):
        WBlist.append(submission.id)
        WBlist.append(submission.title)
        WBlist.append(submission.num_comments)
        WBlist.append(submission.subreddit)


# In[79]:


WBlist


# In[81]:


len(set(WBlist))


# In[51]:


#Code section to search all the posts in the given subreddit list 'subreddits'
#This code collects all the posts in one go from the subreddits and not in Batches
data = []
dataFramePosts = []
postIDs = []

#File containing all the relevant keywords related to whistleblowing
with open('Keywords_list_WB.txt', 'r') as file:
   lines = file.readlines()

WhistleblowingWords = [line.strip() for line in lines]

subreddits = ['technology','tech','technews','worldnews','news','programming','privacy','politics','google','cybersecurity']  

for subreddititem in subreddits:
    
    subreddit = reddit.subreddit(subreddititem)

    for keywordWB in WhistleblowingWords:            
            creationdateStr = datetime.utcfromtimestamp(int(post.created_utc)).strftime('%Y-%m-%d %H:%M:%S UTC')
            for post in subreddit.search(keywordWB, time_filter='all', limit=None):
                dataFramePosts.append([post.id, post.title, post.selftext, post.num_comments,creationdateStr,post.subreddit])

            ResDFrame = pd.DataFrame(dataFramePosts,columns=['id','title','selftext','num_comments','creationdatestr','subreddit'])
            ResDFrame = ResDFrame.drop_duplicates()


# In[53]:


#This code collects all the posts in batches by manually specin order to not encounter TooManyRequests: received 429 HTTP response
data = []
dataFramePosts = []
postIDs = []

#File containing all the relevant keywords related to whistleblowing
with open('Keywords_list_WB.txt', 'r') as file:
   lines = file.readlines()

WhistleblowingWords = [line.strip() for line in lines]

subreddit = reddit.subreddit('technology') #,'tech','technews','worldnews','news','programming','privacy','politics','google','cybersecurity'] 

for keywordWB in WhistleblowingWords:            
        creationdateStr = datetime.utcfromtimestamp(int(post.created_utc)).strftime('%Y-%m-%d %H:%M:%S UTC')
        for post in subreddit.search(keywordWB, time_filter='all', limit=None):
            dataFramePosts.append([post.id, post.title, post.selftext, post.num_comments,creationdateStr,post.subreddit])

        ResDFrame = pd.DataFrame(dataFramePosts,columns=['id','title','selftext','num_comments','creationdatestr','subreddit'])
        ResDFrame = ResDFrame.drop_duplicates()


# In[75]:


ResDFrame


# In[85]:


ResDFrame.to_csv("Whistleblowingdata_posts1.csv", index=False) #Writing the collected posts into a CSV File


# In[1046]:


#CodeSection that generates a random subset of a Pandas Dataframe.
import pandas as pd
import random

def random_subset(dataframe, size):

    if size > len(dataframe):
        raise ValueError("The subset size is larger than DataFrame size.")

    indices = random.sample(range(len(dataframe)), size)
    
    subset = dataframe.iloc[indices]
    
    subset.to_csv("randomsampledataframe.csv", index=False)
    
    return subset


# In[ ]:


random_subset(dataframe,353)


# In[ ]:


len(dfPost)


# In[ ]:


len(set(dfPost))


# In[ ]:


ResDFrame.nunique()


# In[318]:


dataframe_wistleblowing = pd.read_csv('WBDatasetstec.csv')


# In[320]:


dataframe_wistleblowing = dataframe_wistleblowing.drop_duplicates(subset = "title")


# In[ ]:


dataframe_wistleblowing


# In[314]:


dataframe = pd.read_csv('WBDatasetstec.csv')


# In[ ]:


dataframe


# In[324]:


dataframe_wistleblowing.to_csv("WBDatasetstec_NoDuplicates.csv", index=False)


# In[ ]:


dataframe_wistleblowing["title"].nunique()


# In[ ]:


#Code section of merging all the csvs files containing posts collected in batches from the various subreddits
import pandas as pd
import glob

directory_path = '/Users/abi94/Documents/Sample/'

file_pattern = '*.csv'

file_list = glob.glob(directory_path + file_pattern)

print(file_list)

dfs = []

for file in file_list:
    df = pd.read_csv(file)
    dfs.append(df)

merged_df = pd.concat(dfs, ignore_index=True)

# Write the merged dataframe to a new CSV file
merged_df.to_csv('CommentsSubredTechAndTechnews.csv', index=False)

print("Merged CSV files saved as 'CommentsSubredTechAndTechnews.csv'")


# In[ ]:


WBlist


# In[ ]:


#Code section to collect all the comments from the posts retrieved using the postIDs

dfComment = []

csvfilepath = 'WhistleblowingDatasetPosts.csv' #Dataset containing the posts collected previously

def calccommentcontroversiality(comment):
    totalvotes = comment.ups + comment.downs
    score = comment.score
    return totalvotes / max(totalvotes, score, 1)

with open(csvfilepath, 'r', newline='') as file:
    reader = csv.reader(file)
    for row in reader:
        postid = row[0]
        posttitle = row[1]
        try:
            submission = reddit.submission(id=postid)
            submission.comments.replace_more(limit=None)
            for comment in submission.comments.list():
                if comment.depth == 0:
                    print(postid)
                    controversialitycomment = calccommentcontroversiality(comment)
                    dfComment.append([postid,posttitle,comment.id,comment.body,comment.score,comment.ups,comment.downs,controversialitycomment,comment.author,comment.subreddit,str(datetime.fromtimestamp(comment.created_utc))])                   
                
        except praw.exceptions.APIException as e:
            if e.error_type == 'RATELIMIT':
                print("Rate limited. Waiting before retrying...")
                time.sleep(60)
                continue
            else:
                print(f"Error occurred: {e}")
        except praw.exceptions.ClientException as e:
            print(f"Error occurred while processing post {postid}: {e}")
        except Exception as e:
            print(f"Error occurred while processing post {postid}: {e}")


# In[726]:


ResDFrame = pd.DataFrame(dfComment,columns=['PostID','Posttitle','CommentID','body','score','ups','downs','comment_controversiality','author','subreddit','comment_date'])


# In[728]:


ResDFrame


# In[730]:


ResDFrame.to_csv("CommentsWB_1.csv", index=False)


# In[ ]:




