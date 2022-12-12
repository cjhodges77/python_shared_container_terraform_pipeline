# Infrastructure Lambda Building Pipeline

## Introduction

This repository contains our tooling, linting rules and build pipeline helpers:

- The `buildLambda` Jenkins shared library which should be used to build Lambdas.
  Located in `vars/buildLambda.groovy`.


- The `aws-lambda-dev-base` image which contains development tooling.
  Located in `images/aws-lambda-python-dev-base`.


- The `aws-lambda-release-base` image which contains the latest patched version of Python.
  Located in `images/aws-lambda-python-release-base`.


- The `aws-lambda-container` Terraform module.
  Located in `terraform/modules/aws-lambda-container`.


- The `example-project` which shows an example of how to build a Lambda.
  Located in `example-project`.

## What's left to do/wishlist?

- Use batect bundles in example project to limit copy/paste. Make consistent updates across projects
- Improve the deployment pipeline.
  - Could we trigger smoke tests as part of the deployment?
  - Can we promote through environments?
- Decide what Jenkins role to use for updating SSM parameters/pushing images.
- Decide what mypy defaults we want.
  - Work out how to re-add `ignore_missing_imports`.
- Fix the immutable tags issue - we need a lifecycle rule.
- Retag the `test` base image and push as `latest`.
- Add Terraform linting for all Lambdas.
- Add pytest test coverage.
- Add default CloudWatch alarms for the Lambda to monitor errors.
- Provide an easier way to pull the latest dev image.

## The Build Pipeline

When the `infrastructure-pipeline-lambda-build` pipeline is triggered in Jenkins, the following happens:

1. The environment is prepared using `tonistiigi/binfmt` which allows us to build `arm64` images for our M1+ users.
2. A `test` tagged image of the dev and release images is created and pushed to ECR.
3. The `example-project` is then built using `buildLambda`.
   For this, the local version of the script used rather than the global one for testing purposes.
4. If the project is built successfully, the built images are then pushed to ECR as `latest`.
