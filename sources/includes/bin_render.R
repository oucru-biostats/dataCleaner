i <- get_input_vars(input, 'bin')
data <- dataset$data.loaded

chkRes$bin_result <- 
  future(
    test_apply(i$bin_enabled,
               binary_scan,
               data = data, keyVar = i$keyVariable,
               subset = i$bin_subset, upLimit = i$bin_upLimit
    )
  )

chkRes$bin_result %...>%
  renderLog(chkRes = ., display = i$bin_display, keys = data.keys()) %...>% 
  (function (res) {
    bin_logTable(res)
    session$sendCustomMessage('logOn', 'bin')
  })



