#' @importFrom httr2 request req_options req_headers req_url_query
#' @importFrom httr2 req_body_json req_perform resp_status resp_body_string resp_body_json
NULL
IBKR_BASE_URL <- "https://localhost:5000/v1/api"

#' Make a GET request to the IBKR Client Portal API
#'
#' @param endpoint API endpoint path (e.g. `"/tickle"`)
#' @param params Named list of query parameters, or `NULL`
#' @return Parsed JSON response as an R list
#' @noRd
ibkr_get <- function(endpoint, params = NULL) {
  req <- request(paste0(IBKR_BASE_URL, endpoint)) |>
    req_options(ssl_verifypeer = FALSE, ssl_verifyhost = FALSE) |>
    req_headers(
      "User-Agent" = "R/ibkrcp",
      "Accept"     = "*/*",
      "Connection" = "keep-alive"
    )

  if (!is.null(params)) req <- req |> req_url_query(!!!params)

  resp <- req |> req_perform()

  if (resp_status(resp) != 200) {
    stop(sprintf(
      "IBKR API GET %s failed with status %d: %s",
      endpoint, resp_status(resp), resp_body_string(resp)
    ))
  }

  resp |> resp_body_json()
}

#' Make a POST request to the IBKR Client Portal API
#'
#' @param endpoint API endpoint path
#' @param body Named list to be serialised as JSON, or `NULL`
#' @return Parsed JSON response as an R list
#' @noRd
ibkr_post <- function(endpoint, body = NULL) {
  req <- request(paste0(IBKR_BASE_URL, endpoint)) |>
    req_options(ssl_verifypeer = FALSE, ssl_verifyhost = FALSE) |>
    req_headers(
      "User-Agent"   = "R/ibkrcp",
      "Accept"       = "*/*",
      "Connection"   = "keep-alive",
      "Content-Type" = "application/json"
    )

  if (!is.null(body)) req <- req |> req_body_json(body)

  resp <- req |> req_perform()

  if (!resp_status(resp) %in% c(200, 201)) {
    stop(sprintf(
      "IBKR API POST %s failed with status %d: %s",
      endpoint, resp_status(resp), resp_body_string(resp)
    ))
  }

  resp |> resp_body_json()
}

#' Make a DELETE request to the IBKR Client Portal API
#'
#' @param endpoint API endpoint path
#' @return Parsed JSON response as an R list
#' @noRd
ibkr_delete <- function(endpoint) {
  req <- request(paste0(IBKR_BASE_URL, endpoint)) |>
    req_options(ssl_verifypeer = FALSE, ssl_verifyhost = FALSE) |>
    req_headers(
      "User-Agent" = "R/ibkrcp",
      "Accept"     = "*/*",
      "Connection" = "keep-alive"
    )

  resp <- req |> req_perform()

  if (resp_status(resp) != 200) {
    stop(sprintf(
      "IBKR API DELETE %s failed with status %d: %s",
      endpoint, resp_status(resp), resp_body_string(resp)
    ))
  }

  resp |> resp_body_json()
}
