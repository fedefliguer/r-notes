``` r
library(data.table)
```

## Escribo los nombres de las que resultarán categóricas
``` r
campos_categoricos <- c('cd_civil', 'cd_provincia', 'cd_mod_atencion',...)
```

## Creo df con esos dummies
``` r
df_dummies <- as.data.table(df[,campos_categoricos])
```

## Transformo cada una en categórica
``` r
df_dummies[ , lapply(.SD, factor)]                      # .SD significa subsetdata. Lappy calcula una función 
                                                        para todos los elementos de una lista (factor es para 
                                                        crear variable categórica)  
```



## Creo la función para binarizar
``` r
f_flag = function(valor_columna) return( ifelse( valor_columna %in% valor, 1, 0 ) )
```

## Proceso por columnas

### Recuperamos los tres primeros elementos de la lista resultados

``` r
for(columna in campos_categoricos)
{
  agrupado <- setorder(df_dummies[, .N, by = eval((columna))])                  # Busco los campos (las opciones de respuesta) con su frecuencia
  agrupado <- agrupado[ N > nu_cantidad_total_muestra / 200 ]                   # Me quedo únicamente con campos que tengan más del 0.5% de la frecuencia
  for(n in 1:nrow(agrupado))                                                    # Por cada campo
  {
    valor <- as.character(agrupado[n, ..columna][[1]])                          # Defino el nombre del campo que buscará luego la función
    if(valor != '' & !is.na(valor))                                             # Únicamente cuando el campo no es nulo ni vacío
    {
      if(grepl('^cd', columna))                                                 # Condición para que queden estructuradas todas igual (puede no ser necesaria) 
      {
        tx_columna_dummy <- c( paste0(sub('^cd', 'fl', tolower(columna)), '', gsub(" ", "", valor)))
      } else
      {
        tx_columna_dummy <- c(paste0('fl_', tolower(columna), '_', gsub(" ", "", valor)))
      }
      df_dummies[, (tx_columna_dummy) := lapply(.SD, f_flag), .SDcols = columna] # Por cada campo pido que se ejecute la función que binariza
    }
  }
  df_dummies[, (columna) := NULL]
}
```

