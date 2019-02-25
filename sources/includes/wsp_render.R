chkRes$wsp_result <- cleanify(data = dataset$data.loaded, keyVar = input$keyVariable,
                              checks = c(if (input$wsp_whitespaces) 'whitespaces', if (input$wsp_doubleWSP) 'doubleWSP'), 
                              options = opt(global(subset(!!input$wsp_subset))))

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
      uiOutput('wsp_logTable')
    )
  )

output$wsp_logTable <- renderUI(renderLog(chkRes$wsp_result, display = input$wsp_display, keys = data.keys()))

session$sendCustomMessage('logOn', 'wsp')