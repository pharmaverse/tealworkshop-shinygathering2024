# https://insightsengineering.github.io/teal/latest-tag/articles/adding-support-for-reporting.html#tealreportcard
#
# * Add reporter argument in your server module
# * Use teal.reporter::simple_reporter_ui in ui
# * Use teal.reporter::simple_reporter_srv in server
# * create card_func to be included in teal.reporter::simple_reporter_srv
# * append text and append plot
# * Learn about filter_panel_api
# * append filter state to the card_func

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
    teal.widgets::verbatim_popup_ui(
      id = ns("rcode"),
      button_label = "Show R Code"
    ),
    # Add code here

  )
}

# Update argument
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

    teal.widgets::verbatim_popup_srv(
      id = "rcode",
      verbatim_content = reactive(get_code(result())),
      title = "Code to reproduce the analysis"
    )

    # Add code here

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
  header = "Shiny Gathering 2024"
)

shinyApp(app$ui, app$server)
