#' Search for contracts by symbol
#'
#' Queries the IBKR contract search endpoint and returns all matching results.
#' Use this to look up conids (IBKR contract IDs) before placing orders or
#' fetching price history.
#'
#' @param symbol Ticker symbol to search for (e.g. `"VGS"`)
#' @param sec_type Security type filter (default: `"STK"` for equities and ETFs)
#' @return Raw response list as returned by IBKR. Stops with an error if no
#'   matches are found.
#' @export
ibkr_search_contracts <- function(symbol, sec_type = "STK") {
  resp <- ibkr_post("/iserver/secdef/search", body = list(
    symbol  = symbol,
    secType = sec_type
  ))

  if (length(resp) == 0) {
    stop(sprintf("No contracts found for symbol: %s", symbol))
  }

  resp
}

#' Get the trading schedule for an instrument
#'
#' Returns the raw IBKR trading schedule for the given symbol and exchange.
#'
#' @param symbol Ticker symbol (e.g. `"VGS"`)
#' @param exchange Exchange code (e.g. `"ASX"`, `"NYSE"`)
#' @param asset_class Asset class (default: `"STK"`)
#' @return Raw response list as returned by IBKR. Stops with an error if no
#'   schedule is returned.
#' @export
ibkr_get_trading_schedule <- function(symbol, exchange, asset_class = "STK") {
  resp <- ibkr_get("/trsrv/secdef/schedule", params = list(
    assetClass = asset_class,
    symbol     = symbol,
    exchange   = exchange
  ))

  if (length(resp) == 0) {
    stop(sprintf("No trading schedule returned for symbol: %s on %s", symbol, exchange))
  }

  resp
}
