``` r
library(tidyverse)
library(plotly)
library(modelr)
options(na.action = na.warn)
```

## Generar un scatter plot de dos variables 
``` r
ggplot(df, aes(x, y)) + 
  geom_point()
```

## Incorporarle una recta definida 
``` r
ggplot(df, aes(x, y)) + 
  geom_abline(aes(intercept = 3, slope = 5)) +
  geom_point() 
```

## Incorporarle las distancias entre los puntos y esa recta definida
``` r
ggplot(df, aes(x + rep(c(-1, 0, 1) / 20, 10), y)) + 
  geom_abline(intercept = 7, slope = 1.5, colour = "grey40") +
  geom_point(colour = "grey40") +
  geom_linerange(aes(ymin = y, ymax = 7 + (x + rep(c(-1, 0, 1) / 20, 10),) * 1.5), colour = "#3366FF")      # La parte de rep es para que los puntos no estén alineados sino levemente separados entre sí para mostrar mejor las distancias
```

## Forma visual de inferir la mejor recta
### Genero una secuencia aleatoria de modelos
``` r
models <- tibble(
  a1 = runif(250, -20, 40),
  a2 = runif(250, -5, 5)
)
```

### Función que calcula predicciones
``` r
model1 <- function(a, data) {
  a[1] + data$x * a[2]
}
```

### Función que calcula promedios de ECM
``` r
measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  sqrt(mean(diff ^ 2))
}

# Aplico a mis modelos
  
dist <- function(a1, a2) {
  measure_distance(c(a1, a2), df)
}

models <- models %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, dist))
```

### Cada modelo como una observación con color asociado a su ECM, quedandome con el mejor
``` r
ggplot(models, aes(a1, a2)) +
  geom_point(data = filter(models, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = -dist))
```

## Búsqueda del óptimo por método del gradiente descendente
### Genero una secuencia aleatoria de modelos
``` r
optim(c(4,2), measure_distance, data = df)              # (4,2) es el punto de partida para el método
```

## Búsqueda del modelo lineal de regresión
### Modelo lineal
``` r
linealModel <- lm(y ~ x, data = df)
```

### Generación de predicciones
``` r
grid <- df %>% 
  data_grid(x) %>%                                      # data_grid(x) genera una columna x numerada
  add_predictions(linealModel) 
```

### Recta de MCO
``` r
ggplot(df, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = pred), data = grid, colour = "red", size = 1)
```

### Incorporo residuos
``` r
df <- df %>% 
  add_residuals(linealModel)
```
La media de los residuos debería ser 0, y el scatter plot de ellos debería no tener una estructura para verificar homocedasticidad.
