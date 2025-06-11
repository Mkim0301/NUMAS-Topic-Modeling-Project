# ==========================================
# LDA Topic Modeling / Inter-topic distance mapping / NPMI validation
# ==========================================
"""
This script performs LDA topic modeling on preprocessed Korean text data.
It includes:
- Loading tokenized and cleaned text
- Running LDA with a range of topic numbers
- Saving top topic terms
- Calculating and saving document-topic probabilities
- Visualizing topics with pyLDAvis (Inter-topic distance mapping)
- Evaluating topic coherence scores using NPMI

Requirements:
- 'final_df' must contain a column named 'cleaned_list' (stringified list of tokens)
- Define 'Route' directory path before running this script
- Requires installed libraries: gensim, pandas, numpy, pyLDAvis, ast
"""

# ================================
# Create 'cleaned_list' from stringified tokens
# ================================
cleaned_list = []
for row in final_df['cleaned_list']:
    tokens = ast.literal_eval(row)
    cleaned_list.append(tokens)

print(cleaned_list[10])

# Use a fresh DataFrame for each iteration
df = final_df

# ================================
# Define LDA parameters
# ================================
start_topic = 2         # minimum number of topics
end_topic = 25          # maximum number of topics
PASSES = 9              # number of passes (epochs) over the corpus
NUM_WORDS = 25          # number of top words to extract per topic

# ================================
# LDA modeling function
# ================================
def lda_modeling(cleaned_list, seed=42):
    dictionary = corpora.Dictionary(cleaned_list)
    dictionary.filter_extremes(no_below=10)  # only keep tokens that appear in at least 10 documents
    corpus = [dictionary.doc2bow(review) for review in cleaned_list]

    model = gensim.models.ldamodel.LdaModel(
        corpus,
        num_topics=topic_num,
        id2word=dictionary,
        passes=PASSES,
        random_state=seed
    )
    return model, corpus, dictionary

# ================================
# LDA visualization function
# ================================
def lda_visualize(model, corpus, dictionary, topic_num):
    pyLDAvis.enable_notebook()
    result_visualized = pyLDAvis.gensim_models.prepare(model, corpus, dictionary)
    pyLDAvis.display(result_visualized)
    RESULT_FILE = Route + ' no' + str(topic_num) + ' LDAvis.html'
    pyLDAvis.save_html(result_visualized, RESULT_FILE)

# ================================
# Save top keywords for each topic
# ================================
def save_top_terms(cleaned_list, topic_num, model, dictionary):
    result_df = pd.DataFrame()
    for i in range(1, topic_num + 1):
        topic_terms = model.get_topic_terms(i - 1, topn=30)
        topic_terms = [dictionary.get(term[0]) for term in topic_terms]
        result_df[f'Topic {i}'] = topic_terms

    result_df.to_excel(Route + f' Topic {topic_num}_top_30_terms.xlsx', index=False)

# ================================
# Calculate topic probabilities per document
# ================================
def calculate_topic_probabilities(load_df, cleaned_list, topic_num, model, dictionary):
    for idx, tokens in enumerate(cleaned_list):
        bow = dictionary.doc2bow(tokens)
        topic_probs = model.get_document_topics(bow)
        topic_prob_dict = {i + 1: 0.0 for i in range(topic_num)}
        for prob in topic_probs:
            topic_id = prob[0] + 1
            topic_prob_dict[topic_id] = prob[1]

        for i in range(1, topic_num + 1):
            load_df.at[idx, f'Topic {i}'] = topic_prob_dict[i]

        sorted_topics = sorted(topic_prob_dict.items(), key=lambda x: x[1], reverse=True)
        primary_topic, primary_prob = sorted_topics[0]

        primary_topic_count = sum(1 for _, prob in sorted_topics if prob == primary_prob)
        if primary_topic_count > 1:
            primary_topic = -1

        secondary_topic = np.nan
        for topic_id, prob in sorted_topics[1:]:
            if prob < primary_prob:
                secondary_topic = topic_id
                break
        secondary_topic_count = sum(1 for _, prob in sorted_topics if prob == sorted_topics[1][1])
        if secondary_topic_count > 1:
            secondary_topic = -1

        load_df.at[idx, 'Primary Topic'] = primary_topic
        load_df.at[idx, 'Secondary Topic'] = secondary_topic

    topic_columns = [f'Topic {i}' for i in range(1, topic_num + 1)]
    load_df[topic_columns] = load_df[topic_columns].fillna(value=np.nan)
    load_df.to_excel(Route + f' Topic {topic_num} topic_probabilities.xlsx', index=False)

    # Save frequency summary for primary topics
    primary_topic_freq = load_df['Primary Topic'].value_counts()
    primary_topic_freq_percent = load_df['Primary Topic'].value_counts(normalize=True) * 100
    primary_topic_freq = primary_topic_freq.sort_index()
    primary_topic_freq_percent = primary_topic_freq_percent.sort_index()

    result_df = pd.DataFrame({
        'Primary Topic': primary_topic_freq.index,
        'Primary Frequency': primary_topic_freq,
        'Primary Percentage': primary_topic_freq_percent,
    })

    result_df.to_excel(Route + f' Topic {topic_num} primary_topic_frequency.xlsx', index=False)

# ================================
# Run topic modeling for a range of topic numbers
# ================================
for topic_num in range(start_topic, end_topic + 1):
    load_df = df.copy()  # fresh copy for each topic number
    model, corpus, dictionary = lda_modeling(cleaned_list)
    save_top_terms(cleaned_list, topic_num, model, dictionary)
    calculate_topic_probabilities(load_df, cleaned_list, topic_num, model, dictionary)
    lda_visualize(model, corpus, dictionary, topic_num)

# ================================
# NPMI Coherence Score Evaluation
# ================================
from gensim.models.ldamodel import LdaModel
from gensim.models.coherencemodel import CoherenceModel
npmi_start = 2
npmi_limit = 25
npmi_step = 1

def compute_coherence_npmi_values(dictionary, corpus, texts, limit, start, step):
    coherence_values = []
    model_list = []
    for num_topics in range(start, limit, step):
        model = LdaModel(corpus=corpus, id2word=dictionary, num_topics=num_topics, random_state=7)
        model_list.append(model)
        coherencemodel = CoherenceModel(model=model, texts=texts, dictionary=dictionary, coherence='c_npmi')
        coherence_values.append(coherencemodel.get_coherence())
    return model_list, coherence_values

def find_optimal_number_of_topics_with_npmi(dictionary, corpus, processed_data):
    result_dir = Route  # directory path to save results
    if not os.path.exists(result_dir):
        os.makedirs(result_dir)

    model_list, coherence_values = compute_coherence_npmi_values(
        dictionary=dictionary,
        corpus=corpus,
        texts=processed_data,
        start=npmi_start,
        limit=npmi_limit,
        step=npmi_step
    )

    x = range(npmi_start, npmi_limit, npmi_step)
    df = pd.DataFrame({'Num Topics': x, 'NPMI Coherence Score': coherence_values})
    result_file = result_dir + date + f'_npmi_coherence_{npmi_start}_to_{npmi_limit}_by_{npmi_step}.xlsx'
    df.to_excel(result_file, index=False)

    plt.plot(x, coherence_values)
    plt.xlabel("Num Topics")
    plt.ylabel("NPMI Coherence Score")
    plt.legend(["NPMI Coherence Values"], loc='best')
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(result_dir + date + f'_npmi_coherence_{npmi_start}_to_{npmi_limit}_by_{npmi_step}.png', dpi=300)
    plt.show()

find_optimal_number_of_topics_with_npmi(dictionary, corpus, cleaned_list)
