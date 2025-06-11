# NUMAS-Topic-Modeling-Project

This repository contains the full pipeline for analyzing nonmedical use of methylphenidate (MPH) for academic purposes using topic modeling on Korean online forum data.

---

## 📚 Study Overview

The dataset was collected from the **"ADHD Minor Gallery"** on **DCinside**, one of South Korea's largest online forums. With official permission from DCinside, a total of **75,190 posts** from **January 1, 2021 to December 31, 2022** were used.

A two-step filtering process was applied to extract relevant content:

1. **MPH keyword filtering**: Detect mentions of methylphenidate and its brand names (e.g., "Concerta", "Bisphentin", "Medikinet").
2. **Academic-use filtering**: Retain posts related to studying, exams, or academic stress (e.g., “CSAT”, “quiz”, “report”).

We conducted topic modeling using **Latent Dirichlet Allocation (LDA)** and visualized results with **pyLDAvis**. Topic coherence was evaluated using the **NPMI metric**.

---

 
## 🧾 Data Format
❗ Due to ethical and privacy concerns, raw data is not shared publicly.


---

## 📂 Code and Data Structure

```bash
.
├── R/
│   └── 01_pre_cleaning.R                 # R script: text cleaning, normalization, formatting
│
├── python/
│   ├── 02_preprocessing_2-step_filtering.py    # Filters data by MPH drug mentions and study-related keywords
│   ├── 03_preprocessing_tokenization.py        # Tokenizes text using MeCab, removes stopwords, normalization, creates frequency tables
│   └── 04_lda_topic_modeling.py                # Performs LDA, coherence evaluation (NPMI), and pyLDAvis visualization
│
├── data/
│   ├── product_ingredient.xlsx           # Brand-to-ingredient mapping dictionary
│   ├── k_stopword.xlsx                   # Korean stopword list
│   └── one_char_list.xlsx                # One-character tokens to inlude
│
└── README.md                             # This file

```
## 🔎 Required Files and Resources

### `02_preprocessing_2-step_filtering.py`
- Replaces brand names with active ingredient names using `product_ingredient.xlsx`  

---

### `03_preprocessing_tokenization.py`
⚠️ **Note:** MeCab-Ko (v2.1.1+) must be installed for Korean tokenization.
- Stopword removal (`k_stopword.xlsx`)  
- Removal of one-character tokens (`one_char_list.xlsx`)  

---



