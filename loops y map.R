library(tidyverse)

# Forma convencional de hacer loops

for (i in c(1:10)){
     print (i^2)
     }

# Forma Tidy

## Para casos en los que el loop tiene una función con un input (y parámetros adicionales)

### Opción 1: formalizar la función
cuadrado <- function(valor1) {
     valor1^2
 }

map(.x = c(1:10), .f = cuadrado)

### Opción 2: función implícita
map_dbl(.x = c(1:10), .f = function(x) x^2) # En este caso no se usa ningún parámetro adicional, calculando el cuadrado. map_dbl devuelve lo mismo que map pero en forma de vector.

### Opción 3: función gamma, ni siquiera declarando funciones
map_dbl(.x = c(1:10),.f = ~.x^2) 

## Para casos en los que el loop tiene una función con dos inputs (y parámetros adicionales)
map2_dbl(.x = c(1:10),.y = c(11:20),.f =  function(x,y) x*y)
