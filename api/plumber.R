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

#* @get /lnurl/callback/<id>
#* @serializer json list(auto_unbox = TRUE)   # ← add this line!
function(id, req, res) {
  amount_str <- req$argsQuery$amount
  
  amount <- if (is.null(amount_str) || length(amount_str) == 0 || !grepl("^[0-9]+$", amount_str)) {
    1000000L
  } else {
    as.numeric(amount_str)
  }
  
  # Return PLAIN LIST (same as payRequest)
  response_data <- list(
    pr     = "lnbc1p5hhq59pp5xrkrx8vsmpfdhq7gn235p3gglaxnr9umw2zw0rxf2ykw2fk27lgsdqqcqzzsxqrrs0fppqzkk5sjlvqa9f767kkandvjz07dzayju4sp5kly6waup2fk0askspyfmlp9hdh264gewrac8cyplwrw667zuf4kq9qxpqysgq7ja5rc7h23qw9vkl9nhxw79x08m8vpuhfr62frkpez3q6ca44lfkrp5x4tgh3nau9w6utyld7yanmruqmcwkl7a3qkjc8vy7zajuk2splulwy5",
    routes = list()
  )
  
  response_data   # ← return the list directly – do NOT call toJSON here
}

# Helper function – now takes amount as argument
callback_handler <- function(id, amount) {

  # Use amount if you want to adjust invoice dynamically later
  # For now it's fixed, so ignored

  invoice <- "lnbc1p5hhq59pp5xrkrx8vsmpfdhq7gn235p3gglaxnr9umw2zw0rxf2ykw2fk27lgsdqqcqzzsxqrrs0fppqzkk5sjlvqa9f767kkandvjz07dzayju4sp5kly6waup2fk0askspyfmlp9hdh264gewrac8cyplwrw667zuf4kq9qxpqysgq7ja5rc7h23qw9vkl9nhxw79x08m8vpuhfr62frkpez3q6ca44lfkrp5x4tgh3nau9w6utyld7yanmruqmcwkl7a3qkjc8vy7zajuk2splulwy5"

  list(
    pr     = invoice,           # plain string
    routes = list()
  )
}
