``` r
# Ejemplo 1 -> SVM con dataset Iris

## Instalación de librerías

install.packages("mlr")
install.packages("mlrMBO")
install.packages("DiceKriging")
install.packages("e1071")
install.packages("rgenoud")

library(data.table)
library(mlr)
library(mlrMBO)
library(DiceKriging)
library(e1071)
library(rgenoud)

## Carga de dataset y configuración inicial
iris = data.table(iris)
configureMlr(show.learner.output = FALSE) # Configuración de lo que quiero ver durante el ajuste de parámetros
iters = 3 # Número de iteraciones
par.set = makeParamSet(
  makeNumericParam("cost", -15, 15, trafo = function(x) 2^x),
  makeNumericParam("gamma", -15, 15, trafo = function(x) 2^x)
) # Se definen los parámetros, en este caso por medio de una transformación

## Generación de la función a maximizar/minimizar.
svm = makeSingleObjectiveFunction(name = "svm.tuning",
                                  fn = function(x) {
                                    lrn = makeLearner("classif.svm", par.vals = x)
                                    resample(lrn, iris.task, cv3, show.info = FALSE)$aggr
                                  },
                                  par.set = par.set,
                                  noisy = TRUE,
                                  has.simple.signature = FALSE,
                                  minimize = TRUE
) # Definimos al alumno, y en este caso el objetivo que es de minimización de error.

## Ajustes finales
ctrl = makeMBOControl()
ctrl = setMBOControlTermination(ctrl, iters = iters)

## Genero el objeto que guarda el resultado de la optimización.
res = mbo(svm, control = ctrl, show.info = FALSE)
```
