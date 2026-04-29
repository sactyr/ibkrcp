#' Tickle the session to confirm it is alive
#'
#' Should be called at the start of each trading session to verify the Client
#' Portal Gateway is running and the session is authenticated. Sessions time out
#' after approximately 5 minutes without a request.
#'
#' @return Invisibly returns the response list. Stops with an error if the
#'   session is not authenticated.
#' @export
ibkr_tickle <- function() {
  resp <- ibkr_get("/tickle")

  if (!isTRUE(resp$iserver$authStatus$authenticated)) {
    stop(
      "IBKR session is not authenticated. ",
      "Please log in via the Client Portal Gateway before trading."
    )
  }

  message("IBKR session is alive and authenticated.")
  invisible(resp)
}

#' Get the current session authentication status
#'
#' @return Named list with session status fields including `authenticated`,
#'   `connected`, and `competing`
#' @export
ibkr_auth_status <- function() {
  ibkr_get("/iserver/auth/status")
}

#' Reauthenticate the session
#'
#' Call this if the session has timed out but the gateway is still running.
#' After calling this function, wait a few seconds then call [ibkr_tickle()]
#' to confirm the session is restored.
#'
#' @return Invisibly returns the response list
#' @export
ibkr_reauthenticate <- function() {
  resp <- ibkr_post("/iserver/reauthenticate")
  message("Reauthentication requested. Wait a few seconds then call ibkr_tickle().")
  invisible(resp)
}
