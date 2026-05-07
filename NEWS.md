# ibkrcp 0.1.1

* `ibkr_search_contracts()`: fixed incorrect HTTP method (GET → POST) to match
  the IBKR Client Portal API specification.
* `ibkr_get_trading_schedule()`: removed hardcoded `symbol` and `exchange`
  defaults; both are now required arguments. Function now returns the raw API
  response instead of a parsed data frame.
* `ibkr_tickle()` renamed to `ibkr_ping()` and switched to POST per API spec.
  Authentication check removed from the function — callers handle this logic.
* `ibkr_auth_status()`: fixed incorrect HTTP method (GET → POST).
* `ibkr_reauthenticate()` removed — deprecated by IBKR and unused.
* `ibkr_get_accounts()` renamed to `ibkr_portfolio_accounts()`.
* `ibkr_get_summary()` renamed to `ibkr_portfolio_summary()`.
* `ibkr_get_positions()` renamed to `ibkr_portfolio_positions()`. Updated to
  use the `/portfolio2/` endpoint; added `sort` and `direction` parameters.
* `ibkr_get_orders()` renamed to `ibkr_live_orders()`. Added `filters` and
  `force` parameters.
* `ibkr_confirm_order_messages()` renamed to `ibkr_reply_order()`.

# ibkrcp 0.1.0

* Initial CRAN submission.
