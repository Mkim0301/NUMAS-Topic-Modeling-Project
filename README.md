# NUMAS-Topic-Modeling-Project

This repository contains the analysis for our study on academic-oriented nonmedical use of methylphenidate (NUMAS) based on online forum discussions.

## 📚 Study Overview

The dataset used for this study was collected from the **“ADHD Minor Gallery”** on DCinside, one of Korea’s largest online forums. A total of **75,190 posts** from **January 1, 2021 to December 31, 2022** were collected.

A two-step filtering process was applied:
1. **MPH keyword filter** (e.g., "Concerta", "Bisphentin", "Metadate")  
2. **Academic-use-related terms** (e.g., “study”, “exam”, “CSAT”, “quiz”, “report”)  

We performed topic modeling using **Latent Dirichlet Allocation (LDA)**.

## Contents
- Data pre-processing
- Tol
- Topic modeling with LDA

## Code Structure

- `R/`: Scripts for data loading and preprocessing
  - `01_preprocess_data.R`: Loads raw data and prepares the input dataframe
- `python/`: Scripts for topic modeling and visualization
  - `02_topic_modeling.py`: Performs LDA topic modeling using 
  - `03_visualize_topics.py`: Plots interactive topic maps using pyLDAvis

## 🧾 Data Format

> **Note:** Due to privacy and ethical considerations, the dataset is **not publicly shared**.
However, to reproduce the code, your dataset must follow this format:

```r
df <- data.frame(
  title = character(),
  dates = as.Date(character()),
  comments = character(),
  URL = character()
)
