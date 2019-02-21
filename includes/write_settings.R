write_settings <- function(varNames, input, filePath){
  settings <- list(
    varNames = varNames,
    msd_enabled = input$msd_enabled,
    did_enabled = input$did_enabled,
    outl_enabled = input$outl_enabled,
    lnr_enabled = input$lnr_enabled,
    bin_enabled = input$lnr_enabled,
    wsp_enabled = input$wsp_enabled,
    spl_enabled = input$spl_enabled,
    msd_subset = input$msd_subset,
    msd_fix = input$msd_fix,
    did_v = input$did_v,
    did_repNo = input$did_repNo,
    outl_subset = input$outl_subset,
    outl_model = input$outl_model,
    outl_fnLower = input$outl_fnLower,
    outl_fnUpper = input$outl_fnUpper,
    outl_skewA = input$outl_skewA,
    outl_skewB = input$outl_skewB,
    outl_params = input$outl_params,
    outl_acceptNegative = input$outl_acceptNegative,
    outl_acceptZero = input$outl_acceptZero,
    lnr_subset = input$lnr_subset,
    lnr_upLimit = input$lnr_upLimit,
    lnr_threshold = input$lnr_threshold,
    lnr_dateAsFactor = input$lnr_dateAsFactor,
    bin_subset = input$bin_subset,
    bin_upLimit = input$bin_upLimit,
    wsp_subset = input$wsp_subset,
    wsp_whitespaces = input$wsp_whitespaces,
    wsp_doubleWSP = input$wsp_doubleWSP,
    spl_subset = input$spl_subset,
    spl_upLimit = input$spl_upLimit,
    dictCheck_plot = input$dictCheck_plot
  )
  
  if (!requireNamespace('jsonlite')) stop('jsonlite is needed!')
  out <- jsonlite::write_json(settings, path = filePath, auto_unbox = TRUE, pretty = TRUE)
  return(out)
}