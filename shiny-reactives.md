# Resumen

| comando       | crea un objeto | aguarda cumplimiento de algo | relación con outputs |
| ------------- | -------------- | ---------------------------- | -------------------- |
| reactive  | sí   | de cualquier input que contenga                 | pueden llamarlo, con ()         |
| eventReactive  | sí   | del input que se defina como evento                 | pueden llamarlo, con ()         |
| reactiveValues  | sí   | siempre está definido, pero se va actualizando                 | pueden llamarlo, con $ (es una lista)         |
| observe  | no   | de cualquier input que contenga                 | no pueden llamar a nada creado ahí, se pueden generar dentro         |
| observeEvent  | no   | del input que se defina para observar                 | no pueden llamar a nada creado ahí, se pueden generar dentro         |


# Ejemplos

## reactive
Crea un objeto pasible de ser llamado en el output, que cada vez que un input que contenga cambie, quedará inhabilitado y se recalculará, así como todos los outputs que invoquen el objeto reactivo, al que hay que invocar con (). Funciona más en línea con la filosofía de programación reactiva de shiny, lo que significa que la expresión reactive() simplemente le dice a shiny cómo se calcula la variable, sin tener que especificar cuándo. Shiny se encargará de determinar cuándo calcularlo. Serán evaluados de manera perezosa (solo cuando sea necesario), almacenarán en caché su valor. Es la forma en que se diseñó shiny y siempre debe ser la primera opción.

```{r}
library(shiny)

ui <- fluidPage(
  headerPanel("Example reactive"),
  
  mainPanel(
    
    # input field
    textInput("user_text", label = "Enter some text:", placeholder = "Please enter some text."),
    
    # display text output
    textOutput("text"))
)

server <- function(input, output) {
  
  # reactive expression
  text_reactive <- reactive({
    input$user_text
  })
  
  # text output
  output$text <- renderText({
    text_reactive()
  })
}

shinyApp(ui = ui, server = server)
```

## eventReactive
Casi análogo al reactive, con la diferencia de que no siempre que cada vez que un input que contenga cambie quedará inhabilitado, sino que únicamente al cumplimiento de un evento.

```{r}
library(shiny)

ui <- fluidPage(
  headerPanel("Example eventReactive"),
  
  mainPanel(
    
    # input field
    textInput("user_text", label = "Enter some text:", placeholder = "Please enter some text."),

    # submit button
    actionButton("submit", label = "Submit"),
    
    # display text output
    textOutput("text"))
)

server <- function(input, output) {
  
  # reactive expression
  text_reactive <- eventReactive( input$submit, {
    input$user_text
  })
  
  # text output
  output$text <- renderText({
    text_reactive()
  })
}

shinyApp(ui = ui, server = server)
```
