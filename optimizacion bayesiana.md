# Ejemplo 1 -> SVM con dataset Iris
## Instalación de librerías
``` r
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
```

## Carga de dataset y configuración inicial
``` r
iris = data.table(iris)
configureMlr(show.learner.output = FALSE) # Configuración de lo que quiero ver durante el ajuste de parámetros
iters = 3 # Número de iteraciones
par.set = makeParamSet(
  makeNumericParam("cost", -15, 15, trafo = function(x) 2^x),
  makeNumericParam("gamma", -15, 15, trafo = function(x) 2^x)
) # Se definen los parámetros, en este caso por medio de una transformación
```

## Generación de la función a maximizar/minimizar.
``` r
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
```

## Ajustes finales
``` r
ctrl = makeMBOControl()
ctrl = setMBOControlTermination(ctrl, iters = iters)
```

## Genero el objeto que guarda el resultado de la optimización.
``` r
res = mbo(svm, control = ctrl, show.info = FALSE)
```

### Ejemplo 2: Random Forest
``` r
library(data.table)
library(mlr)
library(mlrMBO)
library(DiceKriging)
library(e1071)
library(rgenoud)
library(ranger)

iris = data.table(iris)

iris[, target := ifelse(Species=='setosa', 1, 0)]
iris[, Species := NULL]

dtrain = iris[sample(.N,120)]
dtest = iris[sample(.N,30)]

estimar_ranger <- function( x )
{
  modelo  <- ranger( formula= "target ~ .",
                     data= dtrain, 
                     probability=   TRUE, 
                     num.trees=     x$pnum.trees,
                     mtry=          x$pmtry,
                     min.node.size= x$pmin.node.size,
                     max.depth= x$pmax.depth
  )
  
  prediccion_test  <- predict( modelo, dtest )
  
  ganancia_test  <- sum( (prediccion_test$predictions[,1] > 0.015) * 
                           dtest[, ifelse( target==1,29250,-750)])
  return( ganancia_test )
}

configureMlr(show.learner.output = FALSE) # Configuración de lo que quiero ver durante el ajuste de parámetros
iteraciones = 100 # Número de iteraciones

obj.fun  <- makeSingleObjectiveFunction(
  fn   = estimar_ranger,
  minimize= FALSE,
  noisy=    TRUE,
  par.set = makeParamSet(
    makeIntegerParam("pnum.trees",     lower=100L, upper= 999L),
    makeIntegerParam("pmtry",          lower=  2L, upper=  3L),
    makeIntegerParam("pmin.node.size", lower=  1L, upper=  5L),
    makeIntegerParam("pmax.depth",     lower=  0L, upper=  8L)),
  has.simple.signature = FALSE
)

ctrl = makeMBOControl()
ctrl  <-  setMBOControlTermination(ctrl, iters = iteraciones )
surr.km  <-  makeLearner("regr.km", predict.type= "se", covtype= "matern3_2", control = list(trace = FALSE))

res = mbo(obj.fun, learner = surr.km, control = ctrl, show.info = FALSE)
print(res)

res$x$pnum.trees
res$x$pmtry

modelo_final  <- ranger( formula= "target ~ .",
                         data= dtrain,
                         probability=   TRUE,  #para que devuelva las probabilidades
                         num.trees=     res$x$pnum.trees,
                         mtry=          res$x$pmtry,
                         min.node.size= 4,
                         max.depth=     12
)
```
