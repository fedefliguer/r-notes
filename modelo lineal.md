``` r
library(tidyverse)
library(plotly)
library(modelr)
library(robustbase)
library(broom)
library(plotly)
library(glmnet)
```

# Exploración
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

# Regresión Lineal
## Modelo lineal
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

### Modelo robusto ante una posible irregularidad de los residuos (no están centrados en el cero o son heterocedásticos)
``` r
robustModel <- lmRob(y~x1+x2+x3,data = df)
```

### Teorema Frisch–Waugh–Lovell
``` r
coef(lm(y1 ~ x1 + x2))[2] = coef[ lm(residuals(lm(y1 ~ x2)) ~ -1 + residuals(lm(x1 ~ x2))) ]
```
El beta1 de una regresión múltiple es igual al beta de regresar: los residuos de la regresión de la variable explicada sobre beta2, sobre los residuos de la X1 sobre beta2. Siendo beta2 la/s variable/s que, juntas o separadas, consolidan todo el resto de información que X1 no contiene. Esto es una manera de reducir cualquier regresión a una doble

### Función que hace múltiples modelos lineales

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

## Regularización

La alta cantidad de variables y la existencia de una alta correlación entre varias de ellas ocasionas que los coeficientes estimados tengan alta varianza y que muchos de ellos no sean significativos en términos estadísticos. Las técnicas de regularización pueden ayudarnos a mejorar esta situación.

### Lasso

``` r
nba_salary = nba$salary
nba_mtx = model.matrix(salary~., data = nba)                                  # Es mejor en estos casos crear dos objetos, uno para las variables explicativas y otro para la explicada.

lasso.mod=glmnet(x=nba_mtx,                                                   # Matriz de regresores
                 y=nba_salary,                                                # Vector de la variable a predecir
                 alpha=1,                                                     # Indicador del tipo de regularizacion
                 standardize = F)                                             # No estandarizo

lasso_coef = lasso.mod %>% tidy()
```

La salida será un conjunto de coeficientes para modelso ordenados por Lambda, lo que significa que cada modelo usa un lambda distinto: el de mayor lambda seguramente solo incluya el intercepto, y luego vaya incluyendo cada vez otras variables. Es probable que las variables que “sobreviven” para mayores valores de lambda sean las que están medidas con una escala mayor, por lo que en ese caso es conveniente estandarizar.

#### Valor óptimo de Lambda

Para hallar esto en general se usa cross-validation

``` r
lasso_cv=cv.glmnet(x=nba_mtx,y=nba_salary,alpha=1, standardize = T)
lasso_lambda_opt = lasso_cv$lambda.min                                          # Devuelve el lambda para el cual el MSE (error) es minimo

lasso_opt = glmnet(x=nba_mtx,                                                   
                 y=nba_salary, #Vector de la variable a predecir
                 alpha=1, 
                 standardize = TRUE,  
                 lambda = lasso_lambda_opt)
```

Se ve cuáles variables sobrevivieron.

### Ridge y Elastic Net

Funcionan igual que Lasso, pero respectivamente con alpha = 0 y alpha = 0.5. Ridge reduce la varianza sin excluir predictores, Elastic Net es un promedio entre las dos formas de regularización.

## Generalización (GLM)
### Regresión logística

Partimos de un dataset con dos probabilidades (Default 1, No default 0) y tres variables explicativas, en primer lugar buscamos armar modelos binomiales para cada variable y para el conjunto.

``` r
logit_formulas <- formulas(.response = ~default, # único lado derecho de las formulas.
                         bal= ~balance, 
                         stud= ~student,  
                         inc= ~income,  
                         bal_stud=~balance+student, 
                         bal_inc=~balance+income, 
                         stud_inc=~student+income,  
                         full= ~balance + income + student  
                         )
```

Y luego, genero la base con el modelo y sus resultados

``` r
models <- data_frame(logit_formulas) %>%                                            # df a partir del objeto formulas
  mutate(models = names(logit_formulas),                                            # Columna con los nombres de las formulas
         expression = paste(logit_formulas),                                        # Columna con las expresiones de las formulas
         mod = map(logit_formulas, ~glm(.,family = 'binomial', data = default)))    # podría agregarse como parámetro antes de data ' weights = wt' que significa que hay una columna adicional por la que se ponderan los pesos. Esto es útil para muestras muy desbalanceadas.
         
models %>% 
  mutate(tidy = map(mod,tidy)) %>% 
  unnest(tidy, .drop = TRUE) %>% 
  mutate(estimate=round(estimate,5),
         p.value=round(p.value,4))         
```

Evalúo los modelos dentro de los datos usados (vía deviance):

``` r
models <- models %>% 
  mutate(glance = map(mod,glance))

models %>% 
  unnest(glance, .drop = TRUE) %>%
  mutate(perc_explained_dev = 1-deviance/null.deviance) %>% 
  select(-c(models, df.null, AIC, BIC)) %>% 
  arrange(deviance)
```

####  Capacidad de predicción

Agrego las predicciones

``` r
models <- models %>% 
  mutate(pred= map(mod,augment, type.predict = "response"))
```

Armo las curvas ROC

``` r
roc_full <- roc(response=prediction_full$default, predictor=prediction_full$.fitted)
roc_bad <- roc(response=prediction_bad$default, predictor=prediction_bad$.fitted)
ggroc(list(full=roc_full, bad=roc_bad), size=1) + geom_abline(slope = 1, intercept = 1, linetype='dashed') + theme_bw() + labs(title='Curvas ROC', color='Modelo')
```

####  Punto de corte

``` r
cutoffs = seq(0.01,0.95,0.01)
logit_pred = map_dfr(cutoffs, prediction_metrics)
ggplot(logit_pred, aes(cutoff,estimate, group=term, color=term)) + geom_line(size=1) +
  theme_bw() +
  labs(title= 'Accuracy, Sensitivity, Specificity, Recall y Precision', subtitle= 'Modelo completo', color="")
```

Elijo el punto de corte 0.25 y evalúo el modelo

``` r
sel_cutoff = 0.25
full_model <- glm(logit_formulas$full, family = 'binomial', data = default)
table= augment(x=full_model, newdata=test, type.predict='response') 
table=table %>% mutate(predicted_class=if_else(.fitted>0.25, 1, 0) %>% as.factor(),
           default= factor(default))
confusionMatrix(table(table$default, table$predicted_class), positive = "1")
```
