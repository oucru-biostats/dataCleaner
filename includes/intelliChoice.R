intelliChoice <- function(data, type) {
  
  col.list <- colnames(data)
  
  
  detectWord <- function(data){
    set <- NULL
    for (c in col.list) {
      dt <- data[[c]]
      dt <- dt[!is.na(dt) & !is.null(dt)]
      pattern <- '^[A-Za-z\\s(),.!?\\\\/&\\_\\-]+$'
      if (all(grepl(pattern, dt, perl = TRUE)))
        set <- c(set, c)
    }
    return(set)
  }
  
  detectNumeric <- function(data){
    set <- NULL
    for (c in col.list) {
      dt <- data[[c]]
      dt <- dt[!is.na(dt) & !is.null(dt)]
      pattern <- '^[+-]*[0-9.]+$'
      if (all(grepl(pattern, dt, perl = TRUE)))
        set <- c(set, c)
    }
    return(set)
  }
  
  detectDateTime <- function(data){
    set <- NULL
    for (c in col.list) {
      dt <- data[[c]]
      dt <- dt[!is.na(dt) & !is.null(dt)]
      pattern <- '((\\s|^)((([12]\\d{3}|\\d{2})[-\\/.](0?[1-9]|[12]\\d|3[01])[-\\/.](0?[1-9]|[12]\\d|3[01]))|((0?[1-9]|[12]\\d|3[01])[-\\/.](0?[1-9]|[12]\\d|3[01])[-\\/.]([12]\\d{3}|\\d{2}))))|((\\s|^)([0-2]?\\d)\\s?[:]\\s?\\d{1,2})'
      if (all(grepl(pattern, dt, perl = TRUE)))
        set <- c(set, c)
    }
    return(set)
  }
  
  detectPotentialBinary <- function(data){
    set <- NULL
    for (c in col.list) {
      dt <- data[[c]]
      dt <- dt[!is.na(dt) & !is.null(dt)] %>% as.factor()
      
      if (length(levels(dt)) < 5)
        set <- c(set, c)
    }
    return(set)
  }
  
  # includePattern <- switch(type,
  #                          'word' = '[A-Za-z\\s(),.!?\\\\/&\\_\\-]+',
  #                          'numeric' = '^[0-9]+$',
  #                          'dateTime' = ''
  #                          )
  # excludePattern <- switch(type,
  #                          'word' = '',
  #                          'numeric' = '',
  #                          'dateTime' = '((\\s|^)((([12]\\d{3}|\\d{2})[-\\/.](0?[1-9]|[12]\\d|3[01])[-\\/.](0?[1-9]|[12]\\d|3[01]))|((0?[1-9]|[12]\\d|3[01])[-\\/.](0?[1-9]|[12]\\d|3[01])[-\\/.]([12]\\d{3}|\\d{2}))))|((\\s|^)([0-2]?\\d)\\s?[:]\\s?\\d{1,2})')
  #                         )

  detectionList <- switch(type,
                          "word" = detectWord(data),
                          "numeric" = detectNumeric(data),
                          "dateTime" = detectDateTime(data),
                          "binary" = detectPotentialBinary(data)
  )
  
  
  
  return(detectionList)

}