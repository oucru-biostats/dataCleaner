# shinyUI(fluidPage(
#   theme = 'styles.css',
#   tags$script(src = 'jquery.readyselector.js'),
#   tags$link(rel="stylesheet", href="awesomplete.css"),
#   tags$script(src = "awesomplete.js"),
#   tags$script(src = "scripts.js"),
#   tags$head(tags$meta(name="viewport", content="width=device-width, initial-scale=1.0")),
#   
#   #navBar
#   navbarPage(title = tags$div(class = 'header-div',
#                               HTML('&#129302;'),' Data-Clean Robot',
#                               em('Early Alpha')
#   ),
#   windowTitle = 'Data-Clean Robot'
#   )
# ))


shinyUI(navbarPage(
  title = tags$div(class = 'header-div',
                   HTML('&#129302;'),' Data-Clean Robot',
                   em('Beta')),
  tabPanel('General Check',
           div(id = 'foreground',
               div (id = 'text',
                    HTML('<div class="lds-roller"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>'),
                    span(random_text[[runif(1, min = 1, max = length(random_text)) %>% round]])
               )
           ),
           div(
             fluidRow(
               column(6,
                      fileInput(inputId = 'datasource',
                                label = 'Open your data file', 
                                accept = c(
                                  "text/csv",
                                  "text/comma-separated-values,text/plain",
                                  ".csv",
                                  ".xls",
                                  ".xlsx")
                      ),
                      id = 'data-input',
                      class = 'fullWidth'
               ),
               column(6,
                      uiOutput('sheetPicker'),
                      id = 'sheet-input',
                      class = 'hidden'
               ),
               id = 'data-input-holder',
               class = 'center' 
             )
           ),
           
           div(
             id = 'sheetPicker-holder'
           )
  ),
  tabPanel('Dictionary Check'
           ),
  tabPanel('About'
           ),
  id = 'grand-top-bar',
  position = 'fixed-top',
  collapsible = TRUE,
  windowTitle = 'Data-Clean Robot',
  header = list(tags$meta(name="viewport", content="width=device-width, initial-scale=1.0"),
                tags$link(rel='stylesheet', href="styles.css"),
                tags$link(rel='stylesheet', href='jquery-mobile/jquery.mobile.custom.min.css'),
                tags$script(src = 'etc/css-global-variables.min.js'),
                tags$script(src = 'jquery-mobile/jquery.mobile.custom.min.js'),
                tags$script(src = 'scripts.js'))
))