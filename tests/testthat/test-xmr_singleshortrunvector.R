library(testthat)
library(xmrr)
library(dplyr)
library(tidyr)


context("Shortrun Tests")

int_test <- 30

y2 <- 2000 + int_test

Year <- seq(2001, y2, 1)
Measure <-  runif(length(Year))*100 %>% round(0)

test_that("Shortrun vector works right", {
  df <- data.frame(Year, Measure) %>% 
    xmr(., "Measure", recalc = T, shortrun = c(4,5))
  point <- df$`Upper Natural Process Limit`[15]
  last <- df$`Upper Natural Process Limit`[30]
  max <- max(point - last, na.rm = T)
  expect_lt(max, 0.01)
})

test_that("Single shortrun vector works right", {
  df <- data.frame(Year, Measure) %>% 
    xmr(., "Measure", recalc = T, shortrun = 3, longrun = 15)
  point <- df$`Upper Natural Process Limit`[15]
  last <- df$`Upper Natural Process Limit`[26]
  max <- max(point - last, na.rm = T)
  expect_lt(max, 0.01)
})
