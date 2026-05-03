## Resubmission

This is a resubmission. The following notes from the initial pre-check have 
been addressed:

* "Possibly misspelled words: IBKR" — IBKR is the well-known ticker/abbreviation
  for Interactive Brokers. Added to inst/WORDLIST via spelling package.
* "Non-standard file: CRAN-comments.md" — added to .Rbuildignore.

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
