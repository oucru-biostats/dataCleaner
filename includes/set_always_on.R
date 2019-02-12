set_always_on <- function(objs, output = output){
  for (obj in objs)
    outputOptions(output, obj, suspendWhenHidden = FALSE)
}