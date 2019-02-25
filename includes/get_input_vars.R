get_input_vars <- function(input, alias){
  if (missing(alias)) {
    input.names <- names(input)
    out <- sapply(input.names, function(i) input[[i]], simplify = FALSE, USE.NAMES = TRUE)
  } else {
    input.names <- names(input)
    input.which <- grep(paste0('^', alias), input.names, perl = TRUE, value = TRUE)
    out <- sapply(input.which, function(i) input[[i]], simplify = FALSE, USE.NAMES = TRUE) 
  }
  
  return(out)
}