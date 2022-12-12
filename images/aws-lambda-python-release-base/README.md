# AWS Lambda Python Release Base

This image is used by the Lambdas in the `release` stage to keep their Python versions and patches up to date.

The `PYTHON_VERSION` is set in the `Jenkinsfile`.

## Building

If you need to build this image locally, you can run `make build-release-base` from the root of this repository.
