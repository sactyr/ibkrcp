library(httptest2)

# ibkr_live_orders() ----------------------------------------------------------

with_mock_api({
  test_that("ibkr_live_orders() returns a data frame", {
    result <- ibkr_live_orders()
    expect_s3_class(result, "data.frame")
  })

  test_that("ibkr_live_orders() returns expected columns", {
    result <- ibkr_live_orders()
    expect_named(result, c("order_id", "conid", "symbol", "side",
                           "order_type", "quantity", "status"))
  })

  test_that("ibkr_live_orders() returns correct values", {
    result <- ibkr_live_orders()
    expect_equal(result$symbol, "VGS.AX")
    expect_equal(result$side, "BUY")
    expect_equal(result$status, "Submitted")
  })
})

# ibkr_live_orders() empty ----------------------------------------------------

with_mock_dir("no_orders", {
  test_that("ibkr_live_orders() returns empty data frame when no orders", {
    result <- ibkr_live_orders()
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0)
  })
})

# ibkr_place_order() ----------------------------------------------------------

with_mock_api({
  test_that("ibkr_place_order() returns invisibly", {
    expect_invisible(ibkr_place_order("U1234567", 123456789, "BUY", 10))
  })
})

# ibkr_place_order() input validation -----------------------------------------

test_that("ibkr_place_order() stops on invalid side", {
  expect_error(
    ibkr_place_order("U1234567", 123456789, "HOLD", 10),
    "side must be 'BUY' or 'SELL'"
  )
})

test_that("ibkr_place_order() stops on zero quantity", {
  expect_error(
    ibkr_place_order("U1234567", 123456789, "BUY", 0),
    "quantity must be a positive integer"
  )
})

# ibkr_cancel_order() ---------------------------------------------------------

with_mock_api({
  test_that("ibkr_cancel_order() returns invisibly", {
    expect_invisible(ibkr_cancel_order("U1234567", "1001"))
  })
})
