library(readxl)
library(stopwords)
library(text2vec)
library(word2vec)

luzu <- read_excel("Base Dic2024.xlsx", sheet = "Luzu")
olga <- read_excel("Base Dic2024.xlsx", sheet = "Olga")
pinky <- read_excel("Base Dic2024.xlsx", sheet = "Pinky SD")
lacasa <- read_excel("Base Dic2024.xlsx", sheet = "La Casa Streaming")
bondi <- read_excel("Base Dic2024.xlsx", sheet = "Bondi Live")
carajo <- read_excel("Base Dic2024.xlsx", sheet = "Carajo")
blender <- read_excel("Base Dic2024.xlsx", sheet = "Blender")
vorterix <- read_excel("Base Dic2024.xlsx", sheet = "Vorterix")
base <- rbind(luzu,olga,pinky,lacasa,bondi,carajo,blender,vorterix)

# Seleccionar la base principal (por ejemplo, "base")
comentarios <- base$Comentarios  # Reemplazar "Comentarios" con el nombre correcto de la columna

# Dividir los comentarios por el delimitador "~*~"
comentarios <- unlist(strsplit(comentarios, "~\\*~"))

# Verificar los primeros comentarios divididos
head(comentarios)

# Función para limpiar texto
limpiar_texto <- function(texto) {
  texto <- tolower(texto)  # Convertir a minúsculas
  texto <- gsub("[[:punct:]]", " ", texto)  # Eliminar puntuación
  texto <- gsub("[[:digit:]]", " ", texto)  # Eliminar números
  texto <- gsub("[^\x20-\x7EáéíóíÁÉÍÓÚñ]", "", texto)  # Eliminar emojis y caracteres no ASCII
  texto <- gsub("\\s+", " ", texto)  # Reemplazar espacios múltiples por uno solo
  texto <- trimws(texto,which = "both")
  return(texto)  # Reconstruir texto limpio
}

# Aplicar limpieza al texto
comentarios_limpios <- unname(sapply(comentarios, limpiar_texto))

# Filtrar comentarios vacíos después de la limpieza
comentarios_limpios <- comentarios_limpios[comentarios_limpios != ""]

head(comentarios_limpios)

model <- word2vec(x = comentarios_limpios, type = "cbow", dim = 15, iter = 20)
embedding <- as.matrix(model)

embedding <- predict(model, c("luzu", "amo"), type = "embedding")
lookslike <- predict(model, c("luzu", "amo"), type = "nearest", top_n = 5)
lookslike

