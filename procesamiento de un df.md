``` r
library(tidyverse)
library(dplyr)
```

# Resumen de la estructura de la tabla
``` r
glimpse(df)
```

# Filtrar por filas
## Con AND
``` r
df %>% 
  filter(columna1>101 , columna2 == "Privado_Registrado")
```

## Con OR
``` r
df %>% 
  filter(columna1>101 | columna2 == "Privado_Registrado")
```

# Renombrar columna
df %>% 
  rename(nombreNuevo = columna)
  
# Ordenar
df %>% 
  arrange(columnasSeparadasPorComas, asc|desc)
  
# Seleccionar por la positiva
df %>% 
  select(columnasSeparadasPorComas)
  
df %>% 
  select(-columnasSeparadasPorComas)

# Agrupar
df %>% 
  group_by(columnasSeparadasPorComas)

# Agregar variable
df <- df %>% 
  mutate(nombre = * columna * 2 - columna)
  
## Caso especial: variable percentil
df = df %>% 
     mutate(quantile = ntile(columna, 10))
  
## Caso especial: variable case when
df <- df %>% 
  mutate(nombre = case_when(GRUPO == "Privado_Registrado" ~ INDICE * 2,
                            GRUPO == "Público" ~ INDICE * 3))

# Aplanar
df %>% 
  summarise(nombre = mean(columna))
  
# Joinear
df_join <- df %>% 
  left_join(.,df2, by = columnaComún)
  
# Ejemplo de combinadas
df %>% 
  group_by(FECHA) %>%
  summarise(Indprom = mean(INDICE))
  
iris <- iris %>% 
  mutate(id = 1:nrow(.)) %>%  #le agrego un ID
  select(id, everything()) # lo acomodo para que el id este primero. 

# Filas y columnas
library(tidyr)
## A partir de varias columnas, construir una columna que agrande el largo del dataset 
iris_vertical <- iris %>% gather(., # el . llama a lo que esta atras del %>% 
                                 key   = Variables,
                                 value = Valores,
                                 2:5) #le indico que columnas juntar

## A partir de las filas de una columna, construir varias columnas que achiquen el largo del dataset
iris_horizontal <- iris_vertical %>%
  spread(. ,
         key   = Variables, #la llave es la variable que va a dar los nombres de columna
         value = Valores) #los valores con que se llenan las celdas
 
# Tratamiento de los DATE
library(lubridate)
fecha2 <- parse_date_time(fecha2, orders = 'my')
year(fecha)
month(fecha)
day(fecha)
hour(fecha)
fecha + days(2)

# Tratamiento de las anidadas (una columna contiene DFs)
## Si todas tienen la misma cantidad de columnas
bases_df <- bases_df %>% unnest()

## Si no todas tienen la misma cantidad de columnas
bases_df = bases_df %>% 
              group_by(REGION) %>% 
              nest() # Con esto cada valor pasa de ser un df a ser un vector
