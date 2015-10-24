## ---- echo = FALSE-------------------------------------------------------
  load("CartoDB_cred.RData")

## ---- results = 'hide'---------------------------------------------------
library(CartoDB)
cartodb(CBDID, APIKey)

## ---- results = 'hide'---------------------------------------------------
library(spdep)
library(maptools)
nc.sids <- readShapePoly(system.file("etc/shapes/sids.shp", package="spdep")[1],
       ID="FIPSNO", proj4string=CRS("+proj=longlat +ellps=clrk66"))

## ---- eval = FALSE-------------------------------------------------------
#  r2cartodb(nc.sids, "nc.sids")

## ------------------------------------------------------------------------
trans.data <- cartodb.df("SELECT * FROM nc_sids WHERE name = 'Transylvania'")
trans.data

## ------------------------------------------------------------------------
names(trans.data)

## ------------------------------------------------------------------------
sql.qr <- "SELECT sum(bir74) as x from nc_sids"
tot.births74 <- cartodb.df(sql.qr)
tot.births74$x

## ------------------------------------------------------------------------
sql.qr <- "SELECT sum(sid74) as x from nc_sids"
tot.sids74 <- cartodb.df(sql.qr)
tot.sids74$x

## ------------------------------------------------------------------------
rate74 <- tot.sids74$x / tot.births74$x
rate74

## ------------------------------------------------------------------------
sql.qr <- "SELECT sum(sid74)/sum(bir74) as x from nc_sids"
rate74.sql <- cartodb.df(sql.qr)
rate74.sql$x

## ------------------------------------------------------------------------
1000 * rate74.sql$x

## ------------------------------------------------------------------------
sql.qr <- "SELECT sid74/bir74 from nc_sids"
county.rates <- cartodb.df(sql.qr)
summary(unlist(county.rates))

## ------------------------------------------------------------------------
sql.qr <- "SELECT nc_sids.bir74 * rate.rate74 FROM nc_sids, (SELECT sum(sid74)/sum(bir74) as rate74 FROM nc_sids) rate"
exp.cases74 <- cartodb.df(sql.qr)
summary(unlist(exp.cases74))

