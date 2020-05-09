## Operar sobre una columna ignorando nulos
``` r
library(mice)
md.pattern(iris, rotate.names=TRUE)   # Gráfico con el resumen de los missing para el dataset iris
```

## Operar sobre una columna ignorando nulos
``` r
mean(iris$Petal.Length, na.rm = TRUE)
```

## Imputar la media de los valores disponibles
``` r
iris.imp$media[is.na(iris.imp$media)]<-mean(iris.imp$media, na.rm = TRUE)
```

## Imputar por regresión
``` r
rl_model<-lm(iris.imp$Sepal.Length ~ iris.imp$Sepal.Width+iris.imp$Petal.Length, data = iris.imp)
SW<-iris.imp$Sepal.Width[is.na(iris.imp$Sepal.Length)]
PL<-iris.imp$Petal.Length[is.na(iris.imp$Sepal.Length)]
coef<-rl_model$coefficients
iris.imp$Sepal.Length[is.na(iris.imp$Sepal.Length)]<-coef[1]+SW*coef[2]+PL*coef[3]
```

## Imputar por Hot Deck
``` r
library(VIM)
df_aux<-hotdeck(iris, variable="Sepal.Length")
```

## Imputar por Hot Deck
``` r
library(mice)                                                 # El método funciona bajo el supuesto Missing At Random (MAR): La probabilidad de que falte un valor depende solo de los valores observados y no de los valores no observados.
imputed_Data <- mice(iris, maxit = 3, method = 'pmm')         # pmm hace la imputación inicial a través de l amedia.
completeData <- complete(imputed_Data)
iris.imp$mice <- completeData$Sepal.Length
```
