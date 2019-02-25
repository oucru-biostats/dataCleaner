observeEvent(input$wsp_action, {
  
  tryCatch({
    source('sources/includes/wsp_render.R', local = TRUE)
  }, error = 
    function(e) {
      
      print(e)
      # Do something here
    })
})