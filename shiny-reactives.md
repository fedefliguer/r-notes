# 
``` r
comando <- c("reactive","eventReactive","reactiveValues","observe","observeEvent")
crea_objeto <- c("sí","sí","sí","no","no")
aguarda_cumplimiento <- c("de cualquier input que contenga","del input que se defina como evento","siempre está definido, pero se va actualizando","de cualquier input que contenga","del input que se defina como evento")
outputs <- c("pueden llamarlo, con ()","pueden llamarlo, con ()","pueden llamarlo, con $ (es una lista)","no pueden llamar a nada creado ahí, se pueden generar dentro","no pueden llamar a nada creado ahí, se pueden generar dentro")

results <- data.frame(comando,crea_objeto,aguarda_cumplimiento, outputs)
print.data.frame(results)
```

| comando       | crea un objeto | aguarda cumplimiento de algo | relación con outputs |
| ------------- | -------------- | ---------------------------- | -------------------- |
| reactive  | sí   | de cualquier input que contenga                 | pueden llamarlo, con ()         |
| eventReactive  | sí   | del input que se defina como evento                 | pueden llamarlo, con ()         |
| reactiveValues  | sí   | siempre está definido, pero se va actualizando                 | pueden llamarlo, con $ (es una lista)         |
| observe  | no   | de cualquier input que contenga                 | no pueden llamar a nada creado ahí, se pueden generar dentro         |
| observeEvent  | no   | del input que se defina para observar                 | no pueden llamar a nada creado ahí, se pueden generar dentro         |
