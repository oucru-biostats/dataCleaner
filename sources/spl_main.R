spl_logTable <- reactiveVal()
observeEvent(input$spl_action, {
  
  tryCatch({
    source('sources/includes/spl_render.R', local = TRUE)
  }, error = 
    function(e) {
      print(e)
      # Do something here
    })
})

output$spl_log <-
  renderUI(
    div(
      class = 'log-inner',
      pickerInput(inputId = "spl_display",
                  label = "View mode",
                  inline = TRUE,
                  width = '100%',
                  choices = list(
                    'Value' = 'values',
                    'Real index' = 'indexes',
                    'ID (base on Key)' = 'keys'
                  )),
      spl_logTable()
    )
  )