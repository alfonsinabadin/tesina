# Código básico hecho con el chat ----------------------------------------------

# Lectura de comentarios -------------------------------------------------------

library(readxl)

luzu <- read_excel("Base Dic2024.xlsx")

comentarios <- luzu$Comentarios

# Procesamiento BOW ------------------------------------------------------------

library(tm)
library(dplyr)

# Crear un corpus de texto
corpus <- Corpus(VectorSource(comentarios))

# Limpiar los datos
corpus <- corpus %>%
  tm_map(content_transformer(tolower)) %>%       # Convertir a minúsculas
  tm_map(removePunctuation) %>%                  # Eliminar puntuación
  tm_map(removeNumbers) %>%                      # Eliminar números
  tm_map(removeWords, stopwords("spanish")) %>%  # Eliminar stopwords en español
# En español: "de", "la", "y", "el", "que", "a", "en", "es", etc.
  tm_map(stripWhitespace)                        # Eliminar espacios en blanco extra

dtm <- DocumentTermMatrix(corpus)

# Remover términos poco frecuentes para mejorar el análisis
dtm <- removeSparseTerms(dtm, 0.99)  # Mantener términos presentes en al menos 1% de los documentos
dtm <- dtm[row_sums > 0, ]

# LDA

library(topicmodels)

# Configurar el número de temas
num_topics <- 5

# Entrenar el modelo LDA
lda_model <- LDA(dtm, k = num_topics, control = list(seed = 1234))

# Explorar los temas
topics <- terms(lda_model, 10)  # Las 10 palabras más representativas de cada tema
print(topics)

# Visualizar resultados 

# Preparar los datos para LDAvis
library(LDAvis)
lda_json <- createJSON(phi = posterior(lda_model)$terms,
                       theta = posterior(lda_model)$topics,
                       doc.length = rowSums(as.matrix(dtm)),
                       vocab = colnames(dtm),
                       term.frequency = colSums(as.matrix(dtm)))

# Visualizar
serVis(lda_json)