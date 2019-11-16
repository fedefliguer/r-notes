``` r
library(tidyverse)
```

## Forma convencional de hacer loops
``` r
for (i in c(1:10)){
     print (i^2)
     }
```

## Forma Tidy

### Para casos en los que el loop tiene una función con un input (y parámetros adicionales)

#### Opción 1: formalizar la función
``` r
cuadrado <- function(valor1) {
     valor1^2
 }
```

#### Opción 2: función implícita
``` r
map_dbl(.x = c(1:10), .f = function(x) x^2)
```

#### Opción 3: función gamma, ni siquiera declarando funciones
``` r
map_dbl(.x = c(1:10),.f = ~.x^2) 
```

### Para casos en los que el loop tiene una función con dos inputs (y parámetros adicionales)
``` r
map2_dbl(.x = c(1:10),.y = c(11:20),.f =  function(x,y) x*y)
```


#### Opción 1: formalizar la función
``` r
producto <- function(valor1, valor2) {
     valor1*valor2
 }
```
#### Opción 2: función implícita
``` r
map2_dbl(.x = c(1:10),.y = c(11:20),.f =  function(x,y) x*y)
```

#### Opción 3: función gamma, ni siquiera declarando funciones
``` r
map2_dbl(.x = c(1:10),.y = c(11:20),.f = ~.x*.y)
```

map y map2 iteran en paralelo sobre dos listas, por lo que no valen para casos en los que, por ejemplo, se quiera el producto de cacda elemento en c(1:10) por cada elemento en c(11:20), una lista de 100 resultados en vez de 10. Para ese caso hay que usar cross2 de la librería purrr.
