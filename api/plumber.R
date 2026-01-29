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
callback_fn <- function(id, amount = NULL) {   # amount comes from query param
  
  # Optional: validate or log the requested amount (in millisats)
  if (is.null(amount)) {
    amount <- 1000000L  # fallback, or return error
  }
  
  # Here: generate / fetch the REAL BOLT11 invoice
  # Replace this placeholder with your actual invoice creation logic
  invoice <- "lnbc1p5hhq59pp5xrkrx8vsmpfdhq7gn235p3gglaxnr9umw2zw0rxf2ykw2fk27lgsdqqcqzzsxqrrs0fppqzkk5sjlvqa9f767kkandvjz07dzayju4sp5kly6waup2fk0askspyfmlp9hdh264gewrac8cyplwrw667zuf4kq9qxpqysgq7ja5rc7h23qw9vkl9nhxw79x08m8vpuhfr62frkpez3q6ca44lfkrp5x4tgh3nau9w6utyld7yanmruqmcwkl7a3qkjc8vy7zajuk2splulwy5"
  
  # Return the EXACT same kind of plain list as your payRequest function
  list(
    pr     = invoice,                  # ← plain string, NOT list() or c()
    routes = list()                    # empty list
    # successAction = list(
    #   tag = "message",
    #   message = "Thanks for the Thunder Review! ⚡️"
    # )
  )
}

#* Review Status
#* @get /review/status/<id>
function(id) {
  reviews[[id]] %||% list(status = "unknown")
}

# Example Plumber style (adapt to your actual setup)
#* @get /lnurl/callback/<id>
function(id, req, res) {
  # Get amount from query string
  amount_str <- req$QUERY_STRING$amount
  amount <- if (is.null(amount_str)) NULL else as.numeric(amount_str)
  
  # Call the function – same pattern as payRequest
  response_data <- callback_fn(id, amount)
  
  # Serialize **once only** – just like your payRequest
  jsonlite::toJSON(
    response_data,
    auto_unbox = TRUE,
    pretty     = FALSE
  )
}
