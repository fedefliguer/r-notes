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
dat3 = mydata[, c("origin", "year", "month", "hour"), with=FALSE] # Se queda con varias columnas definiendolas con comillas (hay que usar with=FALSE en esos casos)
dat6 = mydata[, !c("origin", "year", "month"), with=FALSE] # Elimina

dat9 = mydata[origin %in% c("JFK", "LGA")] # Filtra filas
dat10 = mydata[!origin %in% c("JFK", "LGA")] # Filtra filas por la negativa
dat11 = mydata[origin == "JFK" & carrier == "AA"] # Filtra por dos condiciones
dat3 = mydata[month %between% c(2, 5)] # Se queda con varias columnas # Puede filtrar con between o con like

dt[,mean(mpg)] # Sumariza el promedio de una columna
dt[,mean(mpg),by=am] # Sumariza el promedio de una columna por grupos
dt[,mean(mpg),by=.(am,cyl)] # Sumariza el promedio de una columna por grupos de dos variables
mydata[, lapply(.SD, mean, na.rm = TRUE), .SDcols = c("arr_delay", "dep_delay"), by = origin] # Calcula el promedio de varias columnas por una variable

dt[mpg > 20,.(avg=mean(mpg)),by=.(am,cyl)] # Combinación de las tres cosas
```

## Otros
### Sorting
``` r
dt[order(-mpg,wt)][1:5]
```

### Key
Se le puede asignar una key al df haciendo más facil el filtro. No hace falta especificar columnas al filtrar en ese caso
``` r
setkey(mydata, origin, dest)
mydata[.("JFK", "MIA")] # Se quedará con filas cuyo origen sea JFK y dest sea MIA
```

### Agregar columnas sin definir nada
``` r
mydata[, dep_sch:=dep_time - dep_delay] # Agrega una columna
mydata[, c("dep_sch","arr_sch"):=list(dep_time - dep_delay, arr_time - arr_delay)] # Agrega varias columnas
```

#### Agregar columnas if-else
``` r
mydata[, flag:= ifelse(min < 50, 1,0)]
```

### Sumarizar todas las columnas numéricas
``` r
mydata[, lapply(.SD, mean)] # Con funciones básicas
mydata[, sapply(.SD, function(x) c(mean=mean(x), median=median(x)))] # Con funciones más complejas
```

### CUMSUM
``` r
dat = mydata[, cum:=cumsum(distance), by=carrier]
```

### Rank over partition
``` r
dt = mydata[, rank:=frank(-distance,ties.method = "min"), by=carrier] # Una nueva columna asignará el valor 1, 2, 3 dentro de cada carrier, ordenando por distance.
```

### Rank over partition
``` r
DT <- data.table(A=1:5)
DT[ , X := shift(A, 1, type="lag")] # Genera una nueva columna con los valores una fila después
DT[ , Y := shift(A, 1, type="lead")] # Genera una nueva columna con los valores una fila antes
```
