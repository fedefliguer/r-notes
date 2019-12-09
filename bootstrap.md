``` r
library(tidyverse)
library(rsample)
library(GGally)
library(robust)
library(ggplot2)
library(rsample)
library(ggridges)
```
A partir de un df que es la muestra que nosotros observamos (de una población que no conocemos, como siempre) buscamos comprobar qué tanto ajusta el modelo, es decir qué tan bien funciona en repetidos casos. Para eso, nuestro data frame pasa a ser la base de una muestra que se toma múltiples veces con reposición.

## Armado del bootstrap
``` r
muestras_bootstrapeadas <- bootstraps(df,times = 100)
```
La base muestras_bootstrapeadas ahora tiene tantas filas como times (100), y cada una tiene un id y un split, que es una submuestra del tamaño del largo del df, con tantas columnas como variables.

### Ejemplo de un split
``` r
muestras_bootstrapeadas %>% 
  filter(id=="Bootstrap001") %$%
  splits[[1]][[1]]
```
Acá se ve un split completo: una lista de muestras tomadas como filas del df que pueden repetirse.

## Funciones para comprobar el modelo
``` r
ajuste_lineal_simple <- function(df){
  lm(y~x1+x2+x3,data = df)
}

ajuste_lineal_robusto <- function(df){
  lmRob(y~x1+x2+x3,data = df)
}

muestras_bootstrapeadas <- muestras_bootstrapeadas %>% 
  mutate(lm_simple = map(splits, ajuste_lineal_simple),
         lm_rob = map(splits, ajuste_lineal_robusto))
```
Se generó una función para aplicar modelo lineal y otra para modelo lineal robusto, agregando columnas a cada split (muestra) con el resultado de cada uno de esos modelos.

### Lo llevo a una forma visualizable
``` r
parametros <- muestras_bootstrapeadas %>%
  gather(3:4) %>% 
  mutate(tdy = map(statistic,tidy)) %>% 
  unnest(tdy, .drop=TRUE)
```
Cada fila de mi df es un parámetro estimado por regresión simple o robusta: jústamente bootstrap es para determinar si esas estimaciones son parecidas o no lo son.

## Conclusión
``` r
ggplot(parametros, aes(estimate,y=model, fill = model))+
  geom_density_ridges(alpha=.6)+
  theme_minimal()+
  scale_color_manual(values = "darkolivegreen","")+
  theme(legend.position = "bottom")+
  facet_wrap(~term,scales = "free")
```
![Conclusión](https://www.imageupload.net/upload-image/2019/12/09/test.png)

Como la distribución es tan diferente, el método ayudó a visualizar el problema de generar un modelo lineal: la inconstancia en los parámetros, cosa que en los robustos es mucho más fija.
