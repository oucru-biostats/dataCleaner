wsp_logTable <- reactiveVal()
observeEvent(input$wsp_action, {
  
  tryCatch({
    source('sources/includes/wsp_render.R', local = TRUE)
  }, error = 
    function(e) {
      
      print(e)
      # Do something here
    })
})

output$wsp_log <-
  renderUI(
    div(
      class = 'log-inner',
      pickerInput(inputId = "wsp_display",
                  label = "View mode",
                  inline = TRUE,
                  width = '100%',
                  choices = list(
                    'Value' = 'values',
                    'Real index' = 'indexes',
                    'ID (base on Key)' = 'keys'
                  )),
      wsp_logTable()
    )
  )