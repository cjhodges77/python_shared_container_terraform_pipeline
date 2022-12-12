# Example Project

Hello, I am your example project to get you started with building a Lambda in a container.

## Getting Started

You can, if you want, copy this project entirely or just use it as a template.

I was created with `poetry new <lambda-name>`.

You need the following installed:

- Docker
- poetry
- pyenv

## Project Structure

| Location       | Description                                                                     |
|----------------|---------------------------------------------------------------------------------|
| example/       | The code for the Lambda is contained in `example`, the name of the module.      |
| terraform/     | Terraform module for deployment.                 |
| tests/         | Integration and unit tests.                                                     |
| Dockerfle      | The Docker commands required to build a test and release version of the Lambda. |
| Makefile       | The commands required by the `buildLambda` function, plus others.               |
| batect.yml     | The batect configuration for running the lambda and tests.                      |
| pyproject.toml | The Python project configuration, including Poetry dependencies.                |


## Building the Lambda and running the tests

### Building the Image

You will need to authenticate with the management account to be able to pull the base images, e.g:
`aws-vault exec myEngineerRole -- aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin ************.dkr.ecr.eu-west-2.amazonaws.com`

The Lambda can be built with `make build TAG=example-project`.
This will build a Docker image which is tagged with `example-project`.

### Linting and Security Tests

The linting and security tests are provided by the `aws-lambda-dev-base` image.

They can be ran via Docker with `make test-lint`, which invokes the `make lint` command in `/devtools/Makefile`.

### Unit Tests

Run the unit tests via your IDE or with Docker by `make test-unit`.

### Integration Tests

To run the integration tests via your IDE you need to start the Lambda locally.
This can be performed by running `make lambda-local` which starts the Lambda on port `8080`.
You can then run the tests normally via your IDE.

Alternatively, run `make test-integration` which will start the Lambda and run the integration tests for you in Docker.

## Building and Deploying the Lambda

The `buildLambda` Jenkins function takes care of building, testing and pushing the Lambda to ECR.

### Terraform

```
module "lambda" {
  count  = var.environment == "integration" ? 1 : 0
  source = "git::ssh://git@github.com/cjhodges77/python_shared_container_terraform_pipeline/example-project/terraform?depth=1"

  account_engineering_boundary            = lookup(var.account_engineer_boundaries, data.aws_caller_identity.current.account_id, "")
  component                               = "aws-lambda-example-project"
  environment                             = var.environment
  image_tag                               = data.aws_ssm_parameter.latest_image_tag.value
  lambda_git_repo                         = "https://github.com/cjhodges77/python_shared_container_terraform_pipeline/tree/main/example-project"
  log_subscription_filter_destination_arn = data.terraform_remote_state.log_handler.outputs.log_handler_arn
}
```

## Dockerfile Structure

The Dockerfile contains both the `dev` (test) stage and a `release` stage.

### Stage: dev

In the `dev` stage, it bases the image from `aws-lambda-dev-base` which contains linting and security tooling.

It copies in the `pyproject.toml` which contains the Poetry dependencies and exports a `requirements.txt` which is used by the
release stage to install locked production dependencies that the Lambda was tested with at the time.

Finally, the Python package `example` and the `tests` are copied in to the image.

### Stage: release

In the `release` stage, it bases the image from `aws-lambda-release-base` which contains a patched version of Python.

It installs the production dependencies via pip from the `requirements.txt` generated in the `dev` stage.

It then copies the Python package `example` and makes it executable.

Finally, it tests whether it can import the `example` handler file and then sets the handler endpoint that Lambda will execute.

## batect.yml

The batect file contains three containers:

| Name         | Description                                                                         |
|--------------|-------------------------------------------------------------------------------------|
| lambda       | The Lambda container using the `release` stage.                                     |
| lambda-local | A copy of the `lambda` container with the port exposed for local integration tests. |
| test         | The test container using the `dev` stage.                                           |

And it contains the following tasks:

| Name             | Description                                                                                         |
|------------------|-----------------------------------------------------------------------------------------------------|
| lambda-local     | Starts the `lambda-local` container for integration testing via your IDE.                           |
| test-integration | Starts the `lambda` container and then runs `poetry run tests/integration` in the `test` container. |
| test-lint        | Starts the `test` container and runs `make lint` in the `/devtools` folder.                         |
| test-unit        | Starts the `test` container and runs `poetry run tests/unit`.                                       |

## Invoking the Lambda

The Lambda can be invoked locally when started with `make lambda-local`.
You can then POST to the Lambda:

`curl -XPOST 'http://localhost:8080/2015-03-31/functions/function/invocations' -d '{"hello": "world"}'`
