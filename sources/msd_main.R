msd_logTable <- reactiveVal()
observeEvent(input$msd_action, {
  tryCatch({
    source('sources/includes/msd_render.R', local = TRUE)
  }, error =
    function(e) {
      print(e)
  })
  
  NULL
})

output$msd_log <- 
  renderUI(
    div(
      class = 'log-inner',
      pickerInput(inputId = "msd_display",
                  label = "View mode",
                  inline = TRUE,
                  width = '100%',
                  choices = list(
                    'Value' = 'values',
                    'Real index' = 'indexes',
                    'ID (base on Key)' = 'keys'
                  )),
      msd_logTable()
    )
  )



