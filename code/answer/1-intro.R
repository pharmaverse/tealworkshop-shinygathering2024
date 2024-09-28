library(teal)

data = teal_data(
  iris = iris,
  code = "
    iris <- iris
  "
)

# data <- teal_data()
# data <- within(data, {
#   iris <- iris
# })
# datanames(data) <- "iris"
data <- verify(data)

app <- init(
  data = data,
  modules = modules(
    example_module(label = "my module")
  ),
  header = "my teal app"
)

shinyApp(app$ui, app$server)
