library(httptest2)

# ibkr_ping() -----------------------------------------------------------------

with_mock_api({
  test_that("ibkr_ping() returns invisibly", {
    expect_invisible(ibkr_ping())
  })
})

# ibkr_auth_status() ----------------------------------------------------------

with_mock_api({
  test_that("ibkr_auth_status() returns a list", {
    resp <- ibkr_auth_status()
    expect_type(resp, "list")
  })
})
