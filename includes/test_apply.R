test_apply <- function(requiredVars, testFunc, ...){
  eligible <- all(requiredVars)
  if (eligible){
    out <- do.call(testFunc, list(...))
    return(out)
  } else stop(NULL)
}
