# # chkRes$spl_result <- spelling_scan(data = dataset$data.loaded, keyVar = input$keyVariable,
# #                                    subset = input$spl_subset)
# chkRes$spl_result <- 
#   test_apply(c(input$spl_enabled, length(input$spl_subset)),
#              spelling_scan,
#              data = dataset$data.loaded, keyVar = input$keyVariable,
#              subset = input$spl_subset)
# 
# output$spl_log <- 
#   renderUI(
#     div(
#       class = 'log-inner',
#       pickerInput(inputId = "spl_display",
#                   label = "View mode",
#                   inline = TRUE,
#                   width = '100%',
#                   choices = list(
#                     'Value' = 'values',
#                     'Real index' = 'indexes',
#                     'ID (base on Key)' = 'keys'
#                   )),
#       uiOutput('spl_logTable')
#     )
#   )
# 
# output$spl_logTable <- renderUI(renderLog(chkRes$spl_result, display = input$spl_display, keys = data.keys()))
# session$sendCustomMessage('logOn', 'spl')


i <- get_input_vars(input, 'spl')
keyVar <- input$keyVariable
data <- dataset$data.loaded

chkRes$spl_result <- 
  future(
    test_apply(c(i$spl_enabled, length(i$spl_subset)),
               spelling_scan,
               data = data, keyVar = i$keyVariable,
               subset = i$spl_subset
    )
  ) 

chkRes$spl_result %...>% 
  renderLog(chkRes = .,display = input$spl_display, keys = data.keys()) %...>% 
  (function (res) {
    spl_logTable(res)
    session$sendCustomMessage('logOn', 'spl')
  })


