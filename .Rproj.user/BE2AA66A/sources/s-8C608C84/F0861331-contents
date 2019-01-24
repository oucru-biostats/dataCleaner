write_meta <- function(build, versionName, versionNo){
  
  if (missing(versionName)) if (exists('meta')) versionName <- meta$versionName
  if (missing(versionNo)) if (exists('meta')) versionNo <- meta$versionNo
  if (missing(build)) if (exists('meta')) build <- meta$build + 1
  
  requireNamespace('jsonlite')
  
  otherPkgs <- lapply(sessionInfo()$otherPkgs, 
                 function(x) list(name = x$Package, version = x$Version))
  
  jsonlite::write_json(list(versionName = versionName, 
                  versionNo = versionNo,
                  build = build,
                  date = Sys.Date(),
                  time = Sys.time(),
                  pkgs = list(basePkgs = sessionInfo()$basePkgs, otherPkgs = otherPkgs)),
             'meta/buildInfo.json')
}

meta <- jsonlite::read_json('meta/buildInfo.json', simplifyVector = TRUE)



