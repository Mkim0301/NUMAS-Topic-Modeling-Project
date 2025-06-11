
# ================================
# Load Data
# ================================
library(stringi)
library(stringr)
library(tidyr)
library(dplyr)

raw_data <- read.csv("/ADHD/Save/raw_data.csv")  # collected 'title', 'comment', 'date', 'no' expected

# ================================
# 1. Processing Data
# ================================

# Filter out rows with NA in title
raw_data1 <- subset(raw_data, !(raw_data$title %in% c('NA')))

# Split 'date' column into 'year', 'month', and 'day_time'
raw_data2 <- separate(raw_data1, col = date, into = c("year", "month", "day_time"), sep = "\\.")

# Split 'day_time' into 'day' and 'time'
raw_data3 <- separate(raw_data2, col = day_time, into = c("day", "time"), sep = " ")

# Convert year, month, day to numeric values
raw_data3$year <- as.numeric(raw_data3$year)
raw_data3$month <- as.numeric(raw_data3$month)
raw_data3$day <- as.numeric(raw_data3$day)

# ================================
# 2. Create Combined Text Columns
# ================================

# Combine title and comment into a single text column
raw_data3$total <- paste(raw_data3$title, raw_data3$comment)

# Make a backup copy of the text column
raw_data3$textcopy <- raw_data3$total

# ================================
# 3. Deduplication and Sorting
# ================================

# Remove duplicate rows based on 'title' and 'comment'
raw_data3 <-distinct(raw_data3, title, comment, .keep_all = TRUE)

# Sort the full dataset chronologically
raw_sum <- raw_data3[order(raw_data3$year, raw_data3$month, raw_data3$day, raw_data3$time), ]

# ================================
# 4. Clean and Normalize Text
# ================================

# Copy the dataframe to perform text cleaning
raw_sum1_copy <- raw_sum1

# Remove image sequence noise patterns
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, "[1-9][0-9]?\\s+이미지 순서 ON", "")

# Convert all text to lowercase
raw_sum1_copy$total <- str_to_lower(raw_sum1_copy$total)

# Remove excessive whitespace
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, "\\s+", " ")

# ================================
# 5. Remove URLs and Website Spam
# ================================

# Define common spam patterns (e.g., domains, shortened URLs)
website_patterns <- c(
  "www", "https", "htt", "ht\\.", "h1ttps", "h\\.ttp", "youtu\\.be", "gall", "m\\.",
  "drive\\.", "testharo", "adhd\\.or", "nocoworld", "news\\.s", "target=", "a-app",
  "clincalc\\.com", "ht1", "dcinside\\.c", "blog\\.", "addtypete", "ttps"
)

# Merge patterns into a single regex
website_regex <- paste(website_patterns, collapse = "|")

# Identify rows containing website patterns
filtered_rows <- grepl(website_regex, raw_sum1_copy$total)

# Add space between ASCII and Korean characters in matched rows
raw_sum1_copy$total[filtered_rows] <- gsub(
  "(?<=[[:alnum:]])(?![[:space:]]|[[:punct:]])(?=[^[:ascii:][:punct:]]|[[:space:]]+)",
  " ",
  raw_sum1_copy$total[filtered_rows],
  perl = TRUE
)

# Remove entire URLs and matched spam patterns
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, paste0("(", website_regex, ")\\S+"), " ")

# ================================
# 6. Remove image and Extra Symbols
# ================================

# Remove image HTML tags
raw_sum1_copy$total <- str_remove_all(raw_sum1_copy$total, "<img[^>]*>")

# Remove JavaScript snippet
raw_sum1_copy$total <- gsub("window._taboola.*}", "", raw_sum1_copy$total)

# Add space at beginning (for consistent formatting)
raw_sum1_copy$total <- paste(" ", raw_sum1_copy$total)

# ================================
# 7. Handle Email and Special Patterns
# ================================

# Remove specific email addresses or spam text
emails_to_remove <- c(
  'jellosu0@gmail.com', 'brainrich6@gmail.com', 'abcd@yakup.com', 'h@ps', '@=tt'
)
for (email in emails_to_remove) {
  raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, fixed(email), '')
}

# Remove special characters like > < - + except @
raw_sum1_copy$total <- gsub("[><-]", " ", raw_sum1_copy$total)
raw_sum1_copy$total <- gsub("\\+", " ", raw_sum1_copy$total)
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, "(?!\\@)[[:punct:]]", " ")

# ================================
# 8. Normalize Community Nicknames
# ================================

# Replace community aliases (붕이, 갤붕이, etc.)
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, "@붕이", " 애붕이")
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c("에붕이", "갤붕이"), " 애붕이", vectorize = FALSE)
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, " 붕이", " 애붕이")
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, "@붕", " 애붕이")

# Replace @갤 → adhd갤러리
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, "@갤", " adhd갤러리")

# Normalize "게이들" → "애붕이들"
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, "게이들", "애붕이들")

# Replace all remaining @ with 'adhd' (used as a tag in context)
raw_sum1_copy$total <- gsub("\\@", " adhd", raw_sum1_copy$total)

# ================================
# 9. Save Intermediate Output
# ================================

# Optional test output (for review/debugging)
test <- cbind(raw_sum1_copy$total, raw_sum1_copy$textcopy, raw_sum1_copy$no)


# ================================
# 10-1. Normalize Drug Names: Methylphenidate (메틸페니데이트)
# ================================

# Correct spelling variants of the base term '메틸'
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('메칠', '매틸'),
  c('메틸'),
  vectorize = FALSE
)

# Replace all variants and typos of '메틸페니데이트' with a placeholder
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c(
    '메닐페디데이트','메틸페니데이트','메틸패니데이트','메틸펜','메틸페니니데이트',
    '메틸페니게이트','메틸페니데이티드','메틸페이데이트','메틸페니드','메틸페니이드',
    '메틸페니데이','메틸페니데잇ㅌ','메딜페니드','메틸페니'
  ),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Replace the cleaned base '메틸' with the placeholder as well
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('메틸'),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Finally, revert the placeholder back to '메틸페니데이트'
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('TEMPORARYREPLACEMENT'),
  c('메틸페니데이트'),
  vectorize = FALSE
)

# ================================
# 10-2. Normalize Drug Names: Concerta
# ================================

# Temporarily obfuscate "콘서타" with a placeholder for safe processing
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('콘서타'), c(' TEMPORARYREPLACEMENT'), vectorize = FALSE)

# Normalize patterns like 콘서트 + number → TEMPORARYREPLACEMENT + number
raw_sum1_copy$total <- gsub("콘서트([1-9]|[1-9][0-9])", "TEMPORARYREPLACEMENT \\1", raw_sum1_copy$total)
raw_sum1_copy$total <- gsub("콘서트 ([1-9]|[1-9][0-9])", "TEMPORARYREPLACEMENT \\1", raw_sum1_copy$total)

# Replace various misspellings and variants of "콘서타"
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c(
    '콘터타','콘스타','콘사타','콘섲다','콘서ㅌ','콘써타','콘터사','콘서파','콘서나',
    '콘체르타','콘시타','콘소타','콘서ㅏ',' 콘섵하','콘스탄트',' 콘서트 '
  ),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Also handle shorthand versions like "콘9"
raw_sum1_copy$total <- gsub("콘([1-9]|[1-9][0-9])", "TEMPORARYREPLACEMENT \\1", raw_sum1_copy$total)

# ================================
# 10-3. Normalize Drug Names: Medikinet
# ================================

# Replace variants of '메디키넷' with placeholder
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('메디키넷','메디카넷','매디키넷','매티니넷','메디니켓','메디켓'),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Prevent false match with '메디컬'
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('메디컬'),
  c('TEMPORARYREPLACEMENT2'),
  vectorize = FALSE
)

# Replace shortened variants like '메디', '매디' to placeholder
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('메디','매디'),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Restore '메디컬' back from its placeholder
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('TEMPORARYREPLACEMENT2'),
  c('메디컬'),
  vectorize = FALSE
)

# Restore all placeholders to '메디키넷'
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('TEMPORARYREPLACEMENT'),
  c('메디키넷'),
  vectorize = FALSE
)



# ================================
# 11-1 Normalize Drug Names: Atomoxetine (Strattera)
# ================================

# Temporarily mask "아토목세틴" and variants with placeholder
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('아토목세틴'),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('아토목','아토몰','아토몯','아토묵','아토묙','아토모세틴'),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Prevent false positives with similar word "아토피"
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('아토피'),
  c(' TEMPORARYREPLACEMENT2'),
  vectorize = FALSE
)

# Convert general "아토" references to placeholder
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('아토'),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Restore all placeholders to proper medication names
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('TEMPORARYREPLACEMENT'),
  c('아토목세틴'),
  vectorize = FALSE
)
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('TEMPORARYREPLACEMENT2'),
  c('아토피'),
  vectorize = FALSE
)


# ================================
# 11-2. Normalize Drug Names: Strattera (스트라테라)
# ================================

# Replace various misspellings and abbreviations of '스트라테라' with a temporary placeholder
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('스트라테라', '스테라테라'),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Replace abbreviated forms like '스트라' or '스테라' with the placeholder
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('스트라', '스테라'),
  c(' TEMPORARYREPLACEMENT'),
  vectorize = FALSE
)

# Ensure '스트레스' and '테스트' are preserved and not affected by partial matching
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('스트레스'),
  c(' 스트레스'),
  vectorize = FALSE
)

raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('테스트'),
  c(' 테스트'),
  vectorize = FALSE
)

# Restore the placeholder back to '스트라테라'
raw_sum1_copy$total <- stri_replace_all_regex(
  raw_sum1_copy$total,
  c('TEMPORARYREPLACEMENT'),
  c('스트라테라'),
  vectorize = FALSE
)

# ================================
# 12. Normalize Educational Terms
# ================================

# Standardize various forms of school records, mock exams, and core subjects
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('생기부','생활기록부'), c(' 생활기록부'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('모고','모의고사'), c(' 모의고사'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('국영수','국수영'), c(' 국어 영어 수학 '), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 국수'), c(' 국어 수학'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 국영'), c(' 국어 영어'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('영수는'), c(' 영어 수학은'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('영수 '), c(' 영어 수학'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('수능'), c(' 수능'), vectorize=FALSE)


# ================================
# 13. Normalize Multitasking Terms
# ================================

raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('멀티테스킹','멀티태스킹','멀티 태스킹','멀티 테스킹'), c(' 멀티태스킹'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('멀티를'), c(' 멀티태스킹을'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('멀티가'), c(' 멀티태스킹이'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('멀티 되'), c(' 멀티태스킹이 되'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('멀티 안'), c(' 멀티태스킹이 안'), vectorize=FALSE)


# ================================
# 14. Normalize Rating Slangs
# ================================

# Normalize internet slang for rating systems
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('타취'), c('타치'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('ㅅㅌㅊ'), c(' 상타치'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('ㅍㅌㅊ'), c(' 평타치'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('ㅎㅌㅊ'), c(' 하타치'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('며타치','ㅁㅌㅊ'), c(' 몇타치'), vectorize=FALSE)


# ================================
# 15. Normalize University Terms
# ================================

# Use placeholders to preserve meaning during transformation
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('대학교병원','대학교 병원','대학병원','대학 병원'), c(' TEMPORARYREPLACEMENT4'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('대학교'), c(' TEMPORARYREPLACEMENT1'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('대학생'), c(' TEMPORARYREPLACEMENT2'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('대학원생'), c(' TEMPORARYREPLACEMENT3'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('대학원'), c(' TEMPORARYREPLACEMENT5'), vectorize=FALSE)

# Convert remaining '대학' to '대학교' then restore placeholders
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('대학'), c(' 대학교'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('TEMPORARYREPLACEMENT1'), c('대학교'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('TEMPORARYREPLACEMENT2'), c('대학생'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('TEMPORARYREPLACEMENT3'), c('대학원생'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('TEMPORARYREPLACEMENT4'), c('대학병원'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('TEMPORARYREPLACEMENT5'), c('대학원'), vectorize=FALSE)


# ================================
# 16. Normalize Civil Service Exam Terms
# ================================

raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('공무원','공뭔'), c(' 공무원'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('순수공부','순공부','실공부','실제공부','실제 공부'), c(' 순수 공부'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('순공시간'), c(' 순수 공부시간'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('순공'), c(' 순수 공부시간'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('공부 시간', '공부하는 시간','공부하는시간'), c(' 공부시간'), vectorize=FALSE)


# Normalize '공시' terms (short for civil service exam)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('공시생'), c(' 공무원 시험 준비생'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('공시험'), c('공 시험'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 공시'), c(' 공무원 시험'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('성공시'), c('성공 시'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('공시 '), c(' 공무원 시험 '), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('공시준비'), c(' 공무원 시험 준비'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('공시'), c(' 공무원 시험'), vectorize=FALSE)


# ================================
# 17. Normalize Intelligence Tests
# ================================

raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 능지'), c(' 지능'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('왝슬러','웩슬러','웩슬린'), c(' 웩슬러'), vectorize=FALSE)


# ================================
# 18. Normalize Medication Types
# ================================

raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('항우울제','항 우울제'), c(' 항우울제'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('항불안제','항 불안제'), c(' 항불안제'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('신경안정제','신경 안정제'), c(' 신경안정제'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('신경 안정','신경안정'), c(' 신경안정'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('신경안정제'), c('항불안제'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('수면안정제','수면제','수면유도제'), c(' 수면제'), vectorize=FALSE)
# Normalize zolpidem-related terms (sleeping medication)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('졸피뎀','졸피댐','졸피람','스틸녹스','스틸눅스'),  c(' 졸피뎀'), vectorize=FALSE)

# ================================
# 19. Normalize Autism Spectrum Terms
# ================================

raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 자스'), c(' 자폐 스팩트럼'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 자패', '자페'), c(' 자폐'), vectorize=FALSE)


# ================================
# 20. Normalize School Level Terms (Elementary, Middle, High)
# ================================

# Use placeholders for school levels:
# 초등학교 -> TEMPORARYREPLACEMENT1 (elementary)
# 중학교 -> TEMPORARYREPLACEMENT2 (middle)
# 고등학교 -> TEMPORARYREPLACEMENT3 (high)

# Handle variations and slang for school levels
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 중딩'), c(' TEMPORARYREPLACEMENT2'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초중고','초 중 고교'), c(' TEMPORARYREPLACEMENT1 TEMPORARYREPLACEMENT2 TEMPORARYREPLACEMENT3'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초 중 고','초 중  고'), c(' TEMPORARYREPLACEMENT1 TEMPORARYREPLACEMENT2 TEMPORARYREPLACEMENT3'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초등때'), c(' TEMPORARYREPLACEMENT1때'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중등때'), c(' TEMPORARYREPLACEMENT2때'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('고등때'), c(' TEMPORARYREPLACEMENT3때'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초중딩', '초 중등'), c(' TEMPORARYREPLACEMENT1 TEMPORARYREPLACEMENT2'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중고딩','중고등 학교'), c(' TEMPORARYREPLACEMENT2 TEMPORARYREPLACEMENT3'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중 고 대'), c(' TEMPORARYREPLACEMENT2 TEMPORARYREPLACEMENT3, 대학교'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초중때','초 중때'), c(' TEMPORARYREPLACEMENT1 TEMPORARYREPLACEMENT2때'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초중학교','초 중학교','초중등학교'), c(' TEMPORARYREPLACEMENT1 TEMPORARYREPLACEMENT2'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 초중 '), c(' TEMPORARYREPLACEMENT1 TEMPORARYREPLACEMENT2 '), vectorize=FALSE)

# Handle slang terms for individual levels
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중딩'), c(' TEMPORARYREPLACEMENT2'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('고딩'), c(' TEMPORARYREPLACEMENT3'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초딩'), c(' TEMPORARYREPLACEMENT1'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중고등학교','중 고등학교'), c(' TEMPORARYREPLACEMENT2 TEMPORARYREPLACEMENT3'), vectorize=FALSE)

# Normalize actual school names
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초등학교','초등학고'), c(' TEMPORARYREPLACEMENT1'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중학교'), c(' TEMPORARYREPLACEMENT2'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('고등학교'), c(' TEMPORARYREPLACEMENT3'), vectorize=FALSE)

# Convert expressions like 'elementary school 1st grade' to placeholder format
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초등학생 1학년'), c(' TEMPORARYREPLACEMENT1 1학년'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중학생 1학년'), c(' TEMPORARYREPLACEMENT2 1학년'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('고등학생 1학년'), c(' TEMPORARYREPLACEMENT3 1학년'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초등학생 2학년'), c(' TEMPORARYREPLACEMENT1 2학년'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('고등학생 2학년'), c(' TEMPORARYREPLACEMENT3 2학년'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중학생3'), c(' TEMPORARYREPLACEMENT2 3학년'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초등학생 3학년'), c(' TEMPORARYREPLACEMENT1 3학년'), vectorize=FALSE)

# Convert general references like 초중학생 to specific placeholders
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초중학생','초 중학생'), c(' TEMPORARYREPLACEMENT1 학생 TEMPORARYREPLACEMENT2 학생'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중고등학생','중 고등학생'), c('TEMPORARYREPLACEMENT2 학생 TEMPORARYREPLACEMENT3 학생'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초등학생','초등생'), c(' TEMPORARYREPLACEMENT1 학생'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중학생'), c(' TEMPORARYREPLACEMENT2 학생'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('고등학생'), c(' TEMPORARYREPLACEMENT3 학생'), vectorize=FALSE)

# Handle contextually different meanings of '중등', '고등' (e.g., exams, fish)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중등'), c(' TEMPORARYREPLACEMENT2'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초등교사'), c(' TEMPORARYREPLACEMENT1 교사'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('초등'), c(' TEMPORARYREPLACEMENT1'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('고등'), c(' TEMPORARYREPLACEMENT3'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('중고등', '중 고등'), c(' TEMPORARYREPLACEMENT2 TEMPORARYREPLACEMENT3'), vectorize=FALSE)

raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('TEMPORARYREPLACEMENT1'), c('초등학교'), vectorize=F)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('TEMPORARYREPLACEMENT2'), c('중학교'), vectorize=F)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('TEMPORARYREPLACEMENT3'), c('고등학교'), vectorize=F)

# ================================
# 21. Normalize ADHD / ADD Terminology
# ================================

# Normalize various misspellings of 'ADHD'
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, 
                                              c('adhd','adh d','adha','adhh','afhd','ahdh','ahhd','ashd','abhd','ahda','a dhd','ådhd'), 
                                              c(' TEMPORARYREPLACEMENT'), vectorize=FALSE)

# Normalize partial forms like 'adh' and 'add'
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('adh'), c(' TEMPORARYREPLACEMENT'), vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('add'), c(' TEMPORARYREPLACEMENT2'), vectorize=FALSE)

# Insert space if 'ad' is stuck to a Korean character (e.g., 붙어서 나오는 경우 분리)
raw_sum1_copy$total <- str_replace_all(raw_sum1_copy$total, "(?<=^|\\p{Hangul})ad", " ad")

# Replace ' ad' with 'TEMPORARYREPLACEMENT2' after space correction
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' ad'), c(' TEMPORARYREPLACEMENT2'), vectorize=FALSE)


# ================================
# 22. Normalize Other Terms
# ================================

# Normalize Instagram-related terms
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('인스타그램',' 인별','인스타'),  c(' 인스타'),  vectorize=FALSE)
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('유투브',' 유트브','유투1브','유투부','유튭','유툽','youtube'), ' 유튜브', vectorize = FALSE)

# Normalize '잡 생각' variants
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('잡 생각','잡생각'), c(' 잡생각'), vectorize=FALSE)

# Normalize '저능' to '저지능'
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c('저능'), c('저지능'), vectorize=FALSE)

# Remove space between 검사 비용 → 검사비용
raw_sum1_copy$total <- stri_replace_all_regex(raw_sum1_copy$total, c(' 검사 비용'), c(' 검사비용'), vectorize=FALSE)


# ================================
# 39. Save Cleaned Data
# ================================

# Save the cleaned data to a CSV file
write.csv(raw_sum1_copy, file = "/ADHD/Save/clean.csv", row.names = FALSE)
