# Load needed libraries and source files ######
library(shiny)
library(shinyWidgets)
library(tidyverse)
library(readxl)
library(dataMaid)
library(hunspell)
library(DT)
library(stringr)
library(jsonlite)
library(tools)


source(file = 'includes//cleanifyGroup.R', local = TRUE)
source(file = 'includes//text_parse.R', local = TRUE)
source(file = 'includes//write_meta.R', local = TRUE)
source(file = 'includes//intelliChoice.R', local = TRUE)

nav_title <- jsonlite::read_json('meta/navTitle.json', simplifyVector = TRUE)
instr <- jsonlite::read_json('meta/instr.json', simplifyVector = TRUE)
random_text <- jsonlite::read_json('meta/randText.json', simplifyVector = TRUE)

# Loaded dev code ######
if (exists('dev')) if (dev) {
  source(file = 'dev-includes//set_instr.R')
  source(file = 'dev-includes//set_randText.R')
}