# Cargar librerías necesarias
library(ggplot2)
library(plotly)

# Crear datos de ejemplo (representaciones vectoriales de palabras)
word_vectors <- data.frame(
  word = c("miel", "agua", "sopa", "té", "mate"),
  comida = c(0.6, 0.3, 0.8, 0.1, 0.1), # Eje X
  bebida = c(0.3, 0.8, 0.3, 0.5, 1.0), # Eje Y
  caliente = c(0.1, 0.5, 0.9, 0.9, 0.9) # Eje Z
)

# Crear el gráfico 3D
plot_ly(
  data = word_vectors,
  x = ~comida,
  y = ~bebida,
  z = ~caliente,
  type = "scatter3d",
  mode = "markers+text",
  marker = list(size = 6, color = c('#f28482','#f28482','#f28482','#f28482','#f28482','white'))'),
  text = ~word,  # Etiquetas de los puntos
  textposition = "top center"
) %>%
  layout(
    title = "Semántica Vectorial en un Espacio Tridimensional",
    scene = list(
      xaxis = list(title = "Comida"),
      yaxis = list(title = "Bebida"),
      zaxis = list(title = "Caliente")
    )
  )
