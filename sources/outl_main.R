observeEvent(input$outl_action, {
  
  if (length(input$outl_subset))
    tryCatch({
      source('sources/includes/outl_render.R', local = TRUE)
    }, error = 
      function(e) {
        # Do something here
      })
})