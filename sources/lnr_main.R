observeEvent(input$lnr_action, {
  tryCatch({
    source('sources/includes/lnr_render.R', local = TRUE)
  }, error = 
    function(e) {
      # Do something here
    })
})