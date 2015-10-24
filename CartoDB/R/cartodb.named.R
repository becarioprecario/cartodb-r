#List named maps
cartodb.named.list <- function() {

  #Get account id and api key, as set by cartodb()
  account_id <- .CartoDB$data$account.name
  api_key <- .CartoDB$data$api.key

  if(is.null(account_id) | is.null(api_key)) {
    stop("Account ID and API key must be set using  cartodb(ID, apikey)")
  }

  url <- paste0("https://", account_id, ".cartodb.com/api/v1/map/named?api_key=", api_key)

  return(content(GET(url)))
}


cartodb.named.delete <- function(named.maps = c()) {

  #Get account id and api key, as set by cartodb()
  account_id <- .CartoDB$data$account.name
  api_key <- .CartoDB$data$api.key

  if(is.null(account_id) | is.null(api_key)) {
    stop("Account ID and API key must be set using  cartodb(ID, apikey)")
  }

  if(length(named.maps) < 1) {
    warning("No maps to delete")
    return()
  }

  res <- lapply(named.map, function(n.map) {
    url <- paste0("https://", account_id, ".cartodb.com/api/v1/map/named/", n.map, "?api_key=", api_key)
    httpDELETE(url)
  })

  #FIXME: Check for errors

  return(res)
}


