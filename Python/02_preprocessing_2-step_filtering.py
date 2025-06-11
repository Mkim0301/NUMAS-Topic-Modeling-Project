"""
MPH Study - 2-Step Filtering Script

This script performs a two-step filtering process:
1. Replaces drug brand names with their corresponding active ingredient names, then filters for posts mentioning 'methylphenidate' (메틸페니데이트).
2. Further filters posts related to academic performance (e.g., exam, study, CSAT).

Note:
- Input: 'clean.csv' with raw_text columns
- Drug mapping: 'product_ingredient.xlsx' with ['약품명', '성분명']
"""

import re
import pandas as pd
import os

# ================================
# Directory Setup
# ================================

folder = "myfolder"
date = "date"
base_route = f"/ADHD/{folder}/"
os.makedirs(base_route, exist_ok=True)
save_path = base_route + str(date)

# ================================
# Load Data
# ================================

df = pd.read_csv('/ADHD/Save/clean.csv')
drug = pd.read_excel('/ADHD/Save/product_ingredient.xlsx')

drug_dict = dict(zip(drug['약품명'], drug['성분명']))
df['raw_text2'] = df['raw_text']

# ================================
# Step 1: Replace Brand Names
# ================================

def replace_words(row):
    text = row['raw_text2']
    for brand, ingredient in drug_dict.items():
        if brand in text:
            text = text.replace(brand, ingredient)
    return text

df['raw_text2'] = df.apply(replace_words, axis=1)

# ================================
# Filter 1: Contains Methylphenidate
# ================================

pattern = r'\\b메틸페니데이트\\b'
df['MPH'] = df['raw_text2'].apply(lambda x: '1' if re.search(pattern, x) else '0')
df_mph = df[df['MPH'] == '1']

print(f"Number of posts mentioning MPH: {len(df_mph)}")

# ================================
# Step 2: Filter Academic-related Posts
# ================================

keywords = ['시험', '수능', '고시', '고사', '모의고사', '기말고사', '중간고사', '학점', 'n수', 'n수생',
            '실기', '공부', '학습', '학업', '보고서', '퀴즈', '숙제', '과제', '수험',
            '입시', '취업', '성적', '정시', '점수', '공무원_시험']

df_mph['study'] = df_mph['raw_text2'].apply(lambda x: 1 if any(k in x for k in keywords) else 0)
df_final = df_mph[df_mph['study'] == 1]

print(f"Number of academic-related MPH posts: {len(df_final)}")

# ================================
# Save Output
# ================================

df_final.to_excel(save_path + 'filtered_mph_study_posts.xlsx', index=False)
