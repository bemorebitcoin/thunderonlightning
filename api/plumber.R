library(plumber)
library(jsonlite)
library(uuid)

# In-memory store
reviews <- new.env(parent = emptyenv())

#* Health check
#* @get /health
#* @serializer json list(auto_unbox = TRUE)
function() {
  list(
    status = "ok",
    time = as.character(Sys.time())
  )
}

#* LNURL Pay Request
#* @get /lnurl/pay/<id>
#* @serializer json list(auto_unbox = TRUE)
function(id) {
  if (is.null(reviews[[id]])) {
    reviews[[id]] <- list(status = "requested")
  }
  
  list(
    tag            = "payRequest",
    callback       = paste0("https://thunderonlightning.onrender.com/lnurl/callback/", id),
    minSendable    = 1000L,
    maxSendable    = 500000L,
    commentAllowed = 500L,
    metadata       = jsonlite::toJSON(
      list(list("text/plain", "Thunder Review")),
      auto_unbox = TRUE
    )
  )
}

#* LNURL Callback
#* @get /lnurl/callback/<id>
function(id, amount, comment = "") {
  if (missing(amount) || !is.numeric(as.numeric(amount))) {
    return(list(error = "Missing or invalid amount"))
  }
  
  reviews[[id]] <- list(
    status = "paid",
    amount = as.numeric(amount) / 1000,
    comment = comment,
    time = Sys.time()
  )
  
  list(
    pr = "lnbc1REPLACE_WITH_REAL_INVOICE",
    routes = list()
  )
}

#* Review Status
#* @get /review/status/<id>
function(id) {
  reviews[[id]] %||% list(status = "unknown")
}
