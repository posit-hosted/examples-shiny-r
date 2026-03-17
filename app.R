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
    b$Page$navigate("https://example.com")
    b$Page$loadEventFired()
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

chromote::set_chrome_args(c(
  "--no-sandbox",
  "--disable-dev-shm-usage",
  "--disable-gpu",
  c("--force-color-profile", "srgb"),
  "--disable-extensions",
  "--mute-audio"
))
options(chromote.headless = "old")

shinyApp(ui = ui, server = server)
