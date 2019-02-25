chkRes$bin_result <- binary_scan(data = dataset$data.loaded, keyVar = input$keyVariable,
                                 subset = input$bin_subset, upLimit = input$bin_upLimit)

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
      uiOutput('bin_logTable')
    )
  )

output$bin_logTable <- renderUI(renderLog(chkRes$bin_result, display = input$bin_display, keys = data.keys()))

session$sendCustomMessage('logOn', 'bin')