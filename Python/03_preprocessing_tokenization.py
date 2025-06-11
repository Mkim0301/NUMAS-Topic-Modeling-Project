
"""
Tokenization

This script performs tokenization, stopword removal, and word frequency analysis
for Korean text data using Mecab. It also saves the intermediate results in CSV and Excel formats.

Note:
- Make sure Mecab (Korean version v2.1.1) is installed.
- Requires a DataFrame `final_df` with columns 'text' and 'no'.
- Requires stopword lists: `k_stopword` and `one_char_keyword`.
"""

# ================================
# Mecab Initialization
# ================================

from konlpy.tag import Mecab
mecab = Mecab()  # Ensure Mecab Korean is installed

# ================================
# Imports and Environment Setup
# ================================

import os
import warnings
from collections import Counter
import csv
import pandas as pd
import numpy as np

# Ignore warnings
warnings.filterwarnings(action='ignore')

# ================================
# Directory Setup
# ================================

folder = "myfolder"
date = "date"
base_route = f"/ADHD/{folder}/"

if not os.path.exists(base_route):
    os.makedirs(base_route, exist_ok=True)

save_path = base_route + str(date)

# ================================
# Tokenization
# ================================

tokenized_list = [mecab.morphs(text) for text in final_df['text']]

# Save tokenized list to CSV
with open(f"{save_path} tokenized list.csv", 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerows(tokenized_list)

# Save tokenized list with original text and ID
token_data = list(zip(final_df['no'], final_df['text'], tokenized_list))
df_token = pd.DataFrame(token_data, columns=['no', 'text', 'tokenized_list'])
df_token.to_excel(f"{save_path} tokenized_list.xlsx", index=False)


# ================================
# Normalizaing Tokens
# ================================

tokenized_list = [[token if token not in ['우울증', '울증'] else '우울증' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['몸살감기', '몸살기'] else '몸살' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['불면증'] else '불면' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['겨땀'] else '겨드랑이' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['생기', '생겨', '생겨서', '생겨도', '나타나', '나타날', '나타났'] else '발생' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['힘든데'] else '힘든' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['못해서', '못해'] else '못해' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['약도'] else '약' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['음식물', '음식'] else '음식' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['으름'] else '게으름' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['얘기'] else '이야기' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['애미'] else '엄마' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['애비'] else '아빠' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['부진', '감퇴'] else '저하' for token in tokens] for tokens in tokenized_list]

tokenized_list = [[token if token not in ['저리', '저림', '저려', '저려서', '저려온다', '저린', '저린다고', '저린다', '저렸'] else '저림' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['줄어듦', '줄어드', '줄어든', '줄어든다', '줄어든다는', '줄어든다고', '줄어야', '줄어진'] else '줄어들' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['줄였', '줄여', '줄여야', '줄여서', '줄여도', '줄여라', '줄여볼까', '줄여본', '줄여보', '줄여줄'] else '줄여' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['무서움', '무서워', '무서워서', '무서운', '무서웠', '무서운데', '무서울', '무서워하', '무서', '무서우', '무서워했', '무서워졌', '무서워요', '무서워해서', '무서웠어', '무서운지', '무서워한', '무서버', '무서워져', '무서워진다', '무서우면서도', '무서워할', '무서워합니다'] else '무섭' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['흐리', '흐리멍텅', '흐린', '흐린다고', '흐려', '흐려져서', '흐려서', '흐려진', '흐려졌', '흐려진다', '흐려짐', '흐려진다는', '흐려져', '흐려집니다'] else '흐려' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['멍청', '멍청이'] else '멍청' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['멍해', '멍한', '멍하니', '멍때', '흐리멍텅', '멍하', '멍해진', '멍해서', '멍했', '멍해진다', '멍해졌', '멍할', '멍해질', '떄멍떄림'] else '멍해' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['괴롭힘', '괴롭히', '괴롭혔', '괴롭힌', '괴롭혀', '괴롭힐', '괴롭혀왔', '괴롭혀서', '괴롭힌다'] else '괴롭힘' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['괴롭', '괴로워', '괴로워할', '괴로워도', '괴로우', '괴로워했', '괴로울', '괴로워하', '괴로워서', '괴로웠', '괴로워', '괴로운'] else '괴로움' for token in tokens] for tokens in tokenized_list]

tokenized_list = [[token if token not in ['시달린', '시달려', '시달린다고', '시달려도', '시달렸었', '시달린다', '시달려야', '시달려서', '시달림', '시달렸'] else '시달리' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['망치', '망하', '망했', '망해', '망한', '망함', '망해서', '망침', '망쳐', '망쳤'] else '망했' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['헛구역', '구역감', '헛구역질', '구역질', '헛구역질이'] else '구역감' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['고치', '고쳐', '고쳐야', '고쳐졌', '고쳐질', '고쳐져서', '고쳐진', '고쳐서', '고쳐져', '고쳐라', '고쳐도', '고쳐진다는', '고칠', '고침', '고쳐야'] else '고쳐' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['올라가', '올라감', '올라간', '올라갈', '올라갔', '올라간다', '올라간다는'] else '올라가' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['올라오', '올라와', '올라옴', '올라올', '올라온다', '올라온', '올라와서', '올라왔'] else '올라오' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['떠올라', '떠오를', '떠오른다', '떠오른', '떠오름', '떠오르'] else '떠오르' for token in tokens] for tokens in tokenized_list]

tokenized_list = [[token if token not in  ['돌아가', '돌아간', '돌아갈', '돌아갔', '돌아간다', '되돌아갈', '돌아간다는', '되돌아가'] else '돌아감'  for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in  ['돌아오', '돌아와', '돌아올', '돌아온다', '돌아온', '되돌아옴', '되돌아오', '돌아와서', '돌아왔'] else '돌아옴'  for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in  ['돌아다녀', '돌아다니', '돌아다녀야', '떠돌아다니', '돌아다녀서', '돌아댕기', '싸돌아다니', '돌아다닌다', '돌아다녔', '돌아다님', '돌아다니'] else '돌아다님'  for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in  ['돌아봤', '돌아볼', '되돌아보', '돌아보'] else '돌아봄'  for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in  [ '두근거리', '두근두근', '두근', '두근대', '두근거려서', '두근거린다', '두근거려', '두근거릴', '두근거렸', '두근댄다'] else '두근거림' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in  ['느껴졌', '느껴진다', '느껴져', '느껴질', '느껴본', '느껴진', '느껴집니다', '느껴야', '느껴진다고', '느껴졌었', '느껴도', '느껴진다는', '느껴왔', '느껴요', '느껴질까', '느껴져요', '느껴져도', '느껴져야', '느껴진다면', '느껴진다거나', '느껴졌으나', '느껴봐야', '느껴왔으니까'] else '느껴' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in  ['새로운', '새로', '새로이', '새로워', '새로운가'] else '새로운'  for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in  ['어렵', '어려운', '어려워', '어려웠', '어려워서'] else '어려움'  for token in tokens] for tokens in tokenized_list]

tokenized_list = [[token if token not in ['더러운', '더러운', '더러워서', '더러워', '더러워지', '더러웠', '더러우', '더러워졌', '더러워질', '더러워진', '더러워져서'] else '더러움' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['사라졌', '사라진', '사라지', '사라짐', '사라져서', '사라져', '사라질', '사라진다', '사라진다는', '사라졌었', '사라진다고', '사라졌으면', '사라져도', '사라져야', '사라집니다', '사라져라', '사라질지', '사라져간다'] else '사라짐' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['그만두', '그만둬', '그만뒀', '그만둘', '그만둬야', '그만둘까', '그만둬', '그만둔다고', '그만둬도', '그만둔다', '그만둬요'] else '그만둠' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['떨어지', '떨어짐', '떨어진', '떨어질', '떨어졌', '떨어져', '떨어진다', '떨어진다고', '떨어진다는', '떨어져도', '떨어질까', '떨어져서'] else '떨어짐' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['나아지', '나아진', '나아졌', '나아질', '나아질까', '나아져', '나아진다', '나아졌으면', '나아질지', '나아져야', '나아요'] else '나아짐'
 for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['심해서', '심해져서', '심해진', '심해졌', '심해질', '심해져', '심해진다'] else '심해짐' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['바꾸', '바꿔', '바꿔야', '바꿔서', '바꿀', '바꿔도', '바꿔라', '바꿔야지', '바꿔야겠어', '바꿀라', '바꿀지', '바꿀려고', '바꿀까', '바꿀'] else '바뀜' for token in tokens] for tokens in tokenized_list]
tokenized_list = [[token if token not in ['옮기', '옮겨', '옮길', '옮겼', '옮겨야', '옮긴', '옮길까', '옮겨서', '옮긴다고', '옮겨라', '옮겼었', '옮겨감', '옮겨짐', '옮겨도', '옮겨다닐'] else '옮김' for token in tokens] for tokens in tokenized_list]



# ================================
# Stopword Removal
# ================================

def remove_stopword(tokens):
    review_removed_stopword = []
    for token in tokens:
        if len(token) > 1:
            if token not in list(k_stopword['stopword']):
                if token.isdigit():
                    continue
                review_removed_stopword.append(token)
        else:
            if token in list(one_char_keyword['one_char_keyword']):
                review_removed_stopword.append(token)
    return review_removed_stopword

cleaned_list = [remove_stopword(tokens) for tokens in tokenized_list]

# Remove corpora with less than 3 unique tokens
drop_indices = [i for i, tokens in enumerate(cleaned_list) if len(set(tokens)) < 3]
final_df.drop(index=drop_indices, inplace=True)
final_df.reset_index(drop=True, inplace=True)

# Remove corresponding entries in cleaned_list
cleaned_list = [tokens for i, tokens in enumerate(cleaned_list) if i not in drop_indices]

# ================================
# Save Cleaned Tokens as cleaned_list
# ================================

combined_data = list(zip(final_df['no'], final_df['text'], cleaned_list))
df_combined = pd.DataFrame(combined_data, columns=['no', 'text', 'cleaned_tokens'])
df_combined.to_excel(f"{save_path} cleaned list.xlsx", index=False)

with open(f"{save_path} cleaned list_copy.csv", 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['no','text', 'cleaned_tokens'])
    writer.writerows(combined_data)

# ================================
# Word Frequency Analysis
# ================================

flat_list = [item for sublist in cleaned_list for item in sublist if isinstance(item, (str, int, float))]
word_counts = Counter(flat_list)
sorted_counts = word_counts.most_common()

df_word_counts = pd.DataFrame(sorted_counts, columns=['Word', 'Count'])
df_word_counts.to_excel(f"{save_path} token word count.xlsx", index=False)

with open(f"{save_path} token word count.csv", 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['Word', 'Count'])
    writer.writerows(sorted_counts)

# ================================
# Final Printouts for Validation
# ================================

print(f"Total number of cleaned posts: {len(cleaned_list)}")
