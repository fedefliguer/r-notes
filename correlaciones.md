``` r
library(corrr)
library(GGally)
library(tidyverse)
```

## Varias formas de graficar las correlaciones a la vez
``` r
ggpairs()                                # O el conjunto de columnas seleccionado
```

## Forma un poco más ordenada de visualizar esto
``` r
mtcars %>% 
 correlate() %>% 
  rplot()
```


## Tabla con todas las correlaciones de Pearson
``` r
df %>% 
 correlate() %>% 
  shave() %>% 
  fashion()
```

## Test de correlación
``` r
cor.test(df$columna1,df$columna2)
```

### En presencia de outliers
``` r
cor.test(df$columna1,df$columna2, method = "spearman")
```
