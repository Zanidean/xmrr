## ---- message=FALSE, echo = F--------------------------------------------
library(xmrr)
library(tidyverse)
set.seed(1)
Measure <- round(runif(12, min = 0.50, max = 0.66)*100, 0)
Measure <- c(Measure, round(runif(6, min = 0.70, max = .85)*100, 0))
Time <- c(2000:2017) 
example_data <- data.frame(Time, Measure)
knitr::kable(example_data, format = "markdown", align = 'c')

## ---- message=FALSE, eval = F--------------------------------------------
#  xmr_data <- xmr(df = example_data, measure = "Measure")

## ---- message=FALSE, eval = F--------------------------------------------
#  xmr_data <- xmr(df = example_data, measure = "Measure", recalc = T)

## ---- echo=F, message=FALSE----------------------------------------------
xmr_data <- xmr(example_data, "Measure", 
                recalc = T) %>% 
  select(-Order)
knitr::kable(xmr_data, format = "markdown", align = 'c')

## ---- message = FALSE----------------------------------------------------
xmr_data <- xmr(example_data,  "Measure", 
                recalc = T,
                interval = 5,
                shortrun = c(3,4),
                longrun = c(5,8))

## ---- message = FALSE, eval = F------------------------------------------
#  xmr_data <- xmr(df = example_data,
#                  measure = "Measure",
#                  recalc = T,
#                  #change the rule like so:,
#                  interval = 4,
#                  shortrun = c(2,3))

