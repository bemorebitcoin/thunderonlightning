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
# Callback handler – identical style to your payRequest function
callback_handler <- function(id) {
  # amount handling (from query param, millisats)
  amount <- as.numeric(req$QUERY_STRING$amount)  # or however you get it
  if (is.na(amount)) amount <- 1000000L  # fallback
  
  # Get or generate the real invoice string here
  invoice <- "lnbc1p5hhq59pp5xrkrx8vsmpfdhq7gn235p3gglaxnr9umw2zw0rxf2ykw2fk27lgsdqqcqzzsxqrrs0fppqzkk5sjlvqa9f767kkandvjz07dzayju4sp5kly6waup2fk0askspyfmlp9hdh264gewrac8cyplwrw667zuf4kq9qxpqysgq7ja5rc7h23qw9vkl9nhxw79x08m8vpuhfr62frkpez3q6ca44lfkrp5x4tgh3nau9w6utyld7yanmruqmcwkl7a3qkjc8vy7zajuk2splulwy5"
  
  # Return plain list – exactly like your payRequest
  list(
    pr     = invoice,           # ← plain string (critical: no list(), no c())
    routes = list()             # empty list
  )
}

# In your endpoint / Plumber route / Shiny handler
#* @get /lnurl/callback/<id>
function(id, req) {
  response_data <- callback_handler(id)
  
  # Serialize once, same as payRequest
  jsonlite::toJSON(
    response_data,
    auto_unbox = TRUE
  )
}
