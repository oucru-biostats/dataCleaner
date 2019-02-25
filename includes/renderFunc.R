renderLog <- function(chkRes, ...){
  UseMethod('renderLog')
}

renderLog.checkResult.306 <- function(chkRes, vars = names(chkRes$problem), display = c('values', 'keys', 'indexes'), keys = intelliKey(chkRes)){
  if (is.null(vars)){
    vars <- deparse(substitute(chkRes))
  } 
  
  display <- match.arg(display)
  
  problem <- chkRes$problem
  problemValues <- chkRes$problemValues
  problemIndexes <- chkRes$problemIndexes
  message <- chkRes$message[!is_true(names(chkRes$message) == 'notice')]
  hasKey <- length(keys)
  if (hasKey) problemKeys <- chkRes$problemKeys
  
  if (!is.list(problem)){
    problem <- structure(list(problem), names = vars)
    problemValues <- structure(list(problemValues), names = vars)
    problemIndexes <- structure(list(problemIndexes), names = vars)
    message <- structure(list(message), names = vars)
  }
  
  out <- list(
    tags$table(
      class = 'chk-logTable',
      tags$thead(
        tags$th('Variable'),
        tags$th(sprintf('Suspected %s', display))
      ),
      tags$tbody(
        lapply(vars,
               function(var){
                 if (problem[[var]])
                   row <- list(var,
                               switch(display,
                                      'values' = toString(problemValues[[var]]),
                                      'keys' = toString(problemKeys[[var]]), 
                                      'indexes' = toString(problemIndexes[[var]])
                               )
                   )
                 else row <- list(var, message[[var]])
                 
                 return(do.call(tags$tr,
                                lapply(row, tags$td)))
               })
      )
    )
  )
  
  return(out)
}

renderLog.checkResult.306.cleanify <- function(chkRes, vars = names(chkRes), tests = getTestList(chkRes), display = c('values', 'keys', 'indexes'), keys = intelliKey(chkRes)){
  if (is.null(vars)) vars <- names(chkRes)
  if (is.null(tests)) tests <- getTestList(chkRes)
  display <- match.arg(display)
  
  hasKey <- length(keys)
  
  out <- list(
    tags$table(
      class = 'chk-logTable',
      tags$thead(
        tags$th('Variable'),
        lapply(tests, tags$th)
      ),
      tags$tbody(
        lapply(vars,
               function(var){
                 chkRes.var <- chkRes$var
                 
                 row <- 
                   append(var,
                        lapply(tests,
                               function(test){
                                 res <- chkRes.var$test
                                 if (!is.null(res)){
                                   testName <- res$testName
                                   problem <- res$problem
                                   problemValues <- res$problemValues
                                   problemIndexes <- res$problemIndexes
                                   if (hasKey) problemKeys <- res$problemKeys
                                   
                                   res.show <- switch(display,
                                                      'values' = toString(problemValues),
                                                      'indexes' = toString(problemIndexes),
                                                      'keys' = toString(problemKeys))
                                 } else res.show <- '-'
                               })
                   )
                 
                 return(do.call(tags$tr,
                                lapply(row, tags$td)))
               })
      )
    )
  )
  
  return(out)
}
