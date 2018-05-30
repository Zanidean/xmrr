Overview
---------

xmrr is a package designed to generate and visualize control charts from time-series data.

- `xmr()`: [Generates XMR data.](https://sramhc.shinyapps.io/xmrbuilder/)

- `xmr_chart()`: Takes the output from **xmr()** and makes an XMR chart.


Installation
------------

For the development version:

``` R
install.packages("xmrr")
devtools::install_github("zanidean/xmrr")
```

For the official CRAN version:

``` R
install.packages("xmrr")
```

Typical Use
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


This package is part of a many I use in my procedures. [Please check the Analysis Home for more packages and uses.](file:///Q:/StrategicResearch/Rules%20and%20Procedures%20Folder/Checklists%20and%20procedures/Procedure%20Manual/Data%20Analysis/Home.html)