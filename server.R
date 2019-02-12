library(promises)
library(future)
plan(multiprocess)

shinyServer(function(input, output, session) {
  observeEvent(input$datasource,{
    session$sendCustomMessage('haveData', TRUE)
  })
  
  # Adding data ######
  
  ## Get ext and file path #####
  fileInfo <- reactiveValues()
  ext <- reactiveVal()
  
  observeEvent(input$datasource, {
    fileInfo$ext <- tools::file_ext(input$datasource$datapath)
    ext(tools::file_ext(input$datasource$datapath))
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
    session$sendCustomMessage('changeSheet',TRUE)
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
  
  read.data <- function(datapath){
    out <- switch(fileInfo$ext,
                  "xls" = read_excel_shiny(datapath),
                  "xlsx" = read_excel_shiny(datapath),
                  "csv" = read.csv(datapath, stringsAsFactors = FALSE),
                  default = print("Def")
    )
    return(out)
  }
  
  dataset <- reactiveValues()
  
  observeEvent(c(input$datasource, input$sheetPicker), {
    dataset$data.loaded <- req(read.data((input$datasource)$datapath)) %>% text_parse
  })
  
  observe({
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
  
  observe({
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
              
              tags$li(div('Set key variable', id = 'set-key-var'),
                      tags$ul(
                        tags$li(
                          id = 'key-var-chooser-holder',
                          div(
                            awesomeRadio(inputId = 'keyVariable',
                                         label = NULL,
                                         status = 'primary',
                                         choices = data.cols(),
                                         selected = NULL,
                                         width = 'auto'
                            ),
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
  
  ## Get methods for data #####
  output$methodsNav <- renderUI(
    if (is.null(dataset$data.loaded))
      NULL
    else
      div(
        tags$script(src = "etc/methods-nav.js"),
        navlistPanel(
          "Methods list",
          tabPanel("Missing Data", uiOutput('msd_all')),
          tabPanel("Duplicate IDs", uiOutput('did_all')),
          tabPanel("Numerical Outliers", uiOutput('outl_all')),
          tabPanel("Categorical Loners", uiOutput('lnr_all')),
          tabPanel("Binary", uiOutput('bin_all')),
          tabPanel("Whitespaces", uiOutput('wsp_all')),
          tabPanel("Spellings Issues", uiOutput('spl_all'))
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
             class = 'log-holder')
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
             class = 'log-holder')
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
                   textInput(inputId = 'outl_skewA',
                             label = 'Skew Param a',
                             value = -4,
                             width = '100%')),
            column(6,
                   textInput(inputId = 'outl_skewB',
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
             class = 'log-holder')
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
                   textInput(
                     inputId = 'lnr_threshold',
                     label = 'Max number of observation for loners',
                     value = 5,
                     placeholder = '(min: 1, default: 5)',
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
  
  observeEvent(input$lnr_subset, {
    req(dataset$data.loaded)
    subset <- isolate(input$lnr_subset)
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
             class = 'log-holder')
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
             class = 'log-holder')
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
             class = 'log-holder')
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
  
  ### Duplicated observation ####
  
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
             class = 'log-holder')
    )
  )
  
  output$did_options <- 
    renderUI(
      if (length(data.keys())) div(
        pickerInput(inputId = 'did_key',
                    label = "Select ONE variable for ID",
                    choices = data.keys()
                    ),
        awesomeCheckboxGroup(inputId = "did_subset", 
                             label = "Select variables to check", 
                             choices = isolate(data.cols()[data.cols() != input$did_key]), 
                             selected = isolate(data.cols()[data.cols() != input$did_key]), 
                             inline = TRUE, status = "info"),
        id = 'spl-args-holder'
      ) else div(p('There is no variables in your data that can play the role as identification key.'))
    )
  
  observe({
    updateMaterialSwitch(session = session,
                         inputId = 'did_enabled',
                         value = if (length(input$did_subset) & !is.null(data.keys())) TRUE else FALSE)
  })
  
  observeEvent(input$did_key, {
    updateAwesomeCheckboxGroup(session = session,
                               inputId = 'did_subset',
                               choices = isolate(data.cols()[data.cols() != input$did_key]),
                               selected = isolate(data.cols()[data.cols() != input$did_key]),
                               inline = TRUE, status = "info")
  })
  
  output$did_instr <- renderUI(HTML(instr$spl_instruction))
  output$did_log <- renderUI(div('lorem ipsum'))
  
  #EOF  
  
  set_always_on(c('dataOptions',
                  'msd_all', 'msd_options', 'msd_log', 'msd_instr', 
                  'outl_all', 'outl_options', 'outl_log', 'outl_instr',
                  'lnr_all', 'lnr_options', 'lnr_log', 'lnr_instr',
                  'bin_all', 'bin_options', 'bin_log', 'bin_instr',
                  'wsp_all', 'wsp_options', 'wsp_log', 'wsp_instr',
                  'spl_all', 'spl_options', 'spl_log', 'spl_instr',
                  'did_all', 'did_options', 'did_log', 'did_instr'
  ),
  output = output)
})
