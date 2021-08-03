# Using the Google scholar package

# tidyverse, scholar and kableExtra packages will need installing into R first
# by the user via install.packages() if not already available.
library(tidyverse)
library(scholar)
library(kableExtra)

# Approach uses unique Google Scholar IDs to locate papers.
# e.g. Roy Sanderson's Google Scholar id
# from https://scholar.google.co.uk/citations?user=z6jaMRcAAAAJ&hl=en

# Should now read without NA problems
mep_data <- read_csv("google_scholar.ids.csv")


scholar_ids<- mep_data$Scholar_ID

all_pubs<-NULL

for(ss in scholar_ids) {
  get_publications(ss) %>%
    rbind(all_pubs)  -> all_pubs   
}

all_pubs %>% 
  
  mutate(All_info=paste(year,title,author,journal,number,sep = ", "),
         Title_lower=tolower(title)) %>% 
  arrange(desc(All_info)) %>% 
  distinct(cid, .keep_all = TRUE) %>% 
  distinct(Title_lower, .keep_all = TRUE) %>% 
  filter(year!="1977") %>% #odd one for Roy  
  dplyr::select(All_info)->all_pubs_trim  

# Output as tab-separated or comman-separated files if wanted for Excel.
# Several R packages are also available for direct export to .xlsx or .xls
write_tsv(all_pubs_trim,"MEP_publications.tsv")
write_csv(all_pubs_trim,"MEP_publications.csv")

# As HTML
# Create table in suitable format
pubs_for_kbl <- all_pubs %>% 
  arrange(desc(year)) %>% 
  distinct(cid, .keep_all = TRUE) %>% 
  filter(is.na(year) == FALSE) %>% 
  mutate(publication = paste(journal, number),
         title_lower = tolower(title)) %>% 
  distinct(title_lower, .keep_all = TRUE) %>% 
  select(year, author, title, publication)

# Output as HTML
kbl(pubs_for_kbl) %>% 
  kable_paper() %>% 
  scroll_box(width = "100%", height = "100%") %>% 
  kable_styling(fixed_thead = TRUE) %>% 
  save_kable("MEP_publications.html", self_contained = TRUE)
  



