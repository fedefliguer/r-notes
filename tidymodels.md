``` r
library(tidymodels)
```
Tidymodels instla múltiples paquetes, pero al elegir library(tidymodels) no se agregan todos. Se aclara puntualmente cuál se necesita

## Preparación de los datos
### ¿Con qué proporción queremos que entrene?
``` r
library(rsample)
iris_split <- initial_split(iris, prop = 0.3)                             
```

## Transformación de los datos
``` r
library(recipes)
iris_recipe <- training(iris_split) %>%
  recipe(Species ~.) %>%
  step_corr(all_predictors()) %>%
  step_center(all_predictors(), -all_outcomes()) %>%
  step_scale(all_predictors(), -all_outcomes()) %>%
  prep()
```
De la base de entrenamiento, definimos cuál es la variable a explicar y sobre el resto ejecutamos tres operaciones: con step_corr eliminamos las variables muy correlacionadas, con step_center se centran para tener media 0, y con step_scale se normalizan para que tengan desvío 1. iris_recipe es una receta para preprocesamiento de datos, todavía no aplicados.

``` r
iris_training <- juice(iris_recipe)                 # Para aplicarlo sobre los datos con los que fue construida (iris_split)

iris_testing <- iris_recipe %>%
  bake(testing(iris_split))                         # Para aplicarlo sobre otros datos
```
Ahora la sí esa receta fue aplicada.

## Entrenamiento
### Selección del modelo y ajuste
``` r
iris_rf <-  rand_forest(trees = 100, mode = "classification") %>%              # Parámetro de seteo de qué modelo usar con sus atributos
  set_engine("randomForest") %>%                                               # Parámetro de qué librería usar
  fit(Species ~ ., data = iris_training)                                       # Ajuste de variable dependiente y datos
```

Podrían ser otros modelos:

⋅⋅⋅classification: boost_tree(), decision_tree(), logistic_reg(), mars(), mlp(), multinom_reg(), nearest_neighbor(), null_model(), rand_forest(), svm_poly(), svm_rbf()

⋅⋅⋅regression: boost_tree(), decision_tree(), linear_reg(), mars(), mlp(), nearest_neighbor(), null_model(), rand_forest(), surv_reg(), svm_poly(), svm_rbf()

Cada uno con sus [parámetros](https://tidymodels.github.io/parsnip/articles/articles/Models.html).
