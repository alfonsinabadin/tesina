# Librerías
library(ggplot2)
library(gtools)
set.seed(1406)

# Inferencia -------------------------------------------------------------------

# Prior Dirichlet uniforme
alpha_prior <- c(1, 1, 1, 1, 1)

# Observaciones
observaciones_holiday_inn <- c(1214, 417, 67, 8, 7)
observaciones_savoy <- c(855, 818, 259, 88, 56)

# Posterior Dirichlet
posterior_holiday_inn <- alpha_prior + observaciones_holiday_inn
posterior_savoy <- alpha_prior + observaciones_savoy

# Simulaciones
sim_holiday_inn <- rdirichlet(1000, posterior_holiday_inn)
sim_savoy <- rdirichlet(1000, posterior_savoy)

# Data frame
df_holiday_inn <- data.frame(Proporcion = c(sim_holiday_inn[, 1], sim_holiday_inn[, 2], sim_holiday_inn[, 3], sim_holiday_inn[, 4], sim_holiday_inn[, 5]), 
                             Estrellas = factor(rep(c("Excelente", "Muy bueno", "Regular", "Malo", "Horrible"), each = 1000), 
                                                levels = c("Excelente", "Muy bueno", "Regular", "Malo", "Horrible"), ordered = TRUE), 
                             Hotel = "Holiday Inn")

df_savoy <- data.frame(Proporcion = c(sim_savoy[, 1], sim_savoy[, 2], sim_savoy[, 3], sim_savoy[, 4], sim_savoy[, 5]), 
                       Estrellas = factor(rep(c("Excelente", "Muy bueno", "Regular", "Malo", "Horrible"), each = 1000), 
                                          levels = c("Excelente", "Muy bueno", "Regular", "Malo", "Horrible"), ordered = TRUE), 
                       Hotel = "Savoy")

df <- rbind(df_holiday_inn, df_savoy)

# Grafico
ggplot(df, aes(x = Proporcion, colour = Hotel, fill = Hotel)) +
  geom_density(alpha = 0.7) +
  labs(x = "p", y = "Credibilidad") +
  facet_wrap(~ Estrellas,, nrow=5) +
  scale_fill_manual(values = c("#84A59D","#F5CAC3")) +
  scale_color_manual(values = c("#84A59D","#F5CAC3")) +
  scale_x_continuous(limits=c(0,1)) +
  theme_grey()

# 100 "Horrible" en Holiday Inn
observaciones_holiday_inn_n <- c(0, 0, 0, 0, 100)
posterior_holiday_inn_n <- posterior_holiday_inn + observaciones_holiday_inn_n
sim_holiday_inn <- rdirichlet(1000, posterior_holiday_inn_n)
df_holiday_inn_n <- data.frame(Proporcion = c(sim_holiday_inn[, 1], sim_holiday_inn[, 2], sim_holiday_inn[, 3], sim_holiday_inn[, 4], sim_holiday_inn[, 5]), 
                             Estrellas = factor(rep(c("Excelente", "Muy bueno", "Regular", "Malo", "Horrible"), each = 1000), 
                                                levels = c("Excelente", "Muy bueno", "Regular", "Malo", "Horrible"), ordered = TRUE), 
                             Hotel = "Holiday Inn")
df <- rbind(df_holiday_inn_n, df_savoy)

# Grafico
ggplot(df, aes(x = Proporcion, colour = Hotel, fill = Hotel)) +
  geom_density(alpha = 0.7) +
  labs(x = "p", y = "Credibilidad") +
  facet_wrap(~ Estrellas, nrow=5) +
  scale_fill_manual(values = c("#84A59D","#F5CAC3")) +
  scale_color_manual(values = c("#84A59D","#F5CAC3")) +
  scale_x_continuous(limits=c(0,1)) +
  theme_grey()

# Generativo -------------------------------------------------------------------

# Simulación con posterior
n_simulaciones <- 1000
simulaciones_nuevas <- rdirichlet(n_simulaciones, posterior_holiday_inn_n)

# Nuevos puntajes para el hotel
puntajes <- numeric()
for (i in 1:1000) {
  puntajes[i] <- sum(rmultinom(1,1,simulaciones_nuevas[i,])*(1:5))
}

# Data frame de puntaje promedio
df_puntajes <- data.frame(
  puntaje = factor(puntajes, levels = 1:5, 
                   labels = c("Horrible", "Malo", "Regular", "Muy bueno", "Excelente"))
)

# Grafico
ggplot(df_puntajes, aes(x = puntaje)) +
  geom_bar(binwidth = 0.1, fill = "#F28482", color = "#F28482") +
  labs(x = "Calificación promedio esperada", y = "Frecuencia") +
  theme_grey()        
