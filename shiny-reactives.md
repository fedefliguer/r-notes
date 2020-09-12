# Resumen

| comando       | se define creando un objeto | aguarda cumplimiento de algo | relación con outputs |
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

## reactiveValues
Al igual que reactive, cuando cambia algún input que contiene se va actualizando. Es una lista de valores, y debería ser utilizado en los casos en los que no aplique reactive. Se elige reactiveValues en dos casos, especialmente. En primer lugar (ejemplo 1) cuando tenemos una variable que es una especie de 'estado' en la que el input lo actualiza, y no cuando el input es un valor en sí mismo. En segundo lugar (ejemplo 2), se prefiere reactiveValues cuando una variable puede ser actualizada en muchos lugares distintos del código. Se considera más parecido a la programación imperativa que a la reactiva, porque el código se ocupa de definir el valor de algo y no de esperar una acción a la que reaccionar.

### ejemplo 1
```{r}
library(shiny)

ui <- fluidPage(
  "Total:",
  textOutput("total", inline = TRUE),
  actionButton("add1", "Add 1"),
  actionButton("add5", "Add 5")
)

server <- function(input, output, session) {
  values <- reactiveValues(total = 0)

  observeEvent(input$add1, {
    values$total <- values$total + 1
  })
  observeEvent(input$add5, {
    values$total <- values$total + 5
  })
  output$total <- renderText({
    values$total
  })
}

shinyApp(ui = ui, server = server)
```

### ejemplo 2
```{r}
library(shiny)

fib <- function(n) ifelse(n < 3, 1, fib(n - 1) + fib(n - 2))

ui <- fluidPage(
  selectInput("nselect", "Choose a pre-defined number", 1:10),
  numericInput("nfree", "Or type any number", 1),
  "Fib number:",
  textOutput("nthval", inline = TRUE)
)

server <- function(input, output, session) {
  values <- reactiveValues(n = 1)
  
  observeEvent(input$nselect, {
    values$n <- input$nselect
  })
  observeEvent(input$nfree, {
    values$n <- input$nfree
  })
  output$nthval <- renderText({
    fib(as.integer(values$n))
  })
}

shinyApp(ui = ui, server = server)
```

## observe
Una expresión observe se activa cada vez que cambia alguno de sus inputs. La principal diferencia con respecto a una expresión reactiva es que no genera un objeto, por lo que solo debe usarse para efectos secundarios (como modificar un objeto reactiveValues o activar una ventana emergente). observe no ignora los NULL, por lo que se activará incluso si los inputs son NULL. La forma de evitar que el observe reaccione a determinados inputs es aplicarles isolate().

```{r}
library(shiny)

ui <- fluidPage(
  headerPanel("Example reactive"),
  
  mainPanel(
    
    # action buttons
    actionButton("button1","Button 1"),
    actionButton("button2","Button 2")
  )
)

server <- function(input, output) {
  observe({
    input$button1
    isolate(input$button2)
    showModal(modalDialog(
      title = "Button pressed",
      "You pressed one of the buttons!"
    ))
  })
}

shinyApp(ui = ui, server = server)
```

## observeEvent
Es igual al observe, pero se asume que todos los inputs, excepto los referidos al inicio del observeEvent, están isolate(). El código del ejemplo hace lo mismo que el de observe, pero en ese caso porque explícitamente se evitaba la dependencia con el input$button2, y en este porque explícitamente se pide la dependencia sólo con el input$button1.

```{r}
library(shiny)

ui <- fluidPage(
  headerPanel("Example reactive"),
  
  mainPanel(
    
    # action buttons
    actionButton("button1","Button 1"),
    actionButton("button2","Button 2")
  )
)

server <- function(input, output) {
  observeEvent(input$button1, {
    input$button2  
    showModal(modalDialog(
      title = "Button pressed",
      "You pressed one of the buttons!"
    ))
  })
}

shinyApp(ui = ui, server = server)
```

