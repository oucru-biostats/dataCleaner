lnr_logTable <- reactiveVal()
observeEvent(input$lnr_action, {
  tryCatch({
    source('sources/includes/lnr_render.R', local = TRUE)
  }, error = 
    function(e) {
      print(e)
      # Do something here
    })
  
  NULL
})

output$lnr_log <- 
  renderUI(
    div(
      class = 'log-inner',
      pickerInput(inputId = "lnr_display",
                  label = "View mode",
                  inline = TRUE,
                  width = '100%',
                  choices = list(
                    'Value' = 'values',
                    'Real index' = 'indexes',
                    'ID (base on Key)' = 'keys'
                  )),
      lnr_logTable()
    )
  )