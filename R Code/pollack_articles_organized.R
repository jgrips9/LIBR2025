# Load the libraries
#install.packages("rvest")
#install.packages("dplyr")
#install.packages("stringr")
#install.packages("purrr")
#install.packages("rtf")
library(rvest)
library(dplyr)
library(stringr)
library(purrr)
library(rtf)

# Define the base URL
base_url <- "https://statements.cornell.edu/pollack.cfm"

# Scrape the main page for all links
main_page <- read_html(base_url)

# Extract the links from the main page
links <- main_page %>% 
  html_nodes(xpath = "//a[@class='cu-statement-title']") %>% 
  html_attr("href") %>%
  unique() %>% 
  na.omit() 

base = "https://statements.cornell.edu/"

#Remove extra spaces
library(stringr)
links = str_squish(links)

full_links <- ifelse(str_detect(links, "^http"), links, paste0(base, links))
full_links = gsub("../", "", full_links, fixed = TRUE)


setwd("Z:\\jrg363\\Workshops FA25\\web scraping for library\\R")

#Loop through all the links
for(i in full_links){
  page <- tryCatch(read_html(i), error = function(e) return(NULL)) # Safely handle any broken links
  title <- page %>% 
    html_node("title") %>% 
    html_text() %>% 
    str_trim()
  
  # Extract the date
  date <- page %>% 
    html_node(xpath = "//time|//p[contains(text(), '20')]") %>% 
    html_text() %>% 
    str_trim() %>% 
    .[1] 
  
  # Extract the main content paragraphs
  paragraphs <- page %>% 
    html_nodes("p") %>% 
    html_text() %>% 
    str_trim() 
  
  name = paste(title, date, sep = "_")
  name = str_replace_all(name, "[^[:alnum:]]", " ")
  name = paste(name, ".doc", sep = "")
  rtffile <- RTF(name)
  for (j in paragraphs) {
    text = j
    text = str_replace_all(text, "\n", "")
    text = str_replace_all(text, "\t", "")
    addParagraph(rtffile, text)
  }
  done(rtffile)
}
