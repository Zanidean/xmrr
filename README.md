Overview
---------

xmrr is a package designed to generate and visualize control charts from time-series data.

- `xmr()`: [Generates XMR data.](https://sramhc.shinyapps.io/xmrbuilder/)

- `xmr_chart()`: Takes the output from **xmr()** and makes an XMR chart.


Installation
------------

For the development version:

``` R
devtools::install_github("zanidean/xmrr")
```

For the official CRAN version:

``` R
install.packages("xmrr")
```

Usage
------------

XMRS have two key asssumptions:

* Measurements of value happen over sequential time.

* Each unit of time has only one measurement of value.

This snippet shows the basic syntax:

```R
Year <- seq(2001, 2009, 1)
Measure <-  runif(length(Year))

df <- data.frame(Year, Measure)

xmr(df, "Measure", recalc = T)

```

