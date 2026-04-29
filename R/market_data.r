#' Search for contracts by symbol
#'
#' Queries the IBKR contract search endpoint and returns all matching results.
#' Use this to look up conids (IBKR contract IDs) before placing orders or
#' fetching price history. To find ASX-listed contracts, filter the results
#' for rows where `description` or `company_header` contains `"ASX"`.
#'
#' @param symbol Ticker symbol to search for (e.g. `"VGS"`)
#' @param sec_type Security type filter (default: `"STK"` for equities and ETFs)
#' @return Data frame with one row per match and columns: `conid`, `symbol`,
#'   `company_name`, `description`, `company_header`. Returns an empty data
#'   frame if no matches are found.
#' @export
ibkr_search_contracts <- function(symbol, sec_type = "STK") {
  resp <- ibkr_get("/iserver/secdef/search", params = list(
    symbol  = symbol,
    secType = sec_type
  ))

  if (length(resp) == 0) {
    message(sprintf("No contracts found for symbol: %s", symbol))
    return(data.frame())
  }

  do.call(rbind, lapply(resp, function(x) {
    data.frame(
      conid          = as.integer(x$conid),
      symbol         = x$symbol,
      company_name   = if (!is.null(x$companyName))   x$companyName   else NA_character_,
      description    = if (!is.null(x$description))   x$description   else NA_character_,
      company_header = if (!is.null(x$companyHeader)) x$companyHeader else NA_character_,
      stringsAsFactors = FALSE
    )
  }))
}

#' Get the trading schedule for an instrument
#'
#' Returns the IBKR trading schedule for the given symbol and exchange,
#' including trading and non-trading dates. Non-trading dates are those where
#' the `sessions` field is empty (public holidays). Weekend dates are not
#' included in the schedule.
#'
#' @param symbol Ticker symbol (default: `"VGS"`)
#' @param exchange Exchange code (default: `"ASX"`)
#' @param asset_class Asset class (default: `"STK"`)
#' @return Data frame with columns: `date` (Date), `is_trading` (logical),
#'   `sessions` (character, semicolon-separated session open/close times or
#'   `NA` for non-trading days). Template dates (year 2000) are excluded.
#' @export
ibkr_get_trading_schedule <- function(symbol = "VGS", exchange = "ASX", asset_class = "STK") {
  resp <- ibkr_get("/trsrv/secdef/schedule", params = list(
    assetClass = asset_class,
    symbol     = symbol,
    exchange   = exchange
  ))

  if (length(resp) == 0) return(data.frame())

  exch <- Filter(function(x) x$exchange == exchange, resp)
  if (length(exch) == 0) exch <- resp[1]

  schedules <- exch[[1]]$schedules

  # Exclude template dates (year 2000)
  schedules <- Filter(function(s) !startsWith(as.character(s$tradingScheduleDate), "2000"), schedules)

  do.call(rbind, lapply(schedules, function(s) {
    d <- as.Date(as.character(s$tradingScheduleDate), "%Y%m%d")
    has_sessions <- length(s$sessions) > 0
    session_str  <- if (has_sessions) {
      paste(sapply(s$sessions, function(x) paste0(x$openingTime, "-", x$closingTime)), collapse = ";")
    } else NA_character_

    data.frame(
      date       = d,
      is_trading = has_sessions,
      sessions   = session_str,
      stringsAsFactors = FALSE
    )
  }))
}

#' Get OHLCV price history for an instrument
#'
#' Fetches daily OHLCV bars from the IBKR Client Portal API. The `t` timestamp
#' field (Unix milliseconds) is converted to an `Australia/Sydney` date, which
#' correctly handles the UTC offset for ASX bar open times (~09:59 AEST =
#' 23:59 UTC the prior day).
#'
#' @param conid Integer conid of the instrument
#' @param period History period string. Valid values: `"1m"`, `"3m"`, `"6m"`,
#'   `"1y"` (default), `"2y"`, `"3y"`, `"5y"`
#' @return Data frame with columns: `date` (Date), `open`, `high`, `low`,
#'   `close` (numeric), `volume` (integer), sorted chronologically
#' @export
ibkr_get_price_history <- function(conid, period = "1y") {
  resp <- ibkr_get("/iserver/marketdata/history", params = list(
    conid      = conid,
    period     = period,
    bar        = "1d",
    outsideRth = FALSE
  ))

  if (is.null(resp$data) || length(resp$data) == 0) {
    stop(sprintf(
      "No price history returned for conid %d. Ensure the session is active (not read-only).",
      conid
    ))
  }

  bars <- do.call(rbind, lapply(resp$data, function(bar) {
    data.frame(
      date   = as.Date(format(as.POSIXct(bar$t / 1000, origin = "1970-01-01",
                tz = "Australia/Sydney"), "%Y-%m-%d")),
      open   = bar$o,
      high   = bar$h,
      low    = bar$l,
      close  = bar$c,
      volume = as.integer(bar$v),
      stringsAsFactors = FALSE
    )
  }))

  bars[order(bars$date), ]
}
