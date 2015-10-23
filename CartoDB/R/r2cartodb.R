### r2cartodb: a function to import data to your CartoDB account.  
#Original code by Kyle Walker, Texas Christian University
#See https://rpubs.com/walkerke/r2cartodb
#
# Set your working directory before calling the function.  
# Also, the function depends on the rgdal and httr packages, and requires that you have Rtools installed 
# (and that you have Rtools in your PATH if you are on Windows) if you want to upload spatial
# data frames.  

library(rgdal)
library(httr)

# Advisable to make the layer name different from your imported data, if applicable.

#r2cartodb <- function(obj, layer_name, account_id, api_key) {   
r2cartodb <- function(obj, layer_name, account_id, api_key) {   
  
  #Get account id and api key, as set by cartodb()
  account_id <- .CartoDB$data$account.name
  api_key <- .CartoDB$data$api.key

  if(is.null(account_id) | is.null(api_key)) {
    stop("Account ID and API key must be set using  cartodb(ID, apikey)")
  }

  current.dir <- getwd()
  temp.dir <- tempdir()
  
  cartodb_url <- paste0("https://", 
                        account_id, 
                        ".cartodb.com/api/v1/imports/?api_key=", 
                        api_key)
  
  if (class(obj) == "data.frame") { 
    
    # Will import a basic table or a spatial table if it can detect long/lat columns.
    # The function first writes a CSV then uploads it.  
    
    csv_name <- paste0(temp.dir, "/", layer_name, ".csv")
    
    write.csv(obj, csv_name)
    
    POST(cartodb_url, 
         encode = "multipart", 
         body = list(file = upload_file(csv_name)), 
         verbose())  
    
  } else if (inherits(obj, "Spatial")) {  
    
    # Assuming here that you're using a Spatial*DataFrame, which can be written to a shapefile.  The
    # function will first write to a shapefile and then upload.  
    
    writeOGR(obj = obj, 
             dsn = temp.dir, 
             layer = layer_name, 
             driver = "ESRI Shapefile", 
             overwrite_layer = TRUE)
    
    pattern = paste0(layer_name, "\\.*")
    
    files <- list.files(path = temp.dir, pattern = pattern, full.names = TRUE)
    
    zip_name <- paste0(temp.dir, "/", layer_name, ".zip")
    
    zip(zipfile = zip_name, files = files, flags = "-D9X")
    
    POST(cartodb_url, 
         encode = "multipart", 
         body = list(file = upload_file(zip_name)), 
         verbose())  
    
  } else {
    
      stop("The r2cartodb function requires a data frame or spatial data frame")
    
    }
}
