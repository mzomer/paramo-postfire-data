library(tidyverse)
library(here)
library(broom)
library(DHARMa)
library(lme4)
library(lmerTest)

dir.create(here("data", "processed"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("outputs"), recursive = TRUE, showWarnings = FALSE)
