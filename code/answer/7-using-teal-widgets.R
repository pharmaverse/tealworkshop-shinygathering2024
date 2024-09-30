# https://insightsengineering.github.io/teal/latest-tag/articles/adding-support-for-reporting.html#tealreportcard
# ?teal.widgets::standard_layout
library(teal)
library(ggplot2)

custom_module_ui <- function(id) {
  ns <- NS(id)

  teal.widgets::standard_layout(
    output = shiny::plotOutput(ns("my_plot")),
    encoding = tags$div(
      teal.reporter::simple_reporter_ui(ns("reporter")),
      shiny::selectInput(
        ns("datasets"),
        label = "select dataset",
        choices = NULL
      ),
      shiny::selectInput(
        ns("variables"),
        label = "select variable",
        choices = NULL
      ),
      shiny::sliderInput(
        ns("binwidth"),
        label = "select binwidth",
        min = 0,
        max = 5,
        value = 2,
        step = 0.5
      )
    ),
    forms = shiny::tagList(
      teal.widgets::verbatim_popup_ui(ns("rcode"), "Show R code")
    )
  )

}

custom_module_server <- function(id, data, reporter, filter_panel_api) {
  moduleServer(id, function(input, output, session) {

    updateSelectInput(
      inputId = "datasets",
      choices = datanames(data())
    )

    observeEvent(input$datasets, {
      req(input$datasets)

      only_numeric <- sapply(data()[[input$datasets]], is.numeric)

      updateSelectInput(
        inputId = "variables",
        choices = names(data()[[input$datasets]])[only_numeric]
      )

    })

    result <- reactive({
      req(input$datasets)
      # req(input$variables)
      req(input$variables %in% names(data()[[input$datasets]]))
      new_data <- within(
        data(), {
          my_plot <- ggplot(input_dataset, aes(x = input_vars)) +
            geom_histogram(binwidth = input_binwidth, fill = "skyblue", color = "black")
          my_plot
        },
        input_dataset = as.name(input$datasets),
        input_vars = as.name(input$variables),
        input_binwidth = input$binwidth
      )
    })

    output$my_plot <- shiny::renderPlot({
      result()[["my_plot"]]
    })

    teal.widgets::verbatim_popup_srv(
      id = "rcode",
      verbatim_content = reactive(
        teal.data::get_code(result())
      ),
      title = "Example Code"
    )

    card_function <- function(card = teal::TealReportCard$new()) {
      card$append_fs(filter_panel_api$get_filter_state())
      card$append_text(paste("Selected dataset", input$datasets))
      card$append_plot(result()[["my_plot"]])
    }

    teal.reporter::simple_reporter_srv(
      id = "reporter",
      reporter = reporter,
      card_fun = card_function
    )

  })
}

my_custom_module <- function(label = "My custom module") {
  module(
    label = label,
    ui = custom_module_ui,
    server = custom_module_server,
    datanames = "all"
  )
}

data <- within(teal_data(), {
  ADSL <- teal.data::rADSL
  ADAE <- teal.data::rADAE
})

app <- init(
  data = data,
  modules = modules(
    my_custom_module(label = "my module")
  ),
  header = "my teal app"
)

shinyApp(app$ui, app$server)
