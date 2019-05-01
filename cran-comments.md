## Test environments
* local OS X install, R 3.6.0
* ubuntu 14.04 (on travis-ci), R 3.6.0
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

# youtubecaption 0.1.1

* The following includes a critical bug fix that has not been caught in CRAN submission. Even though it has been newly released, it would be appreciated if the following fix is released in CRAN version so that users are not disoriented.

* A critical bug that the third option `openxl` of `get_caption()` does not work properly has been resolved.
