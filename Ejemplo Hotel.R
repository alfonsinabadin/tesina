library(ggplot2)
library(devtools)
library(ggthemr)
library(gtools)

# Ejemplo para modelo generativo
set.seed(1406)
prior_estrellas <- c(0, 0.24, 0.42, 0.29, 0.05)

n_hoteles <- 1000
estrellas <- sample(1:5, size = n_hoteles, replace = TRUE, prob = prior_estrellas)

ggthemr::ggthemr("dust")
data.frame(estrellas) |> ggplot(aes(x=estrellas)) + 
  geom_histogram(binwidth=1, fill="#F6BD60", color = "#F7EDE2") +
  labs(x="Cantidad de estrellas", 
       y="Cantidad de hoteles") +
  scale_x_continuous(breaks = c(1,2,3,4,5),
                     limits = c(0.5,5.5))


# Ejemplo para modelo inferencial

alpha_prior <- c(1, 1, 1, 1, 1)
estrellas_observadas <- c(0, 16, 29, 19, 3)
posterior <- alpha_prior + estrellas_observadas
simulaciones_prior <- rdirichlet(1000, alpha_prior)
simulaciones_posterior <- rdirichlet(1000, posterior)

df_prior <- data.frame(Proporcion = c(simulaciones_prior[, 1],
                                      simulaciones_prior[, 2],
                                      simulaciones_prior[, 3],
                                      simulaciones_prior[, 4],
                                      simulaciones_prior[, 5]), 
                       Distribución = "Prior", 
                       Estrellas = factor(rep(c("1","2","3","4","5"),each = 1000),
                                          values = c("1","2","3","4","5"), 
                                          ordered = TRUE))
df_posterior <- data.frame(Proporcion = c(simulaciones_posterior[, 1],
                                      simulaciones_posterior[, 2],
                                      simulaciones_posterior[, 3],
                                      simulaciones_posterior[, 4],
                                      simulaciones_posterior[, 5]), 
                       Distribución = "posterior", 
                       Estrellas = factor(rep(c("1","2","3","4","5"),each = 1000),
                                          values = c("1","2","3","4","5"), 
                                          ordered = TRUE))
df <- rbind(df_prior, df_posterior)

ggplot(df, aes(x = Proporcion, fill = Distribucion, colour = Distribucion)) +
  geom_density(alpha = 0.7) +
  labs(x = "Proporción de Hoteles de 3 Estrellas", y = "Densidad") +
  scale_fill_manual(values = c("#84A59D","#F5CAC3")) +
  scale_color_manual(values = c("#84A59D","#F5CAC3")) +
  facet_wrap(~ Estrellas, ncol = 5)
