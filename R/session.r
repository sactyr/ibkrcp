#' Ping the session to confirm it is alive
#'
#' Should be called at the start of each trading session to verify the Client
#' Portal Gateway is running and the session is authenticated. Sessions time out
#' after approximately 5 minutes without a request.
#'
#' @return Invisibly returns the response list
#' @export
ibkr_ping <- function() {
  resp <- ibkr_post("/tickle")
  invisible(resp)
}

#' Get the current session authentication status
#'
#' @return Named list with session status fields including `authenticated`,
#'   `connected`, and `competing`
#' @export
ibkr_auth_status <- function() {
  ibkr_post("/iserver/auth/status")
}
