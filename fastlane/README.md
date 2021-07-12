fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### prepare_build
```
fastlane prepare_build
```
Installing dependencies, clean build
### run_tests_on_build
```
fastlane run_tests_on_build
```
Running tests and skip build
### build_and_test
```
fastlane build_and_test
```
Installing dependencies, clean build and running tests

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
