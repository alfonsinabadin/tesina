# Librerías --------------------------------------------------------------------

library(readxl)
library(dplyr)
library(janitor)

library(purrr)
library(stringr)
library(stopwords)
library(tm)
library(stringi)
library(textclean)
library(jsonlite)
library(stringdist)

# Carga de datos ---------------------------------------------------------------

# Ruta del archivo
ruta <- "Base Dic2024.xlsx"

# Obtener nombres de las hojas
hojas <- excel_sheets(ruta)

# Leer todas las hojas, agregar columna con el nombre del canal
base <- lapply(hojas, function(hoja) {
  read_excel(ruta, sheet = hoja) %>%
    clean_names() %>%
    mutate(Canal = hoja)
}) %>%
  bind_rows()

base_exp <- data.frame()

for (i in 1:1000) {
  
  # Limpieza y normalización ---------------------------------------------------
  
  comentarios_fila <- str_split(base$comentarios[i], "~\\*~")
  # Minuscula
  comentarios_fila <- tolower(comentarios_fila[[1]])
  # Elimino vocales repetidas ejemplo 'amoo'
  # comentarios_fila <- gsub('([aeiou])\\1+', '\\1', comentarios_fila)
  # Conservo solo letras (a-z), letras con tilde y ñ, y espacios
  comentarios_fila <- gsub("[^\\p{L}\\s]+", " ", comentarios_fila, perl = TRUE)
  # Elimino stopwords
  comentarios_fila <- removeWords(comentarios_fila, stopwords("es"))
  # Quito espacios extra
  comentarios_fila <- str_squish(comentarios_fila)
  # Filtro vacíos
  comentarios_fila <- subset(comentarios_fila, comentarios_fila!="")
  
  # Armo dataframe de la linea
  if (!is_empty(comentarios_fila)) { 
    base_exp <- rbind(
      base_exp,
      data.frame(
        canal = base$canal[i],
        suscriptores = base$suscriptores[i],
        titulo_del_video = base$titulo_del_video[i],
        url = base$url[i],
        me_gusta = base$me_gusta[i],
        comentarios = comentarios_fila,
        cantidad_comentarios = length(comentarios_fila),
        usuarios_suscritos_que_comentaron = base$usuarios_suscritos_que_comentaron[i],
        duracion_del_video = base$duracion_del_video[i],
        fecha_de_publicacion = base$fecha_de_publicacion[i],
        numero_de_vistas = base$numero_de_vistas[i],
        numero_de_compartidos = base$numero_de_compartidos[i],
        idioma_del_video = base$idioma_del_video[i]
      )
    )
    }
}

save(base_expanded, file = "base_expanded.RData")

# Corrección ortográfica -------------------------------------------------------

# Defino diccionario con el top de palabras más frecuentes, de esta manera 
# capturamos modismos y jerga propia del lenguaje y contexto
palabras <- str_split(base_expanded$Comentario, " ")

palabras_total <- c()

for (i in 1:length(palabras)) {
  palabras_paso <- subset(palabras[[i]], palabras[[i]] != "")
  palabras_total <- c(palabras_total, palabras_paso)
}

tabla_frecuencias <- table(palabras_total)
tabla_ordenada <- sort(tabla_frecuencias, decreasing = TRUE)

tabla_df <- data.frame(
  Palabra = names(tabla_ordenada),
  Frecuencia = as.integer(tabla_ordenada),
  row.names = NULL
)

dic_corpus  <- tabla_df %>%
  filter(Palabra != "") %>%
  arrange(desc(Frecuencia)) %>%
  slice(1:20000)

con <- file("index.jsonl", "r", encoding = "UTF-8")
data_es <- stream_in(con, verbose = FALSE)
close(con)

palabras_es <- unique(data_es$word)
diccionario_es <- data.frame(
  Palabra = palabras_es,
  Frecuencia = 1,
  stringsAsFactors = FALSE
)

diccionario_total <- bind_rows(dic_corpus, diccionario_es) %>%
  group_by(Palabra) %>%
  summarise(Frecuencia = max(Frecuencia), .groups = "drop")

MAX_LEN_DIFF        <- 2L     
MIN_BIGRAM_OVERLAP  <- 2L     
UMBRAL_DL           <- 3L 

tabla_correcciones <- tibble(
  token      = character(),
  correccion = character()
)

char_bigrams <- function(x) {
  x2 <- paste0("_", x, "_")
  if (nchar(x2) < 2) return(character(0))
  vapply(seq_len(nchar(x2) - 1), function(i) substr(x2, i, i + 1), character(1))
}

filtrar_candidatos <- function(token, dic_df,
                               max_len_diff = MAX_LEN_DIFF,
                               min_bigram_overlap = MIN_BIGRAM_OVERLAP) {
  if (is.na(token) || token == "") return(dic_df[0, , drop = FALSE])
  
  Ltok   <- nchar(token)
  bgrams <- char_bigrams(token)
  
  # Precalcular longitud y bigramas del diccionario
  if (!all(c("len", "bigr") %in% names(dic_df))) {
    dic_df <- dic_df %>%
      mutate(len  = nchar(Palabra),
             bigr = lapply(Palabra, char_bigrams))
  }
  
  cand <- dic_df %>%
    filter(abs(len - Ltok) <= max_len_diff)
  
  if (!nrow(cand)) return(cand[0, , drop = FALSE])
  
  # solapamiento de bigramas
  inters <- vapply(cand$bigr, function(bg) length(intersect(bg, bgrams)), integer(1))
  cand$bi_inter <- inters
  cand %>% filter(bi_inter >= min_bigram_overlap)
}

elegir_correccion <- function(token, candidatos_df, umbral_dl = UMBRAL_DL) {
  if (!nrow(candidatos_df)) {
    return(list(correccion = NA_character_, distancia = NA_real_))
  }
  
  d <- stringdist(token, candidatos_df$Palabra, method = "dl")
  dmin <- min(d)
  
  if (!is.finite(dmin) || dmin > umbral_dl) {
    return(list(correccion = NA_character_, distancia = NA_real_))
  }
  
  idx_min <- which(d == dmin)
  if (length(idx_min) == 1L) {
    return(list(correccion = candidatos_df$Palabra[idx_min],
                distancia  = dmin))
  } else {
    # desempate por frecuencia mayor
    sub <- candidatos_df[idx_min, , drop = FALSE]
    mejor <- sub$Palabra[which.max(sub$Frecuencia)]
    return(list(correccion = mejor, distancia = dmin))
  }
}

tokens_unicos <- unique(palabras_total)
palabras_por_corregir <- setdiff(tokens_unicos, diccionario_total$Palabra)
tabla_correcciones <- tibble(
  token      = palabras_por_corregir,
  correccion = NA_character_,
  distancia = NA_character_
)

diccionario_total_enriq <- diccionario_total %>%
  mutate(len  = nchar(Palabra),
         bigr = lapply(Palabra, char_bigrams))

for (i in 1:nrow(tabla_correcciones)) {
  tok <- tabla_correcciones$token[i]
  cands <- filtrar_candidatos(tok, diccionario_total_enriq,
                              max_len_diff = MAX_LEN_DIFF,
                              min_bigram_overlap = MIN_BIGRAM_OVERLAP)
  res <- elegir_correccion(tok, cands, umbral_dl = UMBRAL_DL)
  tabla_correcciones$correccion[i] <- res$correccion
  tabla_correcciones$distancia[i]  <- res$distancia
}

save.image(file = "environment.RData")
