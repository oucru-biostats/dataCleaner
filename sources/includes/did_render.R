chkRes$did_result <-
  test_apply(input$did_enabled,
             redundancy_check,
             v = dataset$data.loaded[[input$did_v]], repNo = input$did_repNo,
             upLimit = input$did_upLimit)

output$did_log <- 
  renderUI(
    div(
      class = 'log-inner',
      pickerInput(inputId = "did_display",
                  label = "View mode",
                  inline = TRUE,
                  width = '100%',
                  choices = list(
                    'Value' = 'values',
                    'Real index' = 'indexes'
                  )),
      uiOutput('did_logTable')
    )
  )
output$did_logTable <- renderUI(renderLog(chkRes$did_result, vars = input$did_v, display = input$did_display, keys = data.keys()))
session$sendCustomMessage('logOn', 'did')