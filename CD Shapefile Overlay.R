#requires Rtools
#requires JAGS


#install.packages("bbsBayes") 
library(bbsBayes)
library(tidyverse)
library(raster)
#install.packages("sf")
library(sf)
#install.packages("rgeos")
library(rgeos)
library(landscapemetrics)
library(landscapetools)
library(dplyr)
library(rgdal)
library(ggplot2)
#install.packages("lwgeom")
library(lwgeom)

#unzip("maps/All Routes 2019.kmz")
BBSroutes <- st_read("maps/doc.kml")
BBSroutes$Description  <- NULL
BBSroutes$prov <- as.integer(stringr::str_sub(BBSroutes$Name,1,2))
BBSroutes$rt <- as.integer(stringr::str_sub(BBSroutes$Name,4,6))
BBSroutes$Route_Name <- as.character(stringr::str_sub(BBSroutes$Name,8))
BBSroutes$rt.uni <- paste(BBSroutes$prov,BBSroutes$rt,sep = "-") 

plot(BBSroutes)

st_crs(BBSroutes)
BBSlaea <- st_transform(BBSroutes,
                        crs = "+proj=laea +x_0=0 +y_0=0 +lon_0=-90 +lat_0=50")
st_crs(BBSlaea)
BBSlaea <- st_buffer(BBSlaea, 5000)
plot(BBSlaea)

CD <- st_read(dsn = "maps", layer = "2016CD_ag")


CD_laea = st_transform(CD,
                            crs = "+proj=laea +x_0=0 +y_0=0 +lon_0=-90 +lat_0=50")


overlay <- st_intersection(BBSlaea,CD_laea)
overlay$Remove <- NULL
overlay$PRNAME <- NULL
overlay$PRUID <- NULL
overlay$CDTYPE <- NULL
overlay$CDNAME <- NULL
overlay$Name <- NULL
overlay$prov <- NULL
overlay$rt <- NULL
overlay$Route_Name <- NULL

#transform each geometry value into an area value
#this represents the area of the routes overlapping the CD
#subtract it from the area values from the BBS geometry points
#this is now the zero values
#put these zero values into the data frames below
overlay_geo <- overlay$geometry
overlay_geo <- as.data.frame(st_area(overlay_geo))
overlay$cd_area <- overlay_geo

BBS_geo <- BBSlaea$geometry
BBS_geo <- as.data.frame(st_area(BBS_geo))
BBSlaea$bbs_area <- BBS_geo
BBSlaea$Name <- NULL
BBSlaea$prov <- NULL
BBSlaea$rt <- NULL
BBSlaea$Route_Name <- NULL
BBSlaea$geometry <- NULL
overlay$geometry <- NULL

overlay <- merge(BBSlaea, overlay, by = "rt.uni")

#write and read in the overlay to get rid of factor class data
write.csv(overlay, file = "CD overlay.csv")
overlay <- read.csv(file = "CD overlay.csv")
overlay$X <- NULL

CDvalues <- read.csv(file = "bbs_ins_CD.csv")
#get rid of all columns except for CDUID, C_YEAR, CRPLND, INSECTI, and TFAREA
#landscape simplification = CRPLND / TFAREA
CDvalues$X <- NULL
CDvalues$NTFAREA <- NULL
CDvalues$NCRPLND <- NULL
CDvalues$NINSECTI <- NULL
CDvalues$REGION <- NULL

#matchup overlay CDUIDs with data from bbs_ins_CD and filter for different years
CDfilter <- merge(overlay, CDvalues, by = "CDUID")
CD1996 <- filter(CDfilter, C_YEAR == "1996")
CD2001 <- filter(CDfilter, C_YEAR == "2001")
CD2006 <- filter(CDfilter, C_YEAR == "2006")
CD2011 <- filter(CDfilter, C_YEAR == "2011")
CD2016 <- filter(CDfilter, C_YEAR == "2016")
CD1996$C_YEAR <- NULL
CD2001$C_YEAR <- NULL
CD2006$C_YEAR <- NULL
CD2011$C_YEAR <- NULL
CD2016$C_YEAR <- NULL

#find zeroes for areas of BBS routes not intersected by CD overlay.
#1996
zeroes1996 <- (CD1996$bbs_area) - (CD1996$cd_area)
zeroes1996$rt.uni <- CD1996$rt.uni
zeroes1996$TFAREA <- 0
zeroes1996$CRPLND <- 0
zeroes1996$INSECTI <- 0
zeroes1996$`st_area(BBS_geo)` <- as.integer(zeroes1996$`st_area(BBS_geo)`)
colnames(zeroes1996)[1] <- "area_m2"
zeroes1996 <- filter(zeroes1996, area_m2 > 0)

CD1996$bbs_area <- NULL
CD1996$CDUID <- NULL
CD1996$cd_area <- as.integer(unlist(CD1996$cd_area))
colnames(CD1996)[2] <- "area_m2"
CD1996 <- rbind(CD1996, zeroes1996)

#2001
zeroes2001 <- (CD2001$bbs_area) - (CD2001$cd_area)
zeroes2001$rt.uni <- CD2001$rt.uni
zeroes2001$TFAREA <- 0
zeroes2001$CRPLND <- 0
zeroes2001$INSECTI <- 0
zeroes2001$`st_area(BBS_geo)` <- as.integer(zeroes2001$`st_area(BBS_geo)`)
colnames(zeroes2001)[1] <- "area_m2"
zeroes2001 <- filter(zeroes2001, area_m2 > 0)

CD2001$bbs_area <- NULL
CD2001$CDUID <- NULL
CD2001$cd_area <- as.integer(unlist(CD2001$cd_area))
colnames(CD2001)[2] <- "area_m2"
CD2001 <- rbind(CD2001, zeroes2001)

#2006
zeroes2006 <- (CD2006$bbs_area) - (CD2006$cd_area)
zeroes2006$rt.uni <- CD2006$rt.uni
zeroes2006$TFAREA <- 0
zeroes2006$CRPLND <- 0
zeroes2006$INSECTI <- 0
zeroes2006$`st_area(BBS_geo)` <- as.integer(zeroes2006$`st_area(BBS_geo)`)
colnames(zeroes2006)[1] <- "area_m2"
zeroes2006 <- filter(zeroes2006, area_m2 > 0)

CD2006$bbs_area <- NULL
CD2006$CDUID <- NULL
CD2006$cd_area <- as.integer(unlist(CD2006$cd_area))
colnames(CD2006)[2] <- "area_m2"
CD2006 <- rbind(CD2006, zeroes2006)

#2011
zeroes2011 <- (CD2011$bbs_area) - (CD2011$cd_area)
zeroes2011$rt.uni <- CD2011$rt.uni
zeroes2011$TFAREA <- 0
zeroes2011$CRPLND <- 0
zeroes2011$INSECTI <- 0
zeroes2011$`st_area(BBS_geo)` <- as.integer(zeroes2011$`st_area(BBS_geo)`)
colnames(zeroes2011)[1] <- "area_m2"
zeroes2011 <- filter(zeroes2011, area_m2 > 0)

CD2011$bbs_area <- NULL
CD2011$CDUID <- NULL
CD2011$cd_area <- as.integer(unlist(CD2011$cd_area))
colnames(CD2011)[2] <- "area_m2"
CD2011 <- rbind(CD2011, zeroes2011)

#2016
zeroes2016 <- (CD2016$bbs_area) - (CD2016$cd_area)
zeroes2016$rt.uni <- CD2016$rt.uni
zeroes2016$TFAREA <- 0
zeroes2016$CRPLND <- 0
zeroes2016$INSECTI <- 0
zeroes2016$`st_area(BBS_geo)` <- as.integer(zeroes2016$`st_area(BBS_geo)`)
colnames(zeroes2016)[1] <- "area_m2"
zeroes2016 <- filter(zeroes2016, area_m2 > 0)

CD2016$bbs_area <- NULL
CD2016$CDUID <- NULL
CD2016$cd_area <- as.integer(unlist(CD2016$cd_area))
colnames(CD2016)[2] <- "area_m2"
CD2016 <- rbind(CD2016, zeroes2016)

#remove duplicates
CD1996 <- unique(CD1996)
CD2001 <- unique(CD2001)
CD2006 <- unique(CD2006)
CD2011 <- unique(CD2011)
CD2016 <- unique(CD2016)

#calculate weighted mean for multiple CD values on one route for each year.
Wm <- function(x,w){
  wmn = sum(x*w)/sum(w)
}

means_by_route1996 <- CD1996 %>%
  group_by(rt.uni) %>%
  summarise(mean_insecticide = Wm(x = INSECTI, w = area_m2),
            mean_cropland = Wm(x = CRPLND, w = area_m2),
            mean_total_farm = Wm(x = TFAREA, w = area_m2))
means_by_route2001 <- CD2001 %>%
  group_by(rt.uni) %>%
  summarise(mean_insecticide = Wm(x = INSECTI, w = area_m2),
            mean_cropland = Wm(x = CRPLND, w = area_m2),
            mean_total_farm = Wm(x = TFAREA, w = area_m2))
means_by_route2006 <- CD2006 %>%
  group_by(rt.uni) %>%
  summarise(mean_insecticide = Wm(x = INSECTI, w = area_m2),
            mean_cropland = Wm(x = CRPLND, w = area_m2),
            mean_total_farm = Wm(x = TFAREA, w = area_m2))
means_by_route2011 <- CD2011 %>%
  group_by(rt.uni) %>%
  summarise(mean_insecticide = Wm(x = INSECTI, w = area_m2),
            mean_cropland = Wm(x = CRPLND, w = area_m2),
            mean_total_farm = Wm(x = TFAREA, w = area_m2))
means_by_route2016 <- CD2016 %>%
  group_by(rt.uni) %>%
  summarise(mean_insecticide = Wm(x = INSECTI, w = area_m2),
            mean_cropland = Wm(x = CRPLND, w = area_m2),
            mean_total_farm = Wm(x = TFAREA, w = area_m2))



