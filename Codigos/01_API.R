library(tuber)
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(readr)
library(readxl)
library(janitor)

canal <- read_excel("canal.xlsx") %>%
  clean_names() %>%
  distinct()

yt_oauth(
  app_id     = client_id,
  app_secret = client_secret,
  scope      = "ssl",   # <-- no pongas la URL; usa "ssl"
  token      = ""
)

video_ids <- canal$video_id

comentarios_canal <- data.frame()

for (i in 1:nrow(canal)) { 
  all_comments <- get_all_comments(video_id = video_ids[i]) 
  comentarios_canal <- rbind(comentarios_canal, all_comments)
}