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
  
  observe({
    req(dataset$data.loaded)
    data.cols(colnames(dataset$data.loaded))
    cols.state(data.cols())
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
          tabPanel("Missing Data", uiOutput('msd_options'), uiOutput('msd_instr'), uiOutput('msd_log')),
          tabPanel("Numerical Outliers", uiOutput('outl_options'), uiOutput('outl_instr'), uiOutput('outl_log')),
          tabPanel("Categorical Loners", uiOutput('lnr_options'), uiOutput('lnr_instr'), uiOutput('lnr_log')),
          tabPanel("Binary", uiOutput('bin_options'), uiOutput('bin_instr'), uiOutput('bin_log')),
          tabPanel("Whitespaces", uiOutput('wsp_options'), uiOutput('wsp_instr'), uiOutput('wsp_log')),
          tabPanel("Spellings Issues", uiOutput('spl_options'), uiOutput('spl_instr'), uiOutput('spl_log')),
          tabPanel("Duplicate IDs", uiOutput('did_options'), uiOutput('did_instr'), uiOutput('did_log'))
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
                         # label = "Enabled", 
                         status = "success",
                         value = TRUE,
                         right = TRUE),
          id = 'msd-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "outl_enabled", 
                         # label = "Enabled", 
                         status = "success",
                         value = TRUE,
                         right = TRUE),
          id = 'outl-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "lnr_enabled", 
                         # label = "Enabled", 
                         status = "success",
                         value = TRUE, 
                         right = TRUE),
          id = 'lnr-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "bin_enabled", 
                         # label = "Enabled", 
                         status = "success",
                         value = TRUE,
                         right = TRUE),
          id = 'bin-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "wsp_enabled", 
                         # label = "Enabled", 
                         status = "success",
                         value = TRUE,
                         right = TRUE),
          id = 'wsp-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "spl_enabled", 
                         # label = "Enabled", 
                         status = "success",
                         value = TRUE,
                         right = TRUE),
          id = 'spl-holder',
          class = 'opt-holder'
        ),
        div(
          materialSwitch(inputId = "mkrp_enabled", 
                         # label = "Enabled", 
                         status = "success",
                         value = FALSE,
                         right = TRUE),
          id = 'mkrp-holder',
          class = 'opt-holder'
        ),
        id = 'methods-toggle-holder'
      )
  )
  
  #EOF  
  

  
})
