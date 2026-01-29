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
  pr = "lnbc1p5hhq59pp5xrkrx8vsmpfdhq7gn235p3gglaxnr9umw2zw0rxf2ykw2fk27lgsdqqcqzzsxqrrs0fppqzkk5sjlvqa9f767kkandvjz07dzayju4sp5kly6waup2fk0askspyfmlp9hdh264gewrac8cyplwrw667zuf4kq9qxpqysgq7ja5rc7h23qw9vkl9nhxw79x08m8vpuhfr62frkpez3q6ca44lfkrp5x4tgh3nau9w6utyld7yanmruqmcwkl7a3qkjc8vy7zajuk2splulwy5",   # ← plain character string, no list/c()
  routes = list()   # or vector()
) |> jsonlite::toJSON(auto_unbox = TRUE)
}

#* Review Status
#* @get /review/status/<id>
function(id) {
  reviews[[id]] %||% list(status = "unknown")
}
