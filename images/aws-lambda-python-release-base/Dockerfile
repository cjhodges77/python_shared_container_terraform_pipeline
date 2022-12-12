ARG PYTHON_VERSION

FROM public.ecr.aws/lambda/python:${PYTHON_VERSION}

RUN yum update -y

WORKDIR ${LAMBDA_TASK_ROOT}
