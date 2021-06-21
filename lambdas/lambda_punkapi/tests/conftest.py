import os
import json

import pytest
import requests
import boto3
import moto


@pytest.fixture()
def cloudwatch_event():
    """Generates API GW Event"""

    return {
        "id": "53dc4d37-cffa-4f76-80c9-8b7d4a4d2eaa",
        "detail-type": "Scheduled Event",
        "source": "aws.events",
        "account": "123456789012",
        "time": "2019-10-08T16:53:06Z",
        "region": "us-east-1",
        "resources": ["arn:aws:events:us-east-1:123456789012:rule/MyScheduledRule"],
        "detail": {},
    }


class Response:
    def raise_for_status(self):
        pass


class MockResponsePunkApi(Response):
    with open("lambdas/lambda_punkapi/tests/files/punkapi_answer.json", "r") as f:
        text = json.loads(str(f.read()))

    def json(self):
        return self.text


@pytest.fixture(autouse=True)
def mock_response_punkapi(monkeypatch):
    def mock_get(*args, **kwargs):
        return MockResponsePunkApi()

    monkeypatch.setattr(requests, "get", mock_get)


@pytest.fixture(autouse=True)
def lambda_enviroment_variables():
    os.environ["URL_PUNKAPI"] = "testing"
    os.environ["STREAM_NAME"] = "testing"


@pytest.fixture(scope="function")
def aws_enviroment_variables():
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"


@pytest.fixture
def create_infra(aws_enviroment_variables):
    with moto.mock_kinesis():
        conn = boto3.client("kinesis")
        stream_name = "testing"
        conn.create_stream(StreamName=stream_name, ShardCount=1)
        yield
