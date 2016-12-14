---
title: "Developing Data Products - Week 2 Assignment"
author: "César Gamboa"
date: "December 13, 2016"
output: html_document
---
```{r, echo=FALSE, results='hide'}
setwd("E:/Académico/Data Science Specialization/09-Developing Data Products/Week 2/Week 2 Assignment")
```

```{r, message=FALSE, warning=FALSE, results='hide'}
library(data.table)
library(dplyr)
library(leaflet)
library(htmltools)
```

```{r, message=FALSE}
df<-tbl_df(fread("df.csv"))
df
df%>%
  leaflet()%>%
  addTiles()%>%
  addCircles(lng=df$longitud,
             lat=df$latitud,
             popup=~htmlEscape(df$Centro), 
             radius=df$n*10)
```

