#' Data checking: check a dataset based on pre-defined information
#'
#' @export
datacheck_addin <- function() {

  ## ui
  ui <- miniPage(
    gadgetTitleBar("Check data"),
    miniContentPanel(
      textInput("data_path", "Data file:"),
      actionButton("data_browse", "Data browse"),
      textInput("info_path", "Info file:"),
      actionButton("info_browse", "Info browse"),

      textInput("id", "ID variable"),
      checkboxInput('plot', 'Plot', FALSE),
      actionButton("check", "Check data"),
      textOutput("out", container = rCodeContainer)
    )
  )

  ## server
  server <- function(input, output, session) {

    observe({
      if (input$data_browse == 0) return()
      updateTextInput(session, "data_path",  value = file.choose2())
    })

    observe({
      if (input$info_browse == 0) return()
      updateTextInput(session, "info_path",  value = file.choose2())
    })

    reactive_text <- reactive({
      if (input$data_path == "") return(errorMessage("data", "No data available."))
      code1 <- paste("assign('data', read.csv('", gsub("\\\\", "/", input$data_path), "', stringsAsFactors = FALSE))", sep = "")

      if (input$info_path == "") return(errorMessage("data", "No info available."))
      code2 <- paste("assign('info', read.csv('", gsub("\\\\", "/", input$info_path), "', stringsAsFactors = FALSE))", sep = "")

      if (input$id == "") return(errorMessage("id", "ID variable is not specified"))
      code3 <- paste("inspect.data(data = data, info = info, id ='", input$id, "', plot =", input$plot, ", outdir = getwd())", sep = "")

      code <- paste(c(code1, code2, code3), collapse = "\n")
      if (input$check != 0) eval(parse(text = code))
      code
    })

    output$out <- renderText({
      code <- reactive_text()
      if (isErrorMessage(code)) return(NULL)
      code
    })

    # done
    observeEvent(input$done, {
      code <- reactive_text()
      rstudioapi::insertText(text = code)
      invisible(stopApp())
    })

  }

  ## viewer
  viewer <- dialogViewer("Check data", width = 1000, height = 800)

  ## run
  runGadget(ui, server, viewer = viewer)
}
