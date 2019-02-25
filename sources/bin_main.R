bin_logTable <- reactiveVal()
observeEvent(input$bin_action, {

  tryCatch({
    source('sources/includes/bin_render.R', local = TRUE)
  }, error =
    function(e) {
      # Do something here
    })
  
  NULL
})

output$bin_log <- 
  renderUI(
    div(
      class = 'log-inner',
      pickerInput(inputId = "bin_display",
                  label = "View mode",
                  inline = TRUE,
                  width = '100%',
                  choices = list(
                    'Value' = 'values',
                    'Real index' = 'indexes',
                    'ID (base on Key)' = 'keys'
                  )),
      bin_logTable()
    )
  )