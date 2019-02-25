observeEvent(input$did_action, {
  
  tryCatch({
    source('sources/includes/did_render.R', local = TRUE)
  }, error = 
    function(e) {
      print(e)
      # Do something here
    })
})