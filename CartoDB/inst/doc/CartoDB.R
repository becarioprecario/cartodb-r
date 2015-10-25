## ---- echo = FALSE-------------------------------------------------------
  load("CartoDB_cred.RData")

## ---- results = 'hide'---------------------------------------------------
library(CartoDB)
cartodb(CBDID, APIKey)

## ---- echo = FALSE-------------------------------------------------------
#Delete nc_sids table
cartodb.df("DROP TABLE nc_sids")

## ---- results = 'hide'---------------------------------------------------
library(spdep)
library(maptools)
nc.sids <- readShapePoly(system.file("etc/shapes/sids.shp", package="spdep")[1],
       ID="FIPSNO", proj4string=CRS("+proj=longlat +ellps=clrk66"))

## ---- eval = TRUE--------------------------------------------------------
library(rgdal)
r2cartodb(nc.sids, "nc.sids")

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

## ------------------------------------------------------------------------
sql.qr <- "SELECT nc_sids.cartodb_id, nc_sids.bir74 * rate.rate74 as exp74 FROM nc_sids, (SELECT sum(sid74)/sum(bir74) as rate74 FROM nc_sids) rate"
data.sql <- data.frame(cartodb.df(sql.qr))
data.sql[1:5, ]

## ---- eval = TRUE--------------------------------------------------------
sql.qr <- "ALTER TABLE nc_sids ADD COLUMN exp74 numeric"
res <- cartodb.df(sql.qr)

## ------------------------------------------------------------------------
sql.qr <- "UPDATE nc_sids SET exp74 = tab.exp74 FROM (SELECT nc_sids.cartodb_id, nc_sids.bir74 * rate.rate74 as exp74 FROM nc_sids, (SELECT sum(sid74)/sum(bir74) as rate74 FROM nc_sids) rate) tab WHERE nc_sids.cartodb_id = tab.cartodb_id"

res <- cartodb.df(sql.qr)

## ------------------------------------------------------------------------
cartodb.df("ALTER TABLE nc_sids ADD COLUMN smr74 numeric")

sql.qr <- "UPDATE nc_sids SET smr74 = tab.smr74 FROM (SELECT cartodb_id, bir74/exp74 as smr74 FROM nc_sids) tab WHERE nc_sids.cartodb_id = tab.cartodb_id"
cartodb.df(sql.qr)

