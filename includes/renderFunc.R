renderLog <- function(chkRes, vars = names(chkRes$problem)) {
  if (is.null(vars)) vars <- deparse(substitute(chkRes))
  problem <- chkRes$problem
  problemValues <- chkRes$problemValues
  problemIndexes <- chkRes$problemIndexes
  message <- chkRes$message[!is_true(names(chkRes$message) == 'notice')]
  hasKey <- length(data.keys())
  if (hasKey) problemKeys <- chkRes$problemKeys
  if (length(vars) == 1) {
    names(problem) <- vars
    names(message) <- vars
    if (problem) {
      names(problemValues) <- vars
      names(problemIndexs) <- vars
    }
  }
  
  out <- list(
    tags$table(
      class = 'chk-logTable',
      tags$thead(
        tags$th('Variable'),
        tags$th('Suspected Indexes'),
        if (hasKey) tags$th('Suspected IDs'),
        tags$th('Suspected Values')
      ),
      lapply(vars,
             function(var){
               if (problem[[var]]) {
                 print(problemIndexes[var])
                 out <- list(var, 
                             toString(problemIndexes[[var]]), 
                             if (hasKey) toString(problemKeys[[var]]), 
                             toString(problemValues[[var]])
                 )} else {
                   out <- list(var, message[[var]])
                 }
               return(do.call(tags$tr, 
                              if (!problem[[var]]) list(tags$td(out[[1]]), tags$td(out[[2]], colspan = 3))
                              else lapply(out, tags$td)))
             })
    )
  )
  return(out)
}