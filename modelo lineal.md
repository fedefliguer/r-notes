``` r
library(tidyverse)
library(plotly)
library(modelr)
library(robustbase)
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

#### Teorema Frisch–Waugh–Lovell
``` r
coef(lm(y1 ~ x1 + x2))[2] = coef[ lm(residuals(lm(y1 ~ x2)) ~ -1 + residuals(lm(x1 ~ x2))) ]
```
El beta1 de una regresión múltiple es igual al beta de regresar: los residuos de la regresión de la variable explicada sobre beta2, sobre los residuos de la X1 sobre beta2. Siendo beta2 la/s variable/s que, juntas o separadas, consolidan todo el resto de información que X1 no contiene. Esto es una manera de reducir cualquier regresión a una doble

#### Función que hace múltiples modelos lineales

Partimos de, por ejemplo, un dataset que tiene observaciones de PBI por países por año. Nosotros queremos hacer un modelo por país, que relacione año con PBI. Primero generamos un subdataset donde cada observación es un país, unnesteado con el vector de años y valores.
``` r
by_country <- gapminder %>% 
  group_by(country) %>% 
  nest()
```

Generamos el modelo que realiza modelos lineales en forma sistemática, apuntando a correr uno por país
``` r
country_model <- function(df) {
  lm(lifeExp ~ year, data = df)
}

by_club <- by_club %>% 
  mutate(model = map(data, country_model))

by_club %>% 
  mutate(tdy = map(model, tidy)) %>% 
  unnest(tdy)
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

### Modelo robusto ante una posible irregularidad de los residuos (no están centrados en el cero o son heterocedásticos)
``` r
robustModel <- lmRob(y~x1+x2+x3,data = df)
```
