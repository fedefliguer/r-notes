``` r
library(tidyverse)
library(dplyr)
```

## Resumen de la estructura de la tabla
``` r
glimpse(df)
```

## Filtrar por filas
### Con AND
``` r
df %>% 
  filter(columna1>101 , columna2 == "Privado_Registrado")
```

### Con OR
``` r
df %>% 
  filter(columna1>101 | columna2 == "Privado_Registrado")
```

## Renombrar columna
``` r
df %>% 
  rename(nombreNuevo = columna)
```
 
## Ordenar
``` r
df %>% 
  arrange(columnasSeparadasPorComas, asc|desc)
```
  
## Seleccionar 
### Por la positiva
``` r
df %>% 
  select(columnasSeparadasPorComas)
```

### Por la negativa
``` r  
df %>% 
  select(-columnasSeparadasPorComas)
```

## Agrupar
``` r  
df %>% 
  group_by(columnasSeparadasPorComas)
```

## Agregar variable
``` r  
df <- df %>% 
  mutate(nombre = * columna * 2 - columna)
```
  
### Caso especial: variable percentil
``` r  
df = df %>% 
     mutate(quantile = ntile(columna, 10))
```
  
### Caso especial: variable case when
``` r  
df <- df %>% 
  mutate(nombre = case_when(GRUPO == "Privado_Registrado" ~ INDICE * 2,
                            GRUPO == "Público" ~ INDICE * 3))
```

### Aplanar
``` r  
df %>% 
  summarise(nombre = mean(columna))
```
  
## Joinear
``` r  
df_join <- df %>% 
  left_join(.,df2, by = columnaComún)
```
  
## Ejemplos de combinadas
``` r  
df %>% 
  group_by(FECHA) %>%
  summarise(Indprom = mean(INDICE))
```

``` r  
iris <- iris %>% 
  mutate(id = 1:nrow(.)) %>%  #le agrego un ID
  select(id, everything()) # lo acomodo para que el id este primero. 
```

## Filas y columnas
``` r  
library(tidyr)
```

### A partir de varias columnas, construir una columna clave-valor que agrande el largo del dataset 
``` r  
iris_vertical <- iris %>% gather(key   = newColumnKey,      # Nueva columna clave
                                 value = newColumnValue     # Nueva columna valor
                                 2:5) # Que columnas juntar
```

### A partir de las filas de una columna, construir varias columnas que achiquen el largo del dataset
``` r  
iris_horizontal <- iris_vertical %>%
  spread(key   = Variables,                                 # Variable que quiero que se me 'desdoble' en columnas
         value = Valores)                                   # Valores con que se llenan las celdas
```
 
### Tratamiento de los DATE
``` r  
library(lubridate)
```

``` r  
fecha2 <- parse_date_time(fecha2, orders = 'my')
year(fecha)
month(fecha)
day(fecha)
hour(fecha)
fecha + days(2)
```

### Tratamiento de las anidadas (una columna contiene DFs)
#### Si todas tienen la misma cantidad de columnas
``` r  
bases_df <- bases_df %>% unnest()
```

#### Si no todas tienen la misma cantidad de columnas
``` r  
bases_df = bases_df %>% 
              group_by(REGION) %>% 
              nest()                                          # Con esto cada valor pasa de ser un df a ser un vector
```

