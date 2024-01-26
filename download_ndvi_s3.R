############################################################################################################################
#
#COPERNICUS GLOBAL LAND SERVICE (CGLS) DATA DOWNLOAD AND READ
#
#These functions allow to automatically download data provided by the Copernicus Global Land Service and open this data in R.
#See: https://land.copernicus.eu/global/
#
#These functions rely on the data provided in the data manifest of the Copernicus service.
#These functinos allow to download the data without ordering products first,
#but you need to register at https://land.copernicus.eu/global/ and create a username and password.
#
#Set your path, username, password, timeframe, product, resolution and if more than 1 version exists, version number. New products are created regularly.
#For the most recent product availabilities at the Copernicus data manifest check: https://land.copernicus.vgt.vito.be/manifest/
#
#Be aware that Copernicus nc files have lat/long belonging to the centre of the pixel, and R uses upper/left corner:  nc_open.CGLS.data opens the orginal data without adjusting
#coordinates, while ncvar_get_CGSL.data and stack.CGLS.data open the data and adjust the coordinates.
#
#These functions are distributed in the hope that they will be useful,
#but without any warranty.
#
#Author: Willemijn Vroege, ETH Zurich.
#E-mail: wvroege@ethz.ch
#Acknowlegdments: Many thanks to Tim Jacobs, VITO, Copernicus Global Help Desk and Xavier Rotllan Puig, Aster Projects for constructive feedback.
#
#
#First version: 28.10.2019
#Last update  : 04.08.2023
#By: Harold Achicanoy, WUR and Alliance Bioversity-CIAT
###########################################################################################################################

options(warn = -1, scipen = 999)
suppressMessages(if(!require(pacman)){install.packages('pacman');library(pacman)} else {library(pacman)})
suppressMessages(pacman::p_load(RCurl, terra, tidyverse, agrodata, gtools))

## Speed raster reading
# https://frodriguezsanchez.net/post/accessing-data-from-large-online-rasters-with-cloud-optimized-geotiff-gdal-and-terra-r-package/

#Check https://land.copernicus.eu/global/products/ for a product overview and product details
#check https://land.copernicus.vgt.vito.be/manifest/ for an overview for data availability in the manifest

## Function parameters
#path       : Target directory, for example: 'D:/land.copernicus'
#username   : Username
#password   : Password
#timeframe  : time frame of interest, for example: '2020-08-11'
#product    : Product variable; choose from: 'fapar', 'fcover', 'lai', 'ndvi', 'ssm', 'swi', 'lst' ...
#resolution : Resolution; choose from: '1km', '300m' or '100m'
#version    : Version; choose from: 'v1', 'v2', 'v3' ...

# Download function
download.CGLS.data <- function(path, username, password, product, resolution, version, aoi){
  
  if(resolution == "300m"){
    resolution1 <- "333m"
    product <- paste0(product, "300")
  }else if(resolution == "1km"){
    resolution1 <- resolution
  }
  
  collection <- paste(product, version, resolution1, sep="_")
  
  product.link <- paste0("@land.copernicus.vgt.vito.be/manifest/", collection, "/manifest_cgls_", collection, "_latest.txt" )
  
  url <- paste0("https://", paste(username, password, sep=":"), product.link)
  
  file.url <- RCurl::getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE, crlf = TRUE)
  file.url <- unlist(strsplit(file.url, "\n"))
  dates    <- basename(file.url)
  dates    <- as.Date(substr(x = unlist(purrr::map(strsplit(x = dates, split = '_'), 4)), start = 1, stop = 8), format = '%Y%m%d')
  file.url <- paste0("https://",sub(".*//", "",file.url))
  # if(grepl("does not exist", file.url[10])) stop("This product is not available or the product name is misspecified")
  
  collectionPath <- paste(path,collection,sep = '/')
  print(paste("Processing data and putting it in:",collectionPath))
              
  #setwd(path)
  if(!dir.exists(collection)){
    print("Created storage folder")
    dir.create(collectionPath)
  }


  for(i in 1:length(file.url)){
    cat(paste('>>> Processing: ', dates[i], '\n', sep = ''))
    out <- paste0(path,'/',product,'_',version,'_',resolution1,'/', product, '_', dates[i], '.tif')
  
    if(!file.exists(out)){
      ncFileUrl <- file.url[[i]]
      url <- paste0(ncFileUrl, "?auth=", username, ":", password)
      
     # remote_raster <- terra::rast(vsicurl())
      temp <- terra::rast(paste('/vsicurl/', url, sep=''))
      print(temp)
      stop(paste("We are debugging"))
      
      tryCatch(expr = {
        temp <- terra::rast(paste('/vsicurl/', file.url[[i]], sep=''))
        if(version == 'v2'){temp <- temp[['NDVI']]}
        terra::ext(temp) <- c(xmin = -180, xmax = 180, ymin = -60, ymax = 80)
        terra::crs(temp) <- '+proj=longlat +datum=WGS84 +no_defs +type=crs'
        temp <- terra::crop(temp, terra::ext(aoi))
        terra::writeRaster(x         = temp,
                           filename  = out,
                           gdal      = c("COMPRESS=DEFLATE","TFW=YES"),
                           overwrite = T)
      },
      
      error = function(e){
        return(cat(paste0('File: ',file.url[[i]],' not available\n')))
      })
      
    } else {
      cat(paste0('File: ',out,' already exists.\n'))
    }
    
  }
  
  return(cat('Complete download.\n'))
  
}
