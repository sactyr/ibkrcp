library(httptest2)

# ibkr_search_contracts() -----------------------------------------------------

with_mock_api({
  test_that("ibkr_search_contracts() returns a data frame", {
    result <- ibkr_search_contracts("VGS")
    expect_s3_class(result, "data.frame")
  })

  test_that("ibkr_search_contracts() returns expected columns", {
    result <- ibkr_search_contracts("VGS")
    expect_named(result, c("conid", "symbol", "company_name",
                           "description", "company_header"))
  })

  test_that("ibkr_search_contracts() returns correct values", {
    result <- ibkr_search_contracts("VGS")
    expect_equal(result$symbol[1], "VGS")
    expect_type(result$conid, "integer")
  })
})

# ibkr_get_trading_schedule() -------------------------------------------------

with_mock_api({
  test_that("ibkr_get_trading_schedule() returns a data frame", {
    result <- ibkr_get_trading_schedule()
    expect_s3_class(result, "data.frame")
  })

  test_that("ibkr_get_trading_schedule() returns expected columns", {
    result <- ibkr_get_trading_schedule()
    expect_named(result, c("date", "is_trading", "sessions"))
  })

  test_that("ibkr_get_trading_schedule() date column is Date class", {
    result <- ibkr_get_trading_schedule()
    expect_s3_class(result$date, "Date")
  })

  test_that("ibkr_get_trading_schedule() excludes year-2000 template dates", {
    result <- ibkr_get_trading_schedule()
    expect_false(any(format(result$date, "%Y") == "2000"))
  })
})

# ibkr_get_price_history() ----------------------------------------------------

with_mock_api({
  test_that("ibkr_get_price_history() returns a data frame", {
    result <- ibkr_get_price_history(123456789)
    expect_s3_class(result, "data.frame")
  })

  test_that("ibkr_get_price_history() returns expected columns", {
    result <- ibkr_get_price_history(123456789)
    expect_named(result, c("date", "open", "high", "low", "close", "volume"))
  })

  test_that("ibkr_get_price_history() date column is Date class", {
    result <- ibkr_get_price_history(123456789)
    expect_s3_class(result$date, "Date")
  })

  test_that("ibkr_get_price_history() is sorted chronologically", {
    result <- ibkr_get_price_history(123456789)
    expect_equal(result$date, sort(result$date))
  })

  test_that("ibkr_get_price_history() stops when no data returned", {
    with_mock_dir("no_history", {
      expect_error(ibkr_get_price_history(123456789), "No price history returned")
    })
  })
})
