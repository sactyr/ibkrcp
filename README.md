
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ibkrcp

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/ibkrcp)](https://CRAN.R-project.org/package=ibkrcp)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/grand-total/ibkrcp)](https://CRAN.R-project.org/package=ibkrcp)
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
    page](https://www.interactivebrokers.com/campus/ibkr-api-page/cpapi-v1/)
2.  Start the gateway: `bin/run.sh root/conf.yaml` (macOS/Linux) or
    `bin\run.bat root\conf.yaml` (Windows)
3.  Log in via the browser prompt at `https://localhost:5000`
4.  Confirm the session is live before trading

## Installation

Install the released version from CRAN:

``` r
install.packages("ibkrcp")
```

Or the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("sactyr/ibkrcp")
```

## Usage

### Session management

``` r
library(ibkrcp)

# Confirm the gateway is running and the session is alive
ibkr_ping()

# Check authentication status (authenticated, connected, competing)
ibkr_auth_status()
```

### Account and portfolio

``` r
# Get all accounts
accounts <- ibkr_portfolio_accounts()
account_id <- accounts$account_id[1]

# Portfolio summary (cash balances, net liquidation, etc.)
ibkr_portfolio_summary(account_id)

# Current open positions
ibkr_portfolio_positions(account_id)
```

### Market data

``` r
# Look up a contract by symbol. Returns the raw IBKR response: an unnamed
# list of matches, each with $conid, $symbol, and $companyHeader (which
# carries the exchange, e.g. "... - ASX"). Note $description holds the
# exchange code ("ASX"), not a text description.
contracts <- ibkr_search_contracts("VGS")
match   <- Filter(function(x) x$symbol == "VGS" && x$description == "ASX", contracts)
conid   <- match[[1]]$conid

# OHLCV price history (daily bars, 1 year)
prices <- ibkr_get_price_history(conid, period = "1y")

# Trading schedule (trading days, public holidays)
schedule <- ibkr_get_trading_schedule(symbol = "VGS", exchange = "ASX")
```

### Orders

``` r
# Place a market order
ibkr_place_order(account_id, conid, side = "BUY", quantity = 10)

# View live and open orders
ibkr_live_orders()

# Cancel an order
ibkr_cancel_order(account_id, order_id = "1001")
```

## SSL note

The Client Portal Gateway runs on localhost with a self-signed
certificate. `ibkrcp` disables SSL peer and host verification for all
requests (`ssl_verifypeer = FALSE`, `ssl_verifyhost = FALSE`). This is
intentional — verifying SSL against localhost is not meaningful — and
follows IBKR’s own API guidance.

## Scope and roadmap

`ibkrcp` covers the endpoints needed for a basic automated trading
workflow: session management, account queries, market data, and order
management. The Interactive Brokers Client Portal API is significantly
broader than what is currently wrapped — real-time streaming, additional
order types, transaction history, and more remain as future work.

Contributions are welcome. If there’s an endpoint you need that isn’t
covered, please open an issue or submit a pull request on
[GitHub](https://github.com/sactyr/ibkrcp).

## Related

- [IBKR Client Portal API
  documentation](https://ibkrcampus.com/campus/ibkr-api-page/cpapi-v1/)
- [IBKR Client Portal Gateway
  download](https://ibkrcampus.com/campus/ibkr-api-page/cpapi-v1/#client-portal-gw)
