did_logTable <- reactiveVal()
observeEvent(input$did_action, {
  
  tryCatch({
    source('sources/includes/did_render.R', local = TRUE)
  }, error = 
    function(e) {
      print(e)
      # Do something here
    })
})


output$did_log <- 
  renderUI(
    div(
      class = 'log-inner',
      pickerInput(inputId = "did_display",
                  label = "View mode",
                  inline = TRUE,
                  width = '100%',
                  choices = list(
                    'Value' = 'values',
                    'Real index' = 'indexes'
                  )),
      did_logTable()
    )
  )