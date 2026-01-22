library(plumber)
library(jsonlite)
library(uuid)

# In-memory store (replace with DB later)
reviews <- new.env(parent = emptyenv())

#──────────────────────────────────────────────
# LNURL-PAY ENTRY POINT
#──────────────────────────────────────────────

#* LNURL Pay Request
#* @get /lnurl/pay/<id>
function(id) {
  
  # Create session if not exists
  if (is.null(reviews[[id]])) {
    reviews[[id]] <- list(status = "requested")
  }
  
  # Build flat list with scalars (no extra lists!)
  response <- list(
    tag           = "payRequest",                                      # string
    callback      = paste0("https://thunder-lnurl-api.onrender.com/lnurl/callback/", id),  # string (use your real Render URL)
    minSendable   = 1000L,                                             # integer (L for long/int)
    maxSendable   = 500000L,                                           # integer
    commentAllowed = 500L,                                             # integer
    metadata      = jsonlite::toJSON(                                  # stringified array
      list(
        list("text/plain", "Thunder Review")                           # plain text description
        # Add more metadata if needed, e.g. list("text/identifier", "your-id")
      ),
      auto_unbox = TRUE
    )
  )
  
  # Return plain list (jsonlite will handle serialization correctly)
  response
}

#──────────────────────────────────────────────
# CALLBACK (WALLET CALLS THIS)
#──────────────────────────────────────────────

#* LNURL Callback
#* @get /lnurl/callback/<id>
function(id, amount, comment = "") {
  
  # Save payment
  reviews[[id]] <- list(
    status  = "paid",
    amount  = as.numeric(amount) / 1000, # sats
    comment = comment,
    time    = Sys.time()
  )
  
  # ⚠️ Replace with real Lightning invoice
  list(
    pr = "lnbc1REPLACE_WITH_REAL_INVOICE",
    routes = list()
  )
}

#──────────────────────────────────────────────
# STATUS (FOR SHINY POLLING)
#──────────────────────────────────────────────

#* Review Status
#* @get /review/status/<id>
function(id) {
  reviews[[id]] %||% list(status = "unknown")
}
