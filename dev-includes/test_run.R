test_run <- function(testFunc, requiredVars, ...) {
  args <- list(...)
  args <- rlist::list.prepend(args, testFunc = testFunc, requiredVars = requiredVars)
  print(args)
  
  out <- future(do.call(test_apply, args, envir = global_env()))
  return(out)
}