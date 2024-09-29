library(teal)

# data = teal_data(
#   iris = iris,
#   code = "
#     iris <- iris
#   "
# )

data <- cdisc_data()
data <- within(data, {
  ADSL <- teal.data::rADSL
})
datanames(data) <- "ADSL"

data <- verify(data)

app <- init(
  data = data,
  modules = modules(
    example_module(label = "my module")
  ),
  header = "my teal app"
)

shinyApp(app$ui, app$server)
