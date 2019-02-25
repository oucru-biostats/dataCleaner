chkRes$lnr_result <- loners_scan(data = dataset$data.loaded, keyVar = input$keyVariable,
                                 subset = input$lnr_subset, threshold = input$lnr_threshold,
                                 upLimit = input$lnr_upLimit, accept.dateTime = input$lnr_dateAsFactor)

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
      uiOutput('lnr_logTable')
    )
  )

output$lnr_logTable <- renderUI(renderLog(chkRes$lnr_result, display = input$lnr_display, keys = data.keys()))

session$sendCustomMessage('logOn', 'lnr')