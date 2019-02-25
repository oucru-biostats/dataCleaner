chkRes$msd_result <- 
  test_apply(c(input$msd_enabled, length(input$msd_subset)),
             missing_scan,
             data = dataset$data.loaded, keyVar = input$keyVariable,
             subset = input$msd_subset, fix = input$msd_fix)

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
      uiOutput('msd_logTable')
    )
  )

output$msd_logTable <- renderUI(renderLog(chkRes$msd_result, display = input$msd_display, keys = data.keys()))
session$sendCustomMessage('logOn', 'msd')