observeEvent(input$spl_action, {
  
  tryCatch({
    source('sources/includes/spl_render.R', local = TRUE)
  }, error = 
    function(e) {
      # Do something here
    })
})