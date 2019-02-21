read_settings <- function(filePath){
  if (!requireNamespace('jsonlite')) stop('jsonlite is neeeded!')
  
  tryCatch({
    settings <- jsonlite::read_json(filePath, simplifyVector = TRUE)
  }, error = function(e){
    settings <- NULL
  })
  
  if (length(settings)) return(settings)
}