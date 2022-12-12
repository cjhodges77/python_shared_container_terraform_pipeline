from __future__ import annotations

import json
from typing import TYPE_CHECKING

import boto3

from tests.integration import LAMBDA_ENDPOINT

if TYPE_CHECKING:
    from mypy_boto3_lambda import LambdaClient

boto3_session = boto3.Session(aws_access_key_id="abcd", aws_secret_access_key="defg", region_name="eu-west-2")  # nosec
lambda_client: LambdaClient = boto3_session.client("lambda", endpoint_url=f"http://{LAMBDA_ENDPOINT}:8080")


def test_lambda_container_invoke_returns_hello_world():
    result = lambda_client.invoke(FunctionName="function", Payload=json.dumps({"hi": "there"}))
    assert json.loads(result["Payload"].read()) == {"hello": "world"}
