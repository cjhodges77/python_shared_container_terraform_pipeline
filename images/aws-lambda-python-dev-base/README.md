# AWS Lambda Python Dev Base

This image contains a common set of tooling for our Lambdas.

It should be used for the `dev` stage in your Lambda's Dockerfile.

When using `buildLambda`, any dependencies specified in your `pyproject.toml` are ignored in favour of these.

## Building

If you need to build this image locally, you can run `make build-dev-base` from the root of this repository.

This will build the `aws-lambda-release-base` first, and then this image.

## Running

The linting tests can be run in multiple ways:

- `poetry install && make lint PATH="$PWD/../example-project`
- `make build-dev-base && docker run --rm -w /devtools --entrypoint make -v "$PWD/example-project:/var/task" ************.dkr.ecr.eu-west-2.amazonaws.com/aws-lambda-dev-base:latest mypy`
- Through the `make lint` command in `/devtools` through a `batect.yml` file (see the example-project)
