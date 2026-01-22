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

print("DEBUG: FIXED VERSION 2026-01-22 v2")  # ← add this

#──────────────────────────────────────────────
# CALLBACK (WALLET CALLS THIS)
#──────────────────────────────────────────────
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

#──────────────────────────────────────────────
# STATUS (FOR SHINY POLLING)
#──────────────────────────────────────────────
#* Review Status
#* @get /review/status/<id>
function(id) {
  reviews[[id]] %||% list(status = "unknown")
}

#* Health check
#* @get /health
function() {
  list(status = "ok", time = Sys.time())
}
