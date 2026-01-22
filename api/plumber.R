library(plumber)
library(jsonlite)
library(uuid)

# Global serializer to fix array wrapping
#* @serializer json list(auto_unbox = TRUE)

# In-memory store
reviews <- new.env(parent = emptyenv())

#* Health check
#* @get /health
function() {
  list(
    status = "ok",
    time = as.character(Sys.time())
  )
}

#* LNURL Pay Request
#* @get /lnurl/pay/<id>
function(id) {
  if (is.null(reviews[[id]])) {
    reviews[[id]] <- list(status = "requested")
  }
  
  list(
    tag            = "payRequest",
    callback       = paste0("https://thunder-lnurl-api.onrender.com/lnurl/callback/", id),
    minSendable    = 1000L,
    maxSendable    = 500000L,
    commentAllowed = 500L,
    metadata       = jsonlite::toJSON(
      list(list("text/plain", "Thunder Review")),
      auto_unbox = TRUE
    )
  )
}
