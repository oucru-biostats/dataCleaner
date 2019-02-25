observeEvent(input$bin_action, {
  
  tryCatch({
    source('sources/includes/bin_render.R', local = TRUE)
  }, error = 
    function(e) {
      # Do something here
    })
})