library(promises)
library(future)
plan(multiprocess)

shinyServer(function(input, output, session) {
  observeEvent(input$datasource,{
    session$sendCustomMessage('haveData', TRUE)
  })
  
})
