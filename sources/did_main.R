observeEvent(input$did_action, {
  
  tryCatch({
    i <- get_input_vars(input, 'did')
    v <- dataset$data.loaded[[i$did_v]]
    
    
    future(
      test_apply(i$did_enabled,
                 redundancy_check,
                 v = v, repNo = i$did_repNo,
                 upLimit = i$did_upLimit
      )
    ) %>% 
      then(onFulfilled = function(res) chkRes$did_result <- res,
           onRejected = function() session$sendCustomMessage('logOn', 'did')
      )
  }, error = 
    function(e) {
      print(e)
      # Do something here
    })
  
  NULL
})

observeEvent(c(input$did_display, input$did_action, chkRes$did_result),{
  if(!is.null(chkRes$did_result)){
    output$did_logTable <- renderUI(renderLog(chkRes = chkRes$did_result, vars = input$did_v,
                                              display = input$did_display, keys = data.keys()))
    session$sendCustomMessage('logOn', 'did')
  }
})

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

