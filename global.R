# Load needed libraries and source files ######
library(shiny)
library(shinyWidgets)
library(tidyverse)
library(readxl)
library(dataMaid)
library(hunspell)
library(DT)
library(rhandsontable)
library(stringr)
library(jsonlite)
library(tools)

rootPath <- getwd()
shinyOn <- TRUE
dev <- TRUE

includedFiles <- list.files('includes')
for (file in includedFiles)
  source(paste('includes',file, sep = '//'))

# source(file = 'includes//cleanifyGroup.R', local = TRUE)
# source(file = 'includes//text_parse.R', local = TRUE)
# source(file = 'includes//write_meta.R', local = TRUE)
# source(file = 'includes//intelliChoice.R', local = TRUE)
# source(file = 'includes//outlierFn.R', local = TRUE)
# source(file = 'includes//set_always_on.R', local = TRUE)
# source(file = 'includes//write_settings.R', local = TRUE)
# source(file = 'includes//read_settings.R', local = TRUE)
# source(file = 'includes//renderFunc.R', local = TRUE)

metaFiles <- list.files('meta')
for (file in metaFiles) {
  file.name <- sub('.json','', file)
  assign(file.name, jsonlite::read_json(paste('meta', file, sep = '//'), simplifyVector = TRUE))
}
 

# nav_title <- jsonlite::read_json('meta/navTitle.json', simplifyVector = TRUE)
# instr <- jsonlite::read_json('meta/instr.json', simplifyVector = TRUE)
# random_text <- jsonlite::read_json('meta/randText.json', simplifyVector = TRUE)

# Loaded dev code ######
if (exists('dev')) if (dev) {
  devIncludedFiles <- list.files('dev-includes')
  for (file in devIncludedFiles)
    source(paste('dev-includes',file,sep = '//'))
  # source(file = 'dev-includes//set_instr.R')
  # source(file = 'dev-includes//set_randText.R')
}
