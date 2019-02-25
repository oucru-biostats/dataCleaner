observeEvent(input$msd_action, {
  tryCatch({
    source('sources/includes/msd_render.R', local = TRUE)
  }, error = 
    function(e) {
      # Do something here
    })
})