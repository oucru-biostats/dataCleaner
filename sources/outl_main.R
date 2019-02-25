outl_logTable <- reactiveVal()
observeEvent(input$outl_action, {
  
  if (length(input$outl_subset))
    tryCatch({
      source('sources/includes/outl_render.R', local = TRUE)
    }, error = 
      function(e) {
        # Do something here
      })
})

output$outl_log <-
  renderUI(
    div(
      class = 'log-inner',
      pickerInput(inputId = "outl_display",
                  label = "View mode",
                  inline = TRUE,
                  width = '100%',
                  choices = list(
                    'Value' = 'values',
                    'Real index' = 'indexes',
                    'ID (base on Key)' = 'keys'
                  )),
      outl_logTable()
    )
  )