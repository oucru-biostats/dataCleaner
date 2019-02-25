library(promises)
library(future)
plan(multiprocess)

shinyServer(function(input, output, session) {
  # observeEvent(dataset$shownData, {
  #   session$sendCustomMessage('haveData', TRUE)
  # })
  
  # Adding data ######
  
  ## Get ext and file path #####
  fileInfo <- reactiveValues()
  ext <- reactiveVal()
  
  observeEvent(input$datasource, {
    fileInfo$ext <- tools::file_ext(input$datasource$datapath)
    name.split <- strsplit(input$datasource$name, '\\.')[[1]]
    fileInfo$name <- do.call(paste0, as.list(name.split[-length(name.split)]))
    fileInfo$path <- gsub(input$datasource$name, '', input$datasource$datapath)
  })
  
  ## Generate sheet picker dialog #####
  sheetsList <- reactiveVal()
  
  observeEvent(input$datasource,{
    if (isTRUE(fileInfo$ext %in% c('xls', 'xlsx'))) {
      session$sendCustomMessage("excel", TRUE)
      sheetsList(excel_sheets(input$datasource$datapath))
    } else session$sendCustomMessage("excel", FALSE)
  }) 
  
  sheet <- reactive({
    if (is.null(input$sheetPicker)) sheetsList()[1] else input$sheetPicker
  })
  
  observeEvent(input$sheetPicker,{
    if (isTRUE(input$sheetPicker != dataset$sheet)) session$sendCustomMessage('changeSheet',TRUE)
  })
  
  output$sheetPicker <- renderUI(
    if (isTRUE(fileInfo$ext %in% c('xls', 'xlsx')))
      pickerInput(inputId = "sheetPicker",
                  label = "Sheets list",
                  choices = sheetsList(),
                  selected = sheetsList()[1])
  )
  
  ## Load dataset from file and sheet
  read_excel_shiny <- function(datapath){
    req(input$sheetPicker)
    if (!is.null(input$sheetPicker) & isTRUE(input$sheetPicker %in% sheetsList()))
      read_excel(datapath, sheet = sheet())
  }
  
  read.data <- function(datapath, fileInfo){
    out <- switch(fileInfo$ext,
                  "xls" = read_excel_shiny(datapath),
                  "xlsx" = read_excel_shiny(datapath),
                  "csv" = read.csv(datapath, stringsAsFactors = FALSE),
                  default = print("Def")
    )
    if (is.data.frame(out)) {
      if (nrow(out) > 0 && ncol(out) >0) {
        if (fileInfo$ext %in% c('xls', 'xlsx')) dataset$sheet <- input$sheetPicker
        return(out)
      }
      else {
        sendSweetAlert(session, title = 'Blank Data',
                       text = 'This is a blank data. You will be reset to the old one', type = 'error')
        if (fileInfo$ext %in% c('xls', 'xlsx'))
          updatePickerInput(session,
                            inputId = 'sheetPicker',
                            selected = dataset$sheet)
        session$sendCustomMessage('haveData', TRUE)
        return(NULL)
      }
    } else {
      sendSweetAlert(session, title = 'Not a data frame',
                     text = 'This is not a data frame. You will be reset to the old one', type = 'error')
      session$sendCustomMessage('haveData', TRUE)
      return(NULL)
    }
  }
  
  dataset <- reactiveValues()
  
  observeEvent(c(input$datasource, input$sheetPicker), {
    data.loaded <- read.data(req((input$datasource)$datapath), fileInfo) 
    if (!is.null(data.loaded)) dataset$data.loaded <- data.loaded %>% text_parse
  })
  
  observeEvent(c(dataset$data.loaded, dataset$data.result), {
    dataset$shownData <- if (!isTRUE(isTRUE(input$showOriginal)) & is.data.frame(dataset$data.result)) 
      dataset$data.result
    else
      dataset$data.loaded %>%
    cbind("<span style='color:grey; font-style:italic; font-weight:light'>(index)</span>" = 1:nrow(req(dataset$data.loaded)), .)
  })
  
  # observe({
  #   dataset$data.result <- if (is.data.frame(res())) res.dt()
  # })
  
  data.cols <- reactiveVal()
  cols.state <- reactiveVal()
  data.keys <- reactiveVal()
  
  observeEvent(dataset$data.loaded, {
    req(dataset$data.loaded)
    data.cols(colnames(dataset$data.loaded))
    cols.state(data.cols())
    data.keys(intelliKey(dataset$data.loaded, showAll = TRUE))
  })
  
  output$dataset <- renderDT(
    expr = dataset$shownData,
    filter = list(position = 'top', caseInsensitive = FALSE),
    escape = FALSE, 
    server = TRUE,
    selection = 'single',
    rownames = FALSE,
    options = list(
      id = 'dataset',
      search = list(caseInsensitive = FALSE),
      pageLength = 5,
      scrollY = 'auto',
      scrollX = TRUE,
      autoWidth = TRUE,
      scroller = TRUE,
      drawCallback = JS("function() {_DT_callback(this);}"),
      initComplete = JS("function() {_DT_initComplete();}")
      )
    )
  
  proxy <- dataTableProxy('dataset')
  
  ## Options menu for data #####
  
  output$dataOptions <- renderUI(
    if (!is.data.frame(dataset$data.loaded))
      NULL
    else 
    dropdownButton(
      inputId = 'datasetMenu',
      circle = FALSE,
      label = '',
      status = "default",
      icon = icon("ellipsis-v"),
      right = TRUE,
      size = 'sm',
      width = 'auto',
      tags$ul(id = 'dataset-menu',
              tags$li(
                div(
                  id = 'showOriginal-holder',
                  switchInput(inputId = "showOriginal",
                              label = "",
                              onLabel = "Original Dataset",
                              offLabel = "Result Dataset",
                              value = TRUE,
                              onStatus = 'success',
                              offStatus = 'danger',
                              disabled = TRUE,
                              handleWidth = 'auto',
                              labelWidth = '50%',
                              width = '100%',
                              size ='small'
                  ),
                  
                  div(style='display:none', "...")
                )
              ),
              tags$li(
                div(
                  downloadLink(outputId = 'saveSettings',
                                 label = 'Save Settings',
                                 width = '100%'
                                 ),
                  class = 'menu-button'
                )
              ),
              tags$li(
                div(
                  fileInput(inputId = 'loadSettings',
                            label = 'Load Settings',
                            width = '100%'
                            ),
                  p('Load Settings',
                    id = 'load-settings-btn'),
                  class = 'menu-button'
                )
              ),
              tags$li(class = if (!length(data.keys())) 'disabled',
                      div('Set key variable', id = 'set-key-var'),
                      tags$ul(
                        tags$li(
                          id = 'key-var-chooser-holder',
                          div(
                            if (length(data.keys()))
                              awesomeRadio(inputId = 'keyVariable',
                                           label = NULL,
                                           status = 'primary',
                                           choices = data.keys(),
                                           selected = data.keys()[1],
                                           width = 'auto'
                              ) else p('(Empty)'),
                            id = 'key-var-chooser',
                            class = 'awesome-checkbox-chooser'
                          )
                        )
                      )
              ),
              
              tags$li(div('Show/Hide Columns', id = 'show-hide-columns'),
                      tags$ul(
                        tags$li(
                          id = 'columns-chooser-holder',
                          div(
                            awesomeCheckboxGroup(inputId = 'shownColumns',
                                                 label = NULL,
                                                 status = 'columns-list',
                                                 choices = data.cols(),
                                                 selected = data.cols(),
                                                 width = 'auto'
                            ),
                            id = 'columns-chooser',
                            class = 'awesome-checkbox-chooser'
                          )
                        )
                      )
              ),
              
              tags$li(id='output-holder',downloadButton("output", "Download"))
      ),
      tags$script(src = 'etc/data-options.js')
    )
  )
  
  observeEvent(c(input$shownColumns, 1),{
    shownColumns <- input$shownColumns
    
    col.changeList <- xor(data.cols() %in% cols.state(), data.cols() %in% shownColumns) %>% which
    session$sendCustomMessage('toggleCol', list(col.changeList))
    cols.state(shownColumns)
  })
  
  output$actionCheckBar <- renderUI(
    div (
      actionButton(inputId = 'all_action', label = 'Do All Check', width = '110px'),
      div (
        actionButton(inputId = 'msd_action', label = 'Missing Check', width = '120px'),
        actionButton(inputId = 'did_action', label = 'Redundancy Check', width = '150px'),
        actionButton(inputId = 'outl_action', label = 'Outliers Check', width = '120px'),
        actionButton(inputId = 'lnr_action', label = 'Loners Check', width = '120px'),
        actionButton(inputId = 'bin_action', label = 'Binary Check', width = '120px'),
        actionButton(inputId = 'wsp_action', label = 'Whitespaces Check', width = '150px'),
        actionButton(inputId = 'spl_action', label = 'Spelling Check', width = '130px'),
        class = 'each-action-holder'
      ),
      class = 'actionBar'
    )
  )
  
  output$actionDictBar <- renderUI(
    div(
      div(
        actionButton(inputId = 'dictCheck_action', label = 'Do this Check', width = '120px'),
        downloadButton(outputId = 'dictCreate_action', label = 'Save Dictionary', width = '200px'),
        class = 'each-action-holder'
      ),
      class = 'actionBar'
    )
  )
  
  ## Get methods for data #####
  output$methodsNav <- renderUI(
    if (is.null(dataset$data.loaded))
      NULL
    else
      div(
        tags$script(src = "etc/methods-nav.js"),
        navlistPanel(
          tabPanel("Missing Data", uiOutput('msd_all')),
          tabPanel("Redundant Data", uiOutput('did_all')),
          tabPanel("Numerical Outliers", uiOutput('outl_all')),
          tabPanel("Categorical Loners", uiOutput('lnr_all')),
          tabPanel("Binary", uiOutput('bin_all')),
          tabPanel("Whitespaces", uiOutput('wsp_all')),
          tabPanel("Spellings Issues", uiOutput('spl_all')),
          widths = c(3, 9),
          well = FALSE
        )
      )
  )
  
  output$methodsToggle <- renderUI(
    if (is.null(dataset$data.loaded))
      NULL
    else
      div(
        div(
          materialSwitch(inputId = "msd_enabled", 
                         status = "success",
                         right = TRUE),
          id = 'msd-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "did_enabled", 
                         status = "success",
                         right = TRUE),
          id = 'did-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "outl_enabled", 
                         status = "success",
                         right = TRUE),
          id = 'outl-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "lnr_enabled", 
                         status = "success",
                         right = TRUE),
          id = 'lnr-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "bin_enabled", 
                         status = "success",
                         right = TRUE),
          id = 'bin-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "wsp_enabled", 
                         status = "success",
                         right = TRUE),
          id = 'wsp-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "spl_enabled", 
                         status = "success",
                         right = TRUE),
          id = 'spl-holder',
          class = 'opt-holder'
        ),
        id = 'methods-toggle-holder'
      )
  )
  
  output$dictNav <- renderUI(
    div(
      tags$script(src = "etc/dict-nav.js"),
      navlistPanel(
        tabPanel('Check with pre-defined Dict',
                 div(id = 'dict-check',
                     uiOutput('dictCheck'))),
        tabPanel('Create new Dictionary',
                 div(id = 'dict-create',
                     uiOutput('dictCreate'))),
        well = FALSE,
        widths = c(3, 9)
      )
    )
  )
  
  ## Methods details #####
  
  ### Missing data ####
  output$msd_all <- renderUI(
    fluidRow(
      column(8,
             uiOutput('msd_options'),
             class = 'arg-holder'),
      column(4,
             uiOutput('msd_instr'),
             class = 'instr-holder'),
      column(7,
             uiOutput('msd_log'),
             class = 'log-holder',
             id = 'msd-log-holder')
    )
  )
  
  
  output$msd_options <- 
    renderUI(
      div(awesomeCheckboxGroup(inputId = "msd_subset", 
                               label = "Select variables to check", 
                               choices = data.cols(), 
                               selected = data.cols()[data.cols() %in% names(which(intelliCompatible(isolate(dataset$data.loaded), "missing")))], 
                               inline = TRUE, status = "info"),
          materialSwitch(inputId = "msd_fix", 
          label = "Auto replace suspect with NA", 
          status = "danger",
          value = FALSE,
          right = TRUE),
      id = 'msd-args-holder'
      )
    )
  
  observe({
    updateMaterialSwitch(session = session,
                         inputId = 'msd_enabled',
                         value = if (length(input$msd_subset)) TRUE else FALSE)
  })
  
  output$msd_instr <- renderUI(HTML(instr$msd_instruction))
  output$msd_log <- renderUI(div('lorem ipsum'))
  
  ### Numerical Outliers ####
  output$outl_all <- renderUI(
    fluidRow(
      column(8,
             uiOutput('outl_options'),
             class = 'arg-holder'),
      column(4,
             uiOutput('outl_instr'),
             class = 'instr-holder'),
      column(7,
             uiOutput('outl_log'),
             class = 'log-holder',
             id = 'outl-log-holder')
    )
  )
  
  output$outl_options <- 
    renderUI(
      div(
        awesomeCheckboxGroup(
          inputId = "outl_subset", 
          label = "Select variables to check", 
          choices = data.cols(), 
          selected = data.cols()[data.cols() %in% names(which(intelliCompatible(isolate(dataset$data.loaded), "outliers")))], 
          inline = TRUE, status = "info"
        ),
        pickerInput(
          inputId = 'outl_model',
          label = 'Outlier model (default: Adjusted)',
          choices = c('Adjusted model' = 'adjusted', 'Tukey Boxplot model' = 'boxplot', 'Custom model' = 'custom'),
          selected = 'adjusted',
          width = '100%'
        ),
        fluidRow(
          column(6, 
                 textInput(inputId = 'outl_fnLower',
                           label = 'Lower Bound Function',
                           width = '100%',
                           value = getOutlValue(type = 'upper', model = isolate(input$outl_model)))
          ),
          column(6, 
                 textInput(inputId = 'outl_fnUpper',
                           label = 'Upper Bound Function',
                           width = '100%',
                           value = getOutlValue(type = 'lower', model = isolate(input$outl_model)))
                 )
        ),
        conditionalPanel(
          condition = 'input.outl_model == "adjusted"',
          fluidRow(
            column(6,
                   numericInput(inputId = 'outl_skewA',
                             label = 'Skew Param a',
                             value = -4,
                             width = '100%')),
            column(6,
                   numericInput(inputId = 'outl_skewB',
                             label = 'Skew Param b',
                             value = 3,
                             width = '100%'))
          )
        ),
        conditionalPanel(
          condition = 'input.outl_model == "custom"',
          textInput(inputId = 'outl_params',
                    label = 'Additional params definition',
                    placeholder = 'var1 = value1, var2 = value2',
                    width = '100%')
        ),
        fluidRow(
          column(6,
                 materialSwitch(inputId = "outl_acceptNegative", 
                                label = "Accept negative value", 
                                status = "info",
                                value = FALSE,
                                right = TRUE)
                 ),
          column(6,
                 materialSwitch(inputId = "outl_acceptZero", 
                                label = "Accept zero value", 
                                status = "info",
                                value = FALSE,
                                right = TRUE)
          )
        ),
        id = 'outl-args-holder'
      )
    )
  
  observeEvent(input$outl_model, {
    
    session$sendCustomMessage('outl_model', input$outl_model)
    
    updateTextInput(
      session = session,
      inputId = 'outl_fnUpper',
      value = getOutlValue(type = 'upper', model = input$outl_model))
    
    updateTextInput(
      session = session,
      inputId = 'outl_fnLower',
      value = getOutlValue(type = 'lower', model = input$outl_model))
  })
  
  observe({
    updateMaterialSwitch(session = session,
                         inputId = 'outl_enabled',
                         value = if (length(input$outl_subset)) TRUE else FALSE)
  })
  
  output$outl_instr <- renderUI(HTML(instr$outl_instruction))
  output$outl_log <- renderUI(div('lorem ipsum'))
  
  ### Categorical Loners ####
  
  output$lnr_all <- renderUI(
    fluidRow(
      column(8,
             uiOutput('lnr_options'),
             class = 'arg-holder'),
      column(4,
             uiOutput('lnr_instr'),
             class = 'instr-holder'),
      column(7,
             uiOutput('lnr_log'),
             class = 'log-holder',
             id = 'lnr-log-holder')
    )
  )
  
  output$lnr_options <- 
    renderUI(
      div(awesomeCheckboxGroup(inputId = "lnr_subset", 
                               label = "Select variables to check", 
                               choices = data.cols(), 
                               selected = data.cols()[data.cols() %in% names(which(intelliCompatible(isolate(dataset$data.loaded), "loners", accept.dateTime = isolate(input$lnr_dateAsFactor))))], 
                               inline = TRUE, status = "info"),
          fluidRow(
            column(4,
                   knobInput(
                     inputId = "lnr_upLimit",
                     label = "Upper Limit",
                     value = 70,
                     thickness = 0.1,
                     min = 20,
                     max = 100,
                     step = 5,
                     displayPrevious = TRUE, 
                     width = 100,
                     height = 100,
                     lineCap = "round",
                     fgColor = "#428BCA",
                     inputColor = "#428BCA"
                   )),
            column(8,
                   numericInput(
                     inputId = 'lnr_threshold',
                     label = 'Max number of observation for loners',
                     value = 5,
                     min = 1,
                     step = 1,
                     width = '100%'
                   ),
                   materialSwitch(
                     inputId = "lnr_dateAsFactor", 
                     label = "Check date-time variables", 
                     status = "info",
                     inline = TRUE,
                     value = FALSE,
                     right = TRUE)
                  )
            
          ),
          id = 'lnr-args-holder'
      )
    )
  
  observeEvent(input$lnr_dateAsFactor, {
    updateAwesomeCheckboxGroup(session = session,
                               inputId = 'lnr_subset',
                               selected = data.cols()[data.cols() %in% names(which(intelliCompatible(isolate(dataset$data.loaded), "loners", accept.dateTime = isolate(input$lnr_dateAsFactor))))])
  })
  
  observeEvent(input$lnr_threshold, {
    if (!is.numeric(input$lnr_threshold))
      updateNumericInput(session = session,
                         inputId = 'lnr_threshold',
                         value = round(input$lnr_threshold, digits = 0))
  })
  
  observeEvent(input$lnr_subset, {
    req(dataset$data.loaded)
    subset <- input$lnr_subset
    if (!is.null(subset)) if (any(intelliType(dataset$data.loaded[subset]) == 'dateTime'))
      updateMaterialSwitch(session = session,
                           inputId = 'lnr_dateAsFactor',
                           value = TRUE)
  })
  
  observe({
      updateMaterialSwitch(session = session,
                           inputId = 'lnr_enabled',
                           value = if (length(input$lnr_subset)) TRUE else FALSE)
  })
  
  output$lnr_instr <- renderUI(HTML(instr$lnr_instruction))
  output$lnr_log <- renderUI(div('lorem ipsum'))
  
  ### Binary ####
  
  output$bin_all <- renderUI(
    fluidRow(
      column(8,
             uiOutput('bin_options'),
             class = 'arg-holder'),
      column(4,
             uiOutput('bin_instr'),
             class = 'instr-holder'),
      column(7,
             uiOutput('bin_log'),
             class = 'log-holder',
             id = 'bin-log-holder')
    )
  )
  
  output$bin_options <- 
    renderUI(
      div(awesomeCheckboxGroup(inputId = "bin_subset", 
                               label = "Select variables to check", 
                               choices = data.cols(), 
                               selected = data.cols()[data.cols() %in% names(which(intelliCompatible(isolate(dataset$data.loaded), "binary")))], 
                               inline = TRUE, status = "info"),
          fluidRow(
            column(4),
            column(4,
                   knobInput(
                     inputId = "bin_upLimit",
                     label = "Upper Limit",
                     value = 70,
                     thickness = 0.1,
                     min = 20,
                     max = 100,
                     step = 5,
                     displayPrevious = TRUE, 
                     width = 100,
                     height = 100,
                     lineCap = "round",
                     fgColor = "#428BCA",
                     inputColor = "#428BCA"
                   )),
            column(4)
          ),
          id = 'bin-args-holder'
      )
    )
  
  observe({
    updateMaterialSwitch(session = session,
                         inputId = 'bin_enabled',
                         value = if (length(input$bin_subset)) TRUE else FALSE)
  })
  
  output$bin_instr <- renderUI(HTML(instr$bin_instruction))
  output$bin_log <- renderUI(div('lorem ipsum'))
  
  ## Whitespaces check #####
  
  output$wsp_all <- renderUI(
    fluidRow(
      column(8,
             uiOutput('wsp_options'),
             class = 'arg-holder'),
      column(4,
             uiOutput('wsp_instr'),
             class = 'instr-holder'),
      column(7,
             uiOutput('wsp_log'),
             class = 'log-holder',
             id = 'wsp-log-holder')
    )
  )
  
  output$wsp_options <- 
    renderUI(
      div(awesomeCheckboxGroup(inputId = "wsp_subset", 
                               label = "Select variables to check", 
                               choices = data.cols(), 
                               selected = data.cols(), 
                               inline = TRUE, status = "info"),
          materialSwitch(
            inputId = "wsp_whitespaces", 
            label = "Leading & trailing spaces", 
            status = "info",
            inline = TRUE,
            value = TRUE,
            right = TRUE),
          materialSwitch(
            inputId = "wsp_doubleWSP", 
            label = "Double whitespaces", 
            status = "info",
            inline = TRUE,
            value = TRUE,
            right = TRUE),
          id = 'wsp-args-holder'
      )
    )
  
  observe({
    updateMaterialSwitch(session = session,
                         inputId = 'wsp_enabled',
                         value = if (length(input$wsp_subset)) TRUE else FALSE)
  })
  
  output$wsp_instr <- renderUI(HTML(instr$wsp_instruction))
  output$wsp_log <- renderUI(div('lorem ipsum'))
  
  ## Spelling check #####
  
  output$spl_all <- renderUI(
    fluidRow(
      column(8,
             uiOutput('spl_options'),
             class = 'arg-holder'),
      column(4,
             uiOutput('spl_instr'),
             class = 'instr-holder'),
      column(7,
             uiOutput('spl_log'),
             class = 'log-holder',
             id = 'spl-log-holder')
    )
  )
  
  output$spl_options <- 
    renderUI(
      div(awesomeCheckboxGroup(inputId = "spl_subset", 
                               label = "Select variables to check", 
                               choices = data.cols(), 
                               selected = data.cols()[data.cols() %in% names(which(intelliCompatible(isolate(dataset$data.loaded), 'spelling')))], 
                               inline = TRUE, status = "info"),
          fluidRow(
            column(4),
            column(4,
                   knobInput(
                     inputId = "spl_upLimit",
                     label = "Upper Limit",
                     value = 70,
                     thickness = 0.1,
                     min = 20,
                     max = 100,
                     step = 5,
                     displayPrevious = TRUE, 
                     width = 100,
                     height = 100,
                     lineCap = "round",
                     fgColor = "#428BCA",
                     inputColor = "#428BCA"
                   )),
            column(4)
          ),
          id = 'spl-args-holder'
      )
    )
  
  observe({
    updateMaterialSwitch(session = session,
                         inputId = 'spl_enabled',
                         value = if (length(input$spl_subset)) TRUE else FALSE)
  })
  
  output$spl_instr <- renderUI(HTML(instr$spl_instruction))
  output$spl_log <- renderUI(div('lorem ipsum'))
  
  ### Redundant observation ####
  
  output$did_all <- renderUI(
    fluidRow(
      column(8,
             uiOutput('did_options'),
             class = 'arg-holder'),
      column(4,
             uiOutput('did_instr'),
             class = 'instr-holder'),
      column(7,
             uiOutput('did_log'),
             class = 'log-holder',
             id = 'did-log-holder')
    )
  )
  
  output$did_options <- 
    renderUI(
      div(
        fluidRow(
          column(4,
                 knobInput(
                   inputId = "did_upLimit",
                   label = "Upper Limit",
                   value = 50,
                   thickness = 0.1,
                   min = 20,
                   max = 100,
                   step = 5,
                   displayPrevious = TRUE, 
                   width = 100,
                   height = 100,
                   lineCap = "round",
                   fgColor = "#428BCA",
                   inputColor = "#428BCA"
                 )),
          column(8,
                 pickerInput(inputId = 'did_v',
                             label = 'Base variable',
                             choices = data.cols(),
                             options = pickerOptions(dropupAuto = FALSE, 
                                                     liveSearch = TRUE, liveSearchNormalize = TRUE,
                                                     width = '100%',
                                                     size = 6),
                             width = '100%'),
                 numericInput(inputId = 'did_repNo',
                              label = 'Number of observation per ID',
                              value = 1,
                              min = 1,
                              step = 1,
                              width = '100%')
                 ),
                 
        id = 'spl-args-holder'
        ))
    )
  
  observe({
    updateMaterialSwitch(session = session,
                         inputId = 'did_enabled',
                         value = if (length(input$did_v)) TRUE else FALSE)
    if (!is.integer(input$did_repNo))
      if (!is.null(input$did_repNo)) 
        updateNumericInput(session = session,
                           inputId = 'did_repNo',
                           value = round(x = input$did_repNo, digits = 0))
    if (isTRUE(input$did_repNo < 1))
      updateNumericInput(session = session,
                         inputId = 'did_repNo',
                         value = 1)
  })
  
  observeEvent(input$keyVariable,{
    if (!is.null(input$keyVariable))
      updatePickerInput(session = session, 
                        inputId = 'did_v',
                        choices = data.cols()[data.cols() != input$keyVariable])
    
  })
  
  output$did_instr <- renderUI(HTML(instr$spl_instruction))
  output$did_log <- renderUI(div('lorem ipsum'))
  
  ## Dictionary #####
  
  ### Dictionary Check ####
  output$dictCheck <- renderUI(
    fluidRow(
      column(8,
             uiOutput('dictCheck_options'),
             class = 'arg-holder'),
      column(4,
             uiOutput('dictCheck_instr'),
             class = 'instr-holder'),
      column(7,
             uiOutput('dictCheck_log'),
             class = 'log-holder',
             id = 'dictCheck-log-holder')
    )
  )
    
  output$dictCheck_options <-   
    renderUI(
      div(
        tags$script(src = 'etc/dict-check.js'),
        fluidRow(
          column(7,
                 fileInput(inputId = 'info_path',
                           label = 'Get dictionary file', 
                           accept = c("text/csv", 
                                      "text/comma-separated-values,text/plain",
                                      ".csv", ".xls", ".xlsx"),
                           width = '100%')
                 ),
          column(5,
                 switchInput(inputId = "dictCheck_plot", value = FALSE, label = 'Plotting' , size = 'normal', width = '100%'))
        ),
        id = 'dict-check-args-holder'
      )
    )
  
  output$dictCheck_instr <- renderUI(HTML(instr$spl_instruction))
  output$dictCheck_log <- renderUI(div('lorem ipsum'))
  
  
  ### Dictionary Create ####
  output$dictCreate <- renderUI(
      div(uiOutput('dictCreate_options'),
          class = 'arg-holder'
          )
  )
  
  output$dictCreate_options <- 
    renderUI(
      div(
        tags$script(src = 'etc/dict-create.js'),
        rHandsontableOutput("defTable"),
        id = 'dict-create-args-holder'
      )
    )
  
  observeEvent(dataset$data.loaded,{
    if (is.data.frame(dataset$data.loaded)){
      
      data <- dataset$data.loaded
      dataset$intelliType <- intelliType(data, threshold = 0.8)
      type <- sapply(seq_along(dataset$intelliType),
                     function(i) {
                       iType <- dataset$intelliType[[i]]
                       cType <- sapply(data.cols(), function(col) class(data[[col]]), USE.NAMES = FALSE)
                       out <- 
                         if (is.null(iType)) ''
                         else if ('key' %in% iType) {
                          if ('numeric' %in% iType) 'numeric' else 'character'
                         }
                         else switch(iType[length(iType)],
                                     'lang' = 
                                       if (!any(grepl(',', data[[i]])) &
                                           sum(grepl('\\s',  data[[i]], perl = TRUE)) < 2 &
                                           length(unique(na.blank.omit(data[[i]]))) < 20) 'factor' else 'character',
                                     'other' = 
                                       if (!any(grepl(',', data[[i]])) &
                                           sum(grepl('\\s',  data[[i]], perl = TRUE)) < 2 &
                                           length(unique(na.blank.omit(data[[i]]))) < 20) 'factor' else 'character',
                                     'numeric' = 
                                       if (length(unique(na.omit(data[[i]]))) <= 2 & 
                                           all(na.omit(data[[i]]) == floor(na.omit(data[[i]]))) &
                                           all(na.omit(data[[i]]) <= 10))
                                         'factor' 
                                       else 'numeric',
                                     'dateTime' = 'dateTime',
                                     'binary' = 'factor')
                       
                     }, USE.NAMES = FALSE)
      
      values <- sapply(seq_along(type),
                                function(i) {
                                  type = type[i]
                                  
                                  if (type == 'numeric'){
                                    min = min(na.omit(data[[i]]))
                                    max = max(na.omit(data[[i]]))
                                    if (isTRUE(min != max)) paste0('[', min, ', ', max, ']')
                                    else min
                                  } 
                                  else {
                                    if (type == 'factor'){
                                      val = sort(unique(as.character(na.blank.omit(as.character(data[[i]])))))
                                      if (length(val) >  1) paste0('{', toString(val), '}')
                                      else val
                                    } 
                                    else ''
                                  }
                                }, USE.NAMES = FALSE)
      missing <- rep(NA, length(type))
      dataset$defTable <- 
        cbind(varName = data.cols(), label = "", type = type, 
              unit = "", values = values, rules = "", missing = missing)
      row.names(dataset$defTable) <- NULL
    }
  })
  
  output$defTable <- renderRHandsontable(
    rhandsontable(dataset$defTable, stretchH = "all", search = TRUE) %>%
      hot_cols(fixedColumnsLeft = 1, colWidths = c('','','','', '100px', '', '')) %>%
      hot_rows(rowHeights = rep('24px', 7)) %>%
      hot_col(col = 'varName', readOnly = TRUE) %>%
      hot_col(col = 'type', type = 'dropdown', source = c('numeric', 'character', 'dateTime', 'factor'), allowInvalid = FALSE) %>%
      hot_col(col = 'values', placeholder = '{a, b, c} or [min, max]') %>%
      hot_col(col = 'rules', placeholder = '=') %>%
      hot_col(col = 'missing', placeholder = 'NA')
  )
  
  
  ## Save and load settings ----
  
  output$saveSettings <- 
    downloadHandler(
      filename = function() {
        paste0(fileInfo$name, '-', Sys.Date(), '-', 'settings.json')
      },
      content = function(filePath) write_settings(data.cols(), input, filePath)
    )
  
  settings <- reactiveVal()
  observeEvent(input$loadSettings, {
     settings(read_settings(input$loadSettings$datapath))
    
    #check whether data is matched
    if (!identical(data.cols(), settings()$varNames)) 
      sendSweetAlert(session = session,
                     title = 'Data Mismatch!',
                     text = 'Variable lists in loaded dataset and in loaded preset are unmatched.',
                     type = 'error',
                     closeOnClickOutside = TRUE)
    else {
      
      settingList <- names(settings())
      
      #Get some quick list
      enabledList <- grep('_enabled', settingList, value = TRUE)
      subsetList <- grep('_subset', settingList, value = TRUE)
      upLimitList <- grep('_upLimit', settingList, value = TRUE)
      
      materialSwitchList <- c('msd_fix', 
                              'outl_acceptNegative', 'outl_acceptZero', 
                              'lnr_dateAsFactor', 
                              'wsp_whitespaces', 'wsp_doubleWSP',
                              'dictCheck_plot',
                              enabledList)
      textInputList <- c('outl_fnLower', 'outl_fnUpper', 'outl_params')
      numericInputList <- c('did_repNo', 'outl_skewA', 'outl_skewB', 'lnr_threshold')
      pickerInputList <- c('outl_model', 'did_v')
      
      for (method in materialSwitchList)
        updateMaterialSwitch(session,
                             inputId = method,
                             value = settings()[[method]])
      
      for (method in subsetList)
        updateAwesomeCheckboxGroup(session, 
                                   inputId = method,
                                   selected = settings()[[method]])
      for (method in upLimitList)
        updateKnobInput(session,
                        inputId = method,
                        value = settings()[[method]])
      
      for (method in textInputList)
        updateTextInput(session,
                        inputId = method,
                        value = settings()[[method]])
      for (method in numericInputList)
        updateNumericInput(session,
                           inputId = method,
                           value = settings()[[method]])
      for (method in pickerInputList)
        updatePickerInput(session,
                          inputId = method,
                          selected = settings()[[method]])
    }
    
  })
    
  
  ## Apply the check ----
  
  chkRes <- reactiveValues()
  
  testSources <- sapply(testList, function(test) test$source)
  
  for (source in testSources) source(source, local = TRUE)
  
  observeEvent(input$all_action, {
    session$sendCustomMessage('all_check', TRUE)
    tryCatch({
      session$sendCustomMessage('all_check', TRUE)
  }, error = 
    function(e) {
      # Do something here
      print(e)
    })
  })
  
  output$dictCreate_action <- 
    downloadHandler(
      filename = function() {
        paste0(fileInfo$name, '-DataDictionary.csv')
      },
      content = function(filePath) write.csv(hot_to_r(input$defTable), filePath)
    )
  
  #EOF 
  
  set_always_on(c('dataOptions', 'actionCheckBar','actionDictBar',
                  'methodsNav', 'dictNav', 'methodsToggle',
                  'msd_all', 'msd_options', 'msd_log', 'msd_instr', 
                  'outl_all', 'outl_options', 'outl_log', 'outl_instr',
                  'lnr_all', 'lnr_options', 'lnr_log', 'lnr_instr',
                  'bin_all', 'bin_options', 'bin_log', 'bin_instr',
                  'wsp_all', 'wsp_options', 'wsp_log', 'wsp_instr',
                  'spl_all', 'spl_options', 'spl_log', 'spl_instr',
                  'did_all', 'did_options', 'did_log', 'did_instr',
                  'dictCheck', 'dictCheck_options','dictCheck_log', 'dictCheck_instr'
  ),
  output = output)
})
