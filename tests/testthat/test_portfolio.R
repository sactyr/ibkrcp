library(httptest2)

# ibkr_portfolio_accounts() ---------------------------------------------------

with_mock_api({
  test_that("ibkr_portfolio_accounts() returns a data frame", {
    result <- ibkr_portfolio_accounts()
    expect_s3_class(result, "data.frame")
  })

  test_that("ibkr_portfolio_accounts() returns expected columns", {
    result <- ibkr_portfolio_accounts()
    expect_named(result, c("account_id", "type", "currency", "alias"))
  })

  test_that("ibkr_portfolio_accounts() returns correct values", {
    result <- ibkr_portfolio_accounts()
    expect_equal(result$account_id, "U1234567")
    expect_equal(result$currency, "AUD")
  })
})

# ibkr_portfolio_summary() ----------------------------------------------------

with_mock_api({
  test_that("ibkr_portfolio_summary() returns a list", {
    result <- ibkr_portfolio_summary("U1234567")
    expect_type(result, "list")
  })

  test_that("ibkr_portfolio_summary() contains expected fields", {
    result <- ibkr_portfolio_summary("U1234567")
    expect_true("totalcashvalue" %in% names(result))
    expect_true("netliquidation" %in% names(result))
    expect_true("availablefunds" %in% names(result))
  })
})

# ibkr_portfolio_positions() --------------------------------------------------

with_mock_api({
  test_that("ibkr_portfolio_positions() returns a data frame", {
    result <- ibkr_portfolio_positions("U1234567")
    expect_s3_class(result, "data.frame")
  })

  test_that("ibkr_portfolio_positions() returns expected columns", {
    result <- ibkr_portfolio_positions("U1234567")
    expect_named(result, c("conid", "symbol", "position", "mkt_price",
                           "mkt_value", "avg_cost", "unrealised_pnl", "currency"))
  })

  test_that("ibkr_portfolio_positions() returns correct values", {
    result <- ibkr_portfolio_positions("U1234567")
    expect_equal(result$symbol, "VGS.AX")
    expect_equal(result$position, 100)
  })
})

# ibkr_portfolio_positions() empty --------------------------------------------

with_mock_dir("no_positions", {
  test_that("ibkr_portfolio_positions() returns empty data frame when no positions", {
    result <- ibkr_portfolio_positions("U1234567")
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0)
  })
})
