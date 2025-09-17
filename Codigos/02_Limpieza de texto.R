library(readxl)
library(janitor)
library(lubridate)
library(knitr)
library(dplyr)

canales <- c("LuzuTV", "Olga", "Un Poco De Ruido", "La Casa Streaming", 
             "Bondi Live", "Vorterix", "Urbana Play", "Blender")

fotos <- c("logos_streaming/luzu.png", "logos_streaming/olga.png", "logos_streaming/un_poco_de_ruido.png", 
           "logos_streaming/la_casa.png", "logos_streaming/bondi.png","logos_streaming/vorterix.png" , 
           "logos_streaming/urbana.png", "logos_streaming/blender.png")

Luzu <- read_excel("Bases/LuzuTV.xlsx") %>% clean_names() %>% distinct()
comentarios_luzu <- read_excel("Bases/comentarios_luzu.xlsx") %>% 
  filter(publishedAt <= as.Date("05/09/2025", "%d/%m/%Y")) %>% distinct()

Olga  <- read_excel("Bases/Olga.xlsx") %>% clean_names() %>% distinct()
comentarios_olga <- read_excel("Bases/comentarios_olga.xlsx") %>% 
  filter(publishedAt <= as.Date("05/09/2025", "%d/%m/%Y")) %>% distinct()

Unpoco  <- read_excel("Bases/Unpoco.xlsx") %>% clean_names() %>% distinct()
comentarios_unpoco <- read_excel("Bases/comentarios_unpoco.xlsx") %>% 
  filter(publishedAt <= as.Date("05/09/2025", "%d/%m/%Y")) %>% distinct()

Lacasa <- read_excel("Bases/Lacasa.xlsx") %>% clean_names() %>% distinct()
comentarios_lacasa <- read_excel("Bases/comentarios_lacasa.xlsx") %>% 
  filter(publishedAt <= as.Date("05/09/2025", "%d/%m/%Y")) %>% distinct()

Bondi <- read_excel("Bases/Bondi.xlsx") %>% clean_names() %>% distinct()
comentarios_bondi <- read_excel("Bases/comentarios_bondi.xlsx") %>% 
  filter(publishedAt <= as.Date("05/09/2025", "%d/%m/%Y")) %>% distinct()

Vorterix <- read_excel("Bases/Vorterix.xlsx") %>% clean_names() %>% distinct()
comentarios_vorterix <- read_excel("Bases/comentarios_vorterix.xlsx") %>% 
  filter(publishedAt <= as.Date("05/09/2025", "%d/%m/%Y")) %>% distinct()

Urbana <- read_excel("Bases/Urbana.xlsx") %>% clean_names() %>% distinct()
comentarios_urbana <- read_excel("Bases/comentarios_urbana.xlsx") %>% 
  filter(publishedAt <= as.Date("05/09/2025", "%d/%m/%Y")) %>% distinct()

Blender <- read_excel("Bases/Blender.xlsx") %>% clean_names() %>% distinct()
comentarios_blender <- read_excel("Bases/comentarios_blender.xlsx") %>% 
  filter(publishedAt <= as.Date("05/09/2025", "%d/%m/%Y")) %>% distinct()

base_comentarios_completa <- rbind(
  comentarios_luzu,
  comentarios_olga,
  comentarios_unpoco,
  comentarios_lacasa,
  comentarios_bondi,
  comentarios_vorterix,
  comentarios_urbana,
  comentarios_blender
)

# Limpieza

## minusculas
base_comentarios_completa$textDisplay <- tolower(base_comentarios_completa$textDisplay)