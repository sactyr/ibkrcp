library(httptest2)

# ibkr_search_contracts() -----------------------------------------------------

with_mock_api({
  test_that("ibkr_search_contracts() returns a list", {
    result <- ibkr_search_contracts("VGS")
    expect_type(result, "list")
  })

  test_that("ibkr_search_contracts() returns non-empty result", {
    result <- ibkr_search_contracts("VGS")
    expect_gt(length(result), 0)
  })

  test_that("ibkr_search_contracts() each element has a conid", {
    result <- ibkr_search_contracts("VGS")
    expect_true(all(sapply(result, function(x) !is.null(x$conid))))
  })
})

# ibkr_get_trading_schedule() -------------------------------------------------

with_mock_api({
  test_that("ibkr_get_trading_schedule() returns a list", {
    result <- ibkr_get_trading_schedule("VGS", "ASX")
    expect_type(result, "list")
  })

  test_that("ibkr_get_trading_schedule() returns non-empty result", {
    result <- ibkr_get_trading_schedule("VGS", "ASX")
    expect_gt(length(result), 0)
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
