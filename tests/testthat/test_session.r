library(httptest2)

# ibkr_tickle() ---------------------------------------------------------------

with_mock_api({
  test_that("ibkr_tickle() returns invisibly when authenticated", {
    expect_invisible(ibkr_tickle())
  })

  test_that("ibkr_tickle() stops when not authenticated", {
    with_mock_dir("unauthenticated", {
      expect_error(ibkr_tickle(), "not authenticated")
    })
  })
})

# ibkr_auth_status() ----------------------------------------------------------

with_mock_api({
  test_that("ibkr_auth_status() returns a list", {
    resp <- ibkr_auth_status()
    expect_type(resp, "list")
  })
})

# ibkr_reauthenticate() -------------------------------------------------------

with_mock_api({
  test_that("ibkr_reauthenticate() returns invisibly", {
    expect_invisible(ibkr_reauthenticate())
  })
})
