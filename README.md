
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ibkrcp

<!-- badges: start -->

<!-- badges: end -->

`ibkrcp` is a lightweight R client for the [Interactive Brokers Client
Portal REST API](https://ibkrcampus.com/campus/ibkr-api-page/cpapi-v1/).
It covers session management, account and portfolio queries, market data
retrieval, and order placement and cancellation.

## Prerequisites

`ibkrcp` communicates with the IBKR Client Portal Gateway, a lightweight
Java process that must be running locally before any function calls are
made. The gateway exposes the REST API on `https://localhost:5000`.

1.  Download the Client Portal Gateway from the [IBKR API
    page](https://ibkrcampus.com/campus/ibkr-api-page/cpapi-v1/#client-portal-gw)
2.  Start the gateway: `java -jar root/run.jar root/conf.yaml`
3.  Log in via the browser prompt at `https://localhost:5000`
4.  Confirm the session is live before trading

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("sactyr/ibkrcp")
```

## Usage

### Session management

``` r
library(ibkrcp)

# Confirm the gateway is running and authenticated
ibkr_tickle()

# Check authentication status
ibkr_auth_status()

# Re-authenticate if the session has timed out
ibkr_reauthenticate()
```

### Account and portfolio

``` r
# Get all accounts
accounts <- ibkr_get_accounts()
account_id <- accounts$account_id[1]

# Portfolio summary (cash balances, net liquidation, etc.)
ibkr_get_summary(account_id)

# Current open positions
ibkr_get_positions(account_id)
```

### Market data

``` r
# Look up a contract ID (conid) by symbol
contracts <- ibkr_search_contracts("VGS")
conid <- contracts$conid[contracts$company_header == "VGS - ASX"]

# OHLCV price history (daily bars, 1 year)
prices <- ibkr_get_price_history(conid, period = "1y")

# ASX trading schedule (trading days, public holidays)
schedule <- ibkr_get_trading_schedule(symbol = "VGS", exchange = "ASX")
```

### Orders

``` r
# Place a market order
ibkr_place_order(account_id, conid, side = "BUY", quantity = 10)

# View open orders
ibkr_get_orders()

# Cancel an order
ibkr_cancel_order(account_id, order_id = "1001")
```

## SSL note

The Client Portal Gateway runs on localhost with a self-signed
certificate. `ibkrcp` disables SSL peer and host verification for all
requests (`ssl_verifypeer = FALSE`, `ssl_verifyhost = FALSE`). This is
intentional — verifying SSL against localhost is not meaningful — and
follows IBKR’s own API guidance.

## Related

- [IBKR Client Portal API
  documentation](https://ibkrcampus.com/campus/ibkr-api-page/cpapi-v1/)
- [IBKR Client Portal Gateway
  download](https://ibkrcampus.com/campus/ibkr-api-page/cpapi-v1/#client-portal-gw)
