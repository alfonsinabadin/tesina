# app.R

library(shiny)
library(readxl)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(reactable)
library(htmltools)
library(stopwords)
stopwords_esp <- stopwords("es")
set.seed(1406)

# ----------- Base de datos ----------- 
comentarios_df <- read_excel("Base Dic2024.xlsx", sheet = "Luzu")

procesar_vocabulario <- function(df) {
  textos <- df$Comentarios %>% na.omit() %>% tolower()
  textos <- unlist(strsplit(textos, "~\\*~"))
  tokens <- unlist(strsplit(textos, "\\s+"))
  tokens <- str_replace_all(tokens, "[^a-záéíóúñü]", "")
  tokens <- tokens[nchar(tokens) > 2 & tokens != ""]
  tokens <- tokens[!tokens %in% stopwords("es")]
  sort(table(tokens), decreasing = TRUE)[1:40] %>% names()
}

# ----------- UI ----------- 
ui <- fluidPage(
  titlePanel("Simulador LDA con vocabulario real (streaming)"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("K", "Cantidad de tópicos", min = 2, max = 6, value = 5),
      sliderInput("N", "Palabras por comentario", min = 3, max = 15, value = 7),
      sliderInput("n_docs", "Cantidad de comentarios", min = 1, max = 10, value = 5),
      actionButton("generar", "Generar comentarios"),
      br(),
      selectInput("topico_select", "Seleccionar tópico", choices = NULL),
      tableOutput("top_palabras")
    ),
    mainPanel(
      reactableOutput("tabla_comentarios")
    )
  )
)

# ----------- SERVER ----------- 
server <- function(input, output, session) {
  vocabulario <- reactive({
    req(comentarios_df)
    procesar_vocabulario(comentarios_df)
  })
  
  generar_phi <- function(K, vocab) {
    V <- length(vocab)
    phi <- matrix(0, nrow = K, ncol = V)
    for (k in 1:K) {
      idx <- sample(1:V, size = min(15, V))
      phi[k, idx] <- runif(length(idx))
    }
    phi <- phi / rowSums(phi)
    colnames(phi) <- vocab
    phi
  }
  
  generar_comentario <- function(phi, theta_row, N) {
    K <- nrow(phi)
    vocab <- colnames(phi)
    palabras <- character(N)
    z_vector <- integer(N)
    for (i in 1:N) {
      z <- sample(1:K, 1, prob = theta_row)
      palabras[i] <- sample(vocab, 1, prob = phi[z, ])
      z_vector[i] <- z
    }
    list(texto = paste(palabras, collapse = " "), z = z_vector)
  }
  
  resultados <- eventReactive(input$generar, {
    req(vocabulario())
    K <- input$K
    N <- input$N
    n_docs <- input$n_docs
    vocab <- vocabulario()
    phi <- generar_phi(K, vocab)
    theta <- matrix(1/K, nrow = n_docs, ncol = K)
    
    out <- lapply(1:n_docs, function(i) {
      comentario <- generar_comentario(phi, theta[i, ], N)
      z_table <- table(factor(comentario$z, levels = 1:K))
      list(texto = comentario$texto, z = z_table)
    })
    
    updateSelectInput(session, "topico_select", choices = paste0("Tópico ", 1:K))
    
    list(phi = phi, out = out)
  })
  
  output$tabla_comentarios <- renderReactable({
    req(resultados())
    K <- input$K
    df <- data.frame(
      Comentario = paste0("C", seq_along(resultados()$out)),
      Texto = sapply(resultados()$out, function(x) x$texto),
      Composición = sapply(resultados()$out, function(x) {
        z <- as.integer(x$z)
        prop <- round(100 * table(factor(z, levels = 1:K)) / length(z))
        paste0(prop, "% T", 1:K, collapse = ", ")
      })
    )
    
    recuentos <- lapply(resultados()$out, function(x) as.integer(x$z))
    recuentos_df <- do.call(rbind, lapply(recuentos, function(z) {
      as.numeric(table(factor(z, levels = 1:K)))
    }))
    
    colores <- scales::hue_pal()(K)
    df$Distribución <- lapply(1:nrow(recuentos_df), function(i) {
      div(style = "display:flex;", 
          lapply(1:K, function(k) {
            div(style = paste0(
              "flex:1; background:", colores[k], "; height:", recuentos_df[i,k]*10, 
              "px; margin-right:1px"), title = paste("Tópico", k, ":", recuentos_df[i,k]))
          }))
    })
    
    reactable(df, columns = list(
      Distribución = colDef(html = TRUE)
    ), bordered = TRUE, highlight = TRUE)
  })
  
  output$top_palabras <- renderTable({
    req(resultados())
    req(input$topico_select)
    phi <- resultados()$phi
    k <- as.numeric(gsub("Tópico ", "", input$topico_select))
    palabras <- sort(phi[k, ], decreasing = TRUE)[1:10]
    data.frame(Palabra = names(palabras), Probabilidad = round(palabras, 3))
  })
}

# ----------- Ejecutar ----------- 
shinyApp(ui, server)
