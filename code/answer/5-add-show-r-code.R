# https://insightsengineering.github.io/teal.data/latest-tag/articles/teal-data-reproducibility.html#retrieving-code
# Add teal.widgets::verbatim_popup_ui to ui module
# Add teal.widgets::verbatim_popup_srv to server module
# The value of teal.widgets::verbatim_popup_srv(verbatim_content=) have to be in reactive context

library(teal)
library(ggplot2)

tealmodule_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    shiny::selectInput(
      inputId = ns("datasets"),
      label = "Datasets",
      choices = NULL
    ),
    shiny::selectInput(
      inputId = ns("variables"),
      label = "Variables",
      choices = NULL
    ),
    shiny::sliderInput(
      inputId = ns("binwidth"),
      label = "Binwidth",
      min = 0,
      max = 5,
      step = 0.5,
      value = 2
    ),
    shiny::plotOutput(ns("plt")),
    ## Add code here
    teal.widgets::verbatim_popup_ui(
      id = ns("rcode"),
      button_label = "Show R Code"
    )

  )
}

tealmodule_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    shiny::updateSelectInput(
      inputId = "datasets",
      choices = datanames(data())
    )

    observeEvent(input$datasets, {
      req(input$datasets)
      only_numeric <- sapply(data()[[input$datasets]], is.numeric)

      shiny::updateSelectInput(
        inputId = "variables",
        choices = names(data()[[input$datasets]])[only_numeric]
      )
    })

    result <- reactive({
      req(input$datasets)
      req(input$variables %in% names(data()[[input$datasets]]))
      new_data <- within(
        data(),
        {
          my_plot <- ggplot(input_dataset, aes(x = input_vars)) +
            geom_histogram(binwidth = input_binwidth, fill = "skyblue", color = "black")
        },
        input_dataset = as.name(input$datasets),
        input_vars = as.name(input$variables),
        input_binwidth = input$binwidth
      )
      new_data
    })

    output$plt <- shiny::renderPlot({
      result()[["my_plot"]]
    })

    ## Add code here
    teal.widgets::verbatim_popup_srv(
      id = "rcode",
      verbatim_content = reactive(get_code(result())),
      title = "Code to reproduce the analysis"
    )

  })
}

my_custom_module <- function(label = "My Custom Teal Module") {
  module(
    label = label,
    ui = tealmodule_ui,
    server = tealmodule_server,
    datanames = "all"
  )
}

data <- teal_data(
  adsl = teal.data::rADSL,
  adae = teal.data::rADAE,
  code = "
    adsl = teal.data::rADSL
    adae = teal.data::rADAE
  "
)

data <- verify(data)

app <- init(
  data = data,
  modules = modules(
    my_custom_module()
  ),
  header = "my teal app"
)

shinyApp(app$ui, app$server)
