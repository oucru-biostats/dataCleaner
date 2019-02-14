shinyUI(navbarPage(
  title = tags$div(class = 'header-div',
                   HTML('&#129302;'),' Data-Clean Robot',
                   em('Beta')),
  tabPanel('General Check',
           fluidRow(
             column(1,
                    uiOutput('methodsToggle'),
                    class = 'width0'),
             column(11,
                    uiOutput('methodsNav'))
             ),
           class = 'grand-tab-panel'
           ),
  tabPanel('Dictionary Check',
           uiOutput('dictNav'),
           class = 'grand-tab-panel'
           ),
  tabPanel('About'
           ),
  id = 'grand-top-bar',
  position = 'fixed-top',
  collapsible = FALSE,
  windowTitle = 'Data-Clean Robot',
  header = list(tags$meta(name="viewport", content="width=device-width, initial-scale=1.0"),
                tags$link(rel='stylesheet', href="styles.css"),
                tags$link(rel='stylesheet', href='jquery-mobile/jquery.mobile.custom.structure.min.css'),
                tags$link(rel='stylesheet', href="jquery-ui/jquery-ui.css"),
                tags$link(rel='stylesheet', href='simplebar/simplebar.css'),
                tags$link(rel='stylesheet', href="tippy/themes/light-border.css"),
                tags$script(src = 'etc/css-global-variables.min.js'),
                tags$script(src = 'jquery-mobile/jquery.mobile.custom.min.js'),
                tags$script(src = 'jquery-ui/jquery-ui.js'),
                tags$script(src = 'simplebar/simplebar.js'),
                tags$script(src="tippy/tippy.all.min.js"),
                tags$script(src = 'scripts.js'),
                div(id = 'foreground',
                    div (id = 'text',
                         HTML('<div class="lds-roller"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>'),
                         span(random_text[[runif(1, min = 1, max = length(random_text)) %>% round]])
                    )
                ),
                div(id = 'overlay',
                    HTML('<div class="lds-roller hidden"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>')
                ),
                div(
                  fluidRow(
                    column(6,
                           fileInput(inputId = 'datasource',
                                     label = 'Open your data file', 
                                     accept = c("text/csv", 
                                                "text/comma-separated-values,text/plain",
                                                ".csv", ".xls", ".xlsx")),
                           id = 'data-input',
                           class = 'fullWidth'),
                    column(6,
                           uiOutput('sheetPicker'),
                           id = 'sheet-input',
                           class = 'pseudo-hidden'),
                    id = 'data-input-holder',
                    class = 'center' )),
                div(
                  id = 'sheetPicker-holder'
                ),
                uiOutput('sheetResult'),
                uiOutput('dataOptions'),
                DTOutput('dataset')
  )
))