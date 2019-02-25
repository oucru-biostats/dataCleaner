test.add <- function(fullName, alias, 
                     source = NULL){
  if (!exists('testList')) testList <- jsonlite::read_json(file.choose())
  if (length(fullName) != length(alias)) stop('fullName and alias must be vectors of the same length')
  
  for (i in seq_along(fullName)){
    if (any(is.null(source[i]), is.na(source[i]))) source[i] <- paste0("sources//", alias[i], '_main.R')
    testList[[length(testList) + 1]] <- list(id = length(testList) + 1,
                                          name = fullName[i],
                                          alias = alias[i],
                                          source = source[i])
  }
  names(testList) <- append(names(testList), alias)
  testList <<- testList
}

test.write <- function(testList){
  jsonlite::write_json(testList, 'meta//tests.json', auto_unbox = TRUE)
}
# 
# testList <- list()
# test.add(
#   c('Missing Data', 'Redundant Data', 'Numerical Outliers', 'Categorical Loners', 'Binary', 'Whitespaces','Spelling Issues'),
#   c('msd','did','outl','lnr','bin','wsp','spl')
# )
# testList
