text_parse <- function(data){
  data <- lapply(data,
                 function(col){
                   col.res <- iconv(col, to  = 'UTF-8//TRANSLITE')
                   as.is <- if (any(length(grepl("\\s", col.res, perl = TRUE)) >= 2)) TRUE else FALSE
                   col.res <- type.convert(col.res, as.is = as.is)
                 })
  data <- as_tibble(data)
}
