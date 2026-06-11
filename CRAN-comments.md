## Submission

This is a minor update (0.1.2). It fixes field mappings in
`ibkr_portfolio_positions()`, hardens `ibkr_live_orders()` against missing
optional fields, and adds one new function, `ibkr_logout()`, for cleanly
terminating an authenticated session. See NEWS.md for the full list of changes.

## R CMD check results

0 errors | 0 warnings | 0 notes (locally)

## Test environments

* Windows 11 x64, R 4.5.3 (local)

## Notes for CRAN reviewers

This package provides an R client for the Interactive Brokers Client Portal
REST API. It requires a locally running IBKR Client Portal Gateway process
for live use. All tests use httptest2 mock fixtures and do not make real
network requests.

The package uses `ssl_verifypeer = FALSE` and `ssl_verifyhost = FALSE` in
httr2 requests. This is intentional and necessary: the Client Portal Gateway
runs on localhost with a self-signed certificate, and SSL verification against
localhost is not meaningful. This pattern is documented in IBKR's own API
guidance.
