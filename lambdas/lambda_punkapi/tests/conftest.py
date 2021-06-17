import json

import pytest
import requests


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
    with open("lambda_punkapi/tests/files/punkapi_answer.json", "r") as f:
        text = json.loads(str(f.read()))


@pytest.fixture
def mock_response_punkapi(monkeypatch):
    def mock_get(*args, **kwargs):
        return MockResponsePunkApi()

    monkeypatch.setattr(requests, "get", mock_get)
