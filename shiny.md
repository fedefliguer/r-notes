# Paso 1: Creo la interfaz de usuario
```{r }
# Interfaz de usuario
ui <- fluidPage(
  
  # Títuo de la APP
  titlePanel("Clusters por variables duras - Drivers transaccionales"),
  
  sidebarLayout(
    sidebarPanel(
      
      # Input: Cantidad de observaciones en la muestra ----
      sliderInput(inputId = "n",
                  label = "Número de observaciones incluidas:",
                  min = 10000,
                  max = 1379382,
                  value = 100000), 
      
      # Input: Cantidad de clusters ----
      sliderInput(inputId = "k",
                  label = "Número de clusters:",
                  min = 2,
                  max = 10,
                  value = 4),
      
      # Input: Parametro en dummies  ----
      sliderInput(inputId = "d",
                  label = "Parametro en dummies:",
                  min = 0.01,
                  max = 1,
                  value = 0.5),
      
      selectInput(inputId = "var", h3("Variable"), 
                  choices = list("Población transaccional" = "cd_poblacion",
                                 "Cluster transaccional" = "cd_cluster",
                                 "Antigüedad en el banco" = "gr_antiguedad",
                                 "Quintil de ingreso estimado" = "gr_ingreso",
                                 "Género" = "FixGenero",
                                 "Zona" = "FixZona"), selected = 1),
      
      br(),
      
      # Botón de acción para la parte isolada
      actionButton("goButton", "Go!")
      
    ),
    
    # Panel central con los outputs
    mainPanel(
      
      # Output
      plotOutput(outputId = "distPlot")
      
    )
  )
)
```

# Paso 2: Creo la función para graficar
```{r }
server <- function(input, output) {
  output$distPlot <- renderPlot({
    input$goButton
    df <- df[sample(nrow(base), isolate(input$n) ), ]
    columna_dummy <- function(df, columna) {
      df %>% 
        mutate_at(columna, ~paste(columna, eval(as.symbol(columna)), sep = "_")) %>% 
        mutate(valor = input$d) %>% 
        spread(key = columna, value = valor, fill = 0)
    }
    
    df$FixZona = df$zona
    df$FixGenero = df$cd_genero
    df$FixActividad = df$cd_actividad_rubro
    df = columna_dummy(df, "cd_genero")
    df = columna_dummy(df, "zona")
    df = columna_dummy(df, "cd_actividad_rubro")
    
    cl = df %>% select(
      cd_cliente,
      nu_edad,
      percentil_ingreso_estimado,
      nu_entidades_0,
      percentil_deuda_nobg,
      cd_genero_F,
      cd_genero_M,
      19:42
    )
    
    cl = cl[complete.cases(cl), ]
    
    km = kmeans(cl[,2:31], input$k)
    cl$cluster = km$cluster
    cl = cl %>% select(cd_cliente, cluster)
    df_clustered = left_join(df, cl, by = "cd_cliente")
    df_clustered$nu_antiguedad = round((Sys.Date()-df_clustered$fc_alta)/365,0)
    df_clustered$gr_antiguedad = case_when(df_clustered$nu_antiguedad < 2 ~ "Menos de 2 años",
                                           df_clustered$nu_antiguedad < 5 ~ "2 a 5 años",
                                           df_clustered$nu_antiguedad < 10 ~ "5 a 10 años",
                                           df_clustered$nu_antiguedad > 10 ~ "Más de 10 años")
    df_clustered$gr_ingreso = case_when(df_clustered$vl_numerico < quantile(df_clustered$vl_numerico, 0.2) ~ "1",
                                        df_clustered$vl_numerico < quantile(df_clustered$vl_numerico, 0.4) ~ "2",
                                        df_clustered$vl_numerico < quantile(df_clustered$vl_numerico, 0.6) ~ "3",
                                        df_clustered$vl_numerico < quantile(df_clustered$vl_numerico, 0.8) ~ "4",
                                        TRUE ~ "5")
    plot = df_clustered %>% select(
      cluster,
      gr_antiguedad,
      gr_ingreso,
      FixZona,
      FixGenero,
      FixActividad,
      cd_poblacion,
      cd_cluster
    )
    plot = cbind(plot[1], stack(plot[-1]))
    plot = plot %>% count(cluster, ind, values)
    plot = plot %>% filter(ind == input$var)
    ggplot(plot, aes(fill=values, y=n, x=cluster)) + 
      geom_bar(position="stack", stat="identity")
  })
}
```

# Paso 3: Publico la app
```{r }
# Creación de la App
shinyApp(ui = ui, server = server)
```
