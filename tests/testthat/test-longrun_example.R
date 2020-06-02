context("Specific Long-Run")

library(testthat)

library(dplyr)
library(tidyr)

tibble::tribble(
  ~Year, ~Value,
  "2004-2005",                    47L,
  "2005-2006",                    40L,
  "2006-2007",                    68L,
  "2007-2008",                    60L,
  "2008-2009",                    44L,
  "2009-2010",                    43L,
  "2010-2011",                    38L,
  "2011-2012",                    28L,
  "2012-2013",                    47L,
  "2013-2014",                    35L,
  "2014-2015",                    28L,
  "2015-2016",                    28L,
  "2016-2017",                    27L
  ) %>% 
  xmr(prefer_longrun = T) %>% 
  xmr_chart
