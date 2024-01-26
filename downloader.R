library(RCurl)

# URL of the file to download
url <- "https://land.copernicus.vgt.vito.be/PDF/datapool/Vegetation/Indicators/NDVI_300m_V1/2021/01/01/NDVI300_202101010000_GLOBE_PROBAV_V1.0.1/c_gls_NDVI300_202101010000_GLOBE_PROBAV_V1.0.1.nc"

# Local path to save the downloaded file
local_file_path <- "c_gls_NDVI300_202101010000_GLOBE_PROBAV_V1.0.63b.nc"

url <- 'http://1de7-197-155-65-98.ngrok-free.app'
# Basic Authentication credentials
username <- "masgeek"
password <- "andalite6"

download_file <- function(url,username,password,file_path){
  if(file.exists(file_path)){
    # do not run the download
    print(paste("File already exists", file_path))
    return(0)
  }
  # Create the URL options for basic authentication
  url_options <- list(
    httpauth = 1L,  # Use basic authentication
    userpwd = paste0(username, ":", password)
  )
  
  bdown=function(url, file){
    f = CFILE(file, mode="wb")
    a = curlPerform(url = url, writedata = f@ref, noprogress=FALSE, .opts = url_options  )
    close(f)
    return(a)
  }
  
  print(paste("Downloading from",url))
  ret = bdown(url, file_path)
}


download_file(url,username,password,local_file_path)
