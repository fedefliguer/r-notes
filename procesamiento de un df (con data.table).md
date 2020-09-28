``` r
library(data.table)
```

## Leer un csv más rápido que el read.csv de R nativo
``` r
fread("chi_crimes.csv", header=TRUE,sep=",")
```
## Sintaxis
*Resumen*: Es análogo a SQL, con la idea de que en la sentencia df[i, j, by] el i será el where (qué filas entran) el j será el select (qué columnas entran) y el by será el group que se quiera hacer.

### Ejemplos
``` r
dat1 = mydata[ , .(origin)] # Se queda con una columna
dat3 = mydata[, .(origin, year, month, hour)] # Se queda con varias columnas
dat6 = mydata[, !c("origin", "year", "month"), with=FALSE] # Elimina

dat9 = mydata[origin %in% c("JFK", "LGA")] # Filtra filas
dat10 = mydata[!origin %in% c("JFK", "LGA")] # Filtra filas por la negativa
dat11 = mydata[origin == "JFK" & carrier == "AA"] # Filtra por dos condiciones

dt[,mean(mpg)] # Sumariza el promedio de una columna
dt[,mean(mpg),by=am] # Sumariza el promedio de una columna por grupos
dt[,mean(mpg),by=.(am,cyl)] # Sumariza el promedio de una columna por grupos de dos variables

dt[mpg > 20,.(avg=mean(mpg)),by=.(am,cyl)] # Combinación de las tres cosas
```

## Otros
### Sorting
``` r
dt[order(-mpg,wt)][1:5]
```
