############################################################################################################################
#
#COPERNICUS GLOBAL LAND SERVICE (CGLS) DATA DOWNLOAD AND READ: EXAMPLE
#
#This is an example on how to run the functions found in 'land.Copernicus Data Download.R'
#
#These functions allow to automatically download data provided by the Copernicus Global Land Service and open this data in R.
#See: https://land.copernicus.eu/global/
#
#These functions rely on the data provided in the data manifest of the Copernicus service.
#These functinos allow to download the data without ordering products first,
#but you need to register at https://land.copernicus.eu/global/ and create a username and password.
#
#Set your path, username, password, timeframe, product, resolution and if more than 1 version exists, version number. New products are created regularly.
#
#Be aware that Copernicus nc files have lat/long belonging to the centre of the pixel, and R uses upper/left corner:  nc_open.CGLS.data opens the orginal data without adjusting 
#coordinates, while ncvar_get_CGSL.data and stack.CGLS.data open the data and adjust the coordinates.
#
#These functions are distributed in the hope that they will be useful,
#but without any warranty.
#
#Author: Willemijn Vroege, ETH Zurich
#E-mail: wvroege@ethz.ch
#Acknowlegdments: Many thanks to Tim Jacobs, VITO, Copernicus Global Help Desk and Xavier Rotllan Puig, Aster Projects for constructive feedback.
#
#
#First version: 28.10.2019
#Last update  : 12.06.2020
#
###########################################################################################################################


## Reading Functions ####
#if(require(devtools) == FALSE){install.packages("devtools", repos = "https://cloud.r-project.org"); library(devtools)} else {library(devtools)}

#source_url("https://github.com/xavi-rp/Copernicus-Global-Land-Service-Data-Download-with-R/blob/master/land.Copernicus%20Data%20Download.R?raw=TRUE")

source("download_ndvi_s3.R")

## Downloading Data ####
#SET TARGET DIRECTORY USERNAME, PASSWORD, TIMEFRAME OF YOUR INTEREST AND PRODUCT (constising of a product, resolution and version).
#Check https://land.copernicus.eu/global/products/ for a product overview and product details
#check https://land.copernicus.vgt.vito.be/manifest/ for an overview for data availability in the manifest

PATH       <-  #INSERT TARGET DIRECTORY, for example: D:/land.copernicus
USERNAME   <- "masgeek" #INSERT USERNAME
PASSWORD   <- "andalite6" #INSERT PASSWORD
TIMEFRAME  <- seq(as.Date("2020-06-01"), as.Date("2020-06-15"), by="days") #INSERT TIMEFRAME OF INTEREST, for example June 2019
PRODUCT    <- "ndvi" #INSERT PRODUCT VARIABLE;(for example fapar) -> CHOSE FROM fapar, fcover, lai, ndvi,  ssm, swi, lst, ...
RESOLUTION <- "300m" #INSERT RESOLTION (1km, 300m or 100m)
VERSION    <- "v1" #"INSERT VERSION: "v1", "v2", "v3",...
AOI<- geodata::gadm('Rwanda', level = 2, path='.')

download.CGLS.data(path=PATH, username=USERNAME, password=PASSWORD, aoi=AOI, product=PRODUCT, resolution=RESOLUTION, version=VERSION)
