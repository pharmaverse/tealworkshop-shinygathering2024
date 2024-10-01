# ?teal.widgets::standard_layout

library(teal)
library(ggplot2)

tealmodule_ui <- function(id) {
  ns <- NS(id)

  ## Use teal.widgets::standard_layout here
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
    teal.reporter::simple_reporter_ui(ns("reporter"))

  )

}

tealmodule_server <- function(id, data, reporter, filter_panel_api) {
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

    card_fun <- function(card = teal::TealReportCard$new()) {
      card$append_fs(filter_panel_api$get_filter_state())
      card$append_text(paste("Selected dataset", input$datasets))
      card$append_plot(result()[["my_plot"]])
    }

    teal.reporter::simple_reporter_srv(
      id = "reporter",
      reporter = reporter,
      card_fun = card_fun
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
  header = "Shiny Gathering 2024"
)

shinyApp(app$ui, app$server)
