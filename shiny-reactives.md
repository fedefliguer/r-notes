# 
``` r
comando <- c("reactive","eventReactive","reactiveValues","observe","observeEvent")
crea_objeto <- c("sí","sí","sí","no","no")
aguarda_cumplimiento <- c("de cualquier input que contenga","del input que se defina como evento","siempre está definido, pero se va actualizando","de cualquier input que contenga","del input que se defina como evento")
outputs <- c("pueden llamarlo, con ()","pueden llamarlo, con ()","pueden llamarlo, con $ (es una lista)","no pueden llamar a nada creado ahí, se pueden generar dentro","no pueden llamar a nada creado ahí, se pueden generar dentro")

results <- data.frame(comando,crea_objeto,aguarda_cumplimiento, outputs)
print.data.frame(results)
```

```{r comment='', echo=FALSE, results='asis'}
 knitr::kable(mtcars[1:5,], caption = "A Knitr table.", floating.environment="sidewaystable")
```
