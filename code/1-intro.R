# * Create teal app
# * use teal_data() to build data
# * use cdisc_data() to build data object, use teal.data::rADSL and rADAE
# * Run the app, click the Show R Code
# * Verify the data object

library(teal)

# data <- teal_data(
#   my_iris = iris,
#   my_mtcars = mtcars
# )

data <- cdisc_data(
  adsl = teal.data::rADSL,
  adae = teal.data::rADAE
)

app <- init(
  data = data,
  modules = modules(
    example_module(label = "my module")
  ),
  header = "my teal app"
)

shinyApp(app$ui, app$server)
