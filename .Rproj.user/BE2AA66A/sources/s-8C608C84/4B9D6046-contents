# Load needed libraries and source files ######
library(shiny)
library(shinyWidgets)
library(tidyverse)
library(dataMaid)
library(hunspell)
library(DT)
library(stringr)
library(jsonlite)

source(file = 'includes//cleanifyGroup.R')
source(file = 'includes//text_parse.R')
source(file = 'includes//write_meta.R')
source(file = 'includes//intelliChoice.R')

# Loaded dev code ######
if (exists('dev')) if (dev) {
  source(file = 'dev-includes//set_instr.R')
  source(file = 'dev-includes//set_randText.R')
}