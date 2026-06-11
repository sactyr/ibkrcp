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


#' Log out of the current session
#'
#' Cleanly terminates the authenticated Client Portal Gateway session. Useful
#' for tearing down a session at the end of a scheduled run so it does not
#' linger and conflict with a subsequent login.
#'
#' @return Invisibly returns the response list. The API returns a list with a
#'   `confirmed` (or `status`) field indicating the logout succeeded.
#' @export
ibkr_logout <- function() {
  resp <- ibkr_post("/logout")
  invisible(resp)
}
