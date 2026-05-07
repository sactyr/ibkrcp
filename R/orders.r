#' Get all live and open orders
#'
#' @param filters Optional character vector of order status filters (e.g.
#'   `c("Filled", "Cancelled")`)
#' @param force If `TRUE`, forces a fresh fetch bypassing the cache
#'   (default: `FALSE`)
#' @return Data frame with one row per order and columns: `order_id`, `conid`,
#'   `symbol`, `side`, `order_type`, `quantity`, `status`. Returns an empty
#'   data frame if no open orders exist.
#' @export
ibkr_live_orders <- function(filters = NULL, force = FALSE) {
  params <- list(force = force)
  if (!is.null(filters)) params$filters <- paste(filters, collapse = ",")

  resp <- ibkr_get("/iserver/account/orders", params = params)
  orders <- resp$orders

  if (is.null(orders) || length(orders) == 0) {
    message("No open orders found.")
    return(data.frame())
  }

  do.call(rbind, lapply(orders, function(o) {
    data.frame(
      order_id   = o$orderId,
      conid      = o$conid,
      symbol     = o$ticker,
      side       = o$side,
      order_type = o$orderType,
      quantity   = o$totalSize,
      status     = o$status,
      stringsAsFactors = FALSE
    )
  }))
}

#' Place a market order
#'
#' Places a DAY market order for a single instrument. Confirmation prompts
#' returned by the API (e.g. price deviation warnings) are handled
#' automatically via `ibkr_reply_order()`.
#'
#' @param account_id IBKR account ID string (e.g. `"U1234567"`)
#' @param conid Integer conid of the instrument
#' @param side `"BUY"` or `"SELL"`
#' @param quantity Number of shares (positive integer)
#' @return Invisibly returns the final order response list
#' @export
ibkr_place_order <- function(account_id, conid, side, quantity) {
  side     <- toupper(side)
  quantity <- as.integer(quantity)

  if (!side %in% c("BUY", "SELL")) stop("side must be 'BUY' or 'SELL'")
  if (quantity <= 0)               stop("quantity must be a positive integer")

  resp <- ibkr_post(
    sprintf("/iserver/account/%s/orders", account_id),
    body = list(
      orders = list(list(
        conid     = conid,
        orderType = "MKT",
        side      = side,
        quantity  = quantity,
        tif       = "DAY"
      ))
    )
  )

  resp <- ibkr_reply_order(resp)

  message(sprintf(
    "Order placed: %s %d shares (conid %d) for account %s",
    side, quantity, conid, account_id
  ))

  invisible(resp)
}

#' Reply to order confirmation messages returned by IBKR
#'
#' After placing an order, IBKR may return one or more confirmation prompts
#' (e.g. price deviation warnings, regulatory notices). This function
#' automatically confirms each prompt in sequence.
#' Called internally by `ibkr_place_order()`.
#'
#' @param resp Response list from the place order POST
#' @return Final response after all messages are confirmed
#' @noRd
ibkr_reply_order <- function(resp) {
  while (
    is.list(resp) && length(resp) > 0 &&
    is.list(resp[[1]]) &&
    !is.null(resp[[1]]$id) &&
    !is.null(resp[[1]]$message)
  ) {
    message(sprintf("Confirming order message: %s", resp[[1]]$message[[1]]))
    resp <- ibkr_post(
      sprintf("/iserver/reply/%s", resp[[1]]$id),
      body = list(confirmed = TRUE)
    )
  }
  resp
}

#' Cancel an open order
#'
#' @param account_id IBKR account ID string
#' @param order_id Order ID to cancel (as returned by `ibkr_live_orders()`)
#' @return Invisibly returns the response list
#' @export
ibkr_cancel_order <- function(account_id, order_id) {
  resp <- ibkr_delete(sprintf("/iserver/account/%s/order/%s", account_id, order_id))
  message(sprintf("Order %s cancelled for account %s", order_id, account_id))
  invisible(resp)
}
