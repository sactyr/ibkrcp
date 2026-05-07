#' Get all accounts associated with the authenticated user
#'
#' @return Data frame with one row per account and columns: `account_id`,
#'   `type`, `currency`, `alias`
#' @export
ibkr_portfolio_accounts <- function() {
  resp <- ibkr_get("/portfolio/accounts")

  do.call(rbind, lapply(resp, function(a) {
    data.frame(
      account_id = a$accountId,
      type       = a$type,
      currency   = a$currency,
      alias      = if (!is.null(a$alias)) a$alias else NA_character_,
      stringsAsFactors = FALSE
    )
  }))
}

#' Get portfolio summary for an account
#'
#' Returns cash balances and other high-level account metrics as a named list.
#' Each element corresponds to a summary field returned by the IBKR API (e.g.
#' `totalcashvalue`, `netliquidation`, `availablefunds`).
#'
#' @param account_id IBKR account ID string (e.g. `"U1234567"`)
#' @return Named list of summary fields. Each field is itself a list containing
#'   `amount`, `currency`, and `isNull`
#' @export
ibkr_portfolio_summary <- function(account_id) {
  ibkr_get(sprintf("/portfolio/%s/summary", account_id))
}

#' Get current positions for an account
#'
#' @param account_id IBKR account ID string
#' @param sort Field to sort by (default: `"position"`). Other valid values:
#'   `"conid"`, `"contractDesc"`, `"mktValue"`, `"unrealizedPnl"`
#' @param direction Sort direction: `"a"` for ascending (default), `"d"` for
#'   descending
#' @return Data frame with one row per position and columns: `conid`, `symbol`,
#'   `position`, `mkt_price`, `mkt_value`, `avg_cost`, `unrealised_pnl`,
#'   `currency`. Returns an empty data frame if no positions are open.
#' @export
ibkr_portfolio_positions <- function(account_id, sort = "position", direction = "a") {
  resp <- ibkr_get(
    sprintf("/portfolio2/%s/positions", account_id),
    params = list(sort = sort, direction = direction)
  )

  if (length(resp) == 0) {
    message("No open positions found for account ", account_id)
    return(data.frame())
  }

  do.call(rbind, lapply(resp, function(pos) {
    data.frame(
      conid          = pos$conid,
      symbol         = pos$description,
      position       = pos$position,
      mkt_price      = pos$mktPrice,
      mkt_value      = pos$mktValue,
      avg_cost       = pos$avgCost,
      unrealised_pnl = pos$unrealizedPnl,
      currency       = pos$currency,
      stringsAsFactors = FALSE
    )
  }))
}
