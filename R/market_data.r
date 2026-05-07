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
