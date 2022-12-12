FROM ***********.dkr.ecr.eu-west-2.amazonaws.com/aws-lambda-release-base:latest

WORKDIR /devtools

RUN yum install -y gzip make tar && \
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin && \
    pip install -U pip && \
    pip install "poetry==1.*"

COPY ["pyproject.toml", "./"]
RUN poetry config virtualenvs.create false && \
    poetry install && \
    rm poetry.lock

COPY ["Makefile", "./"]

ENTRYPOINT ["poetry"]
