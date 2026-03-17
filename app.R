library(shiny)
library(chromote)

ui <- fluidPage(
  titlePanel("Screenshot of example.com"),
  actionButton("capture", "Capture Screenshot"),
  imageOutput("screenshot")
)

server <- function(input, output, session) {
  screenshot_path <- reactiveVal(NULL)

  observeEvent(input$capture, {
    b <- ChromoteSession$new()
    p <- b$Page$loadEventFired(wait_ = FALSE)
    b$Page$navigate("https://example.com")
    b$wait_for(p)
    tmp <- tempfile(fileext = ".png")
    b$screenshot(tmp, selector = "body")
    b$close()
    screenshot_path(tmp)
  })

  output$screenshot <- renderImage({
    req(screenshot_path())
    list(src = screenshot_path(), contentType = "image/png", width = "100%")
  }, deleteFile = FALSE)
}


shinyApp(ui = ui, server = server)
