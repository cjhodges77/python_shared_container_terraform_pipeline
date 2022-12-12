FROM ***********.dkr.ecr.eu-west-2.amazonaws.com/aws-lambda-dev-base:latest AS dev

WORKDIR ${LAMBDA_TASK_ROOT}

COPY pyproject.toml .
RUN poetry install --no-root && poetry export -o requirements.txt

COPY example example
COPY tests tests

FROM ***********.dkr.ecr.eu-west-2.amazonaws.com/aws-lambda-release-base:latest AS release

WORKDIR ${LAMBDA_TASK_ROOT}

COPY --from=dev ${LAMBDA_TASK_ROOT}/requirements.txt .
RUN pip install -r requirements.txt

COPY example example

RUN chmod -R o+rX .

# RUN python -c "import example.handler;"
CMD ["example.handler.handle"]
