``` r
combinaciones = list()
grupos = c('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J')
ponderaciones = c(0.02, 0.05, 0.09, 0.03, 0.12, 0.04, 0.03, 0.01, 0.02, 0.04, 0.05, 0.09, 0.03, 0.12, 0.04, 0.03, 0.01, 0.02, 0.04, 0.05, 0.05, 0.06)

j = 1
for (i in ponderaciones){
  combinaciones[[j]] = c(0,i)
  j = j + 1
}

combinaciones_ponderaciones = expand.grid(combinaciones)
combinaciones_ponderaciones$total = rowSums(combinaciones_ponderaciones)

j = 1
for (i in grupos){
  combinaciones[[j]] = c(0,i)
  j = j + 1
}

combinaciones_grupos = expand.grid(combinaciones)

# Agregar en ambas una columna con el row number
# Luego, guardarme los row numbers menores a X, y llevarmelos de la otra tabla
# Concatenar los valores que no sean 0 de la tabla de nombres en una única fila, conformando los modelos que serían 'potables'
  # Potable = Que no tenga más variables que observaciones
  # Potable = Que no supere la cantidad de encuestas que pueden tomarse
# Entre esos modelos elijo el mejor
# Cross-validation
```
