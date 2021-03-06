import json

import pytest
import requests


@pytest.fixture()
def kinesis_firehose_event():

    return {
        "invocationId": "c3cd7b51-451d-4897-86cb-c9e7b71ea362",
        "sourceKinesisStreamArn": "arn:aws:kinesis:us-east-1:700901918780:stream/kinesis_stream_data_beer",
        "deliveryStreamArn": "arn:aws:firehose:us-east-1:700901918780:deliverystream/kinesis-firehose-extended-s3-cleaned-data-beer",
        "region": "us-east-1",
        "records": [
            {
                "recordId": "49619312238026402587703325073056911068574045544789311490000000",
                "approximateArrivalTimestamp": 1623978964176,
                "data": "eyJpZCI6IDI4NywgIm5hbWUiOiAiSGVsbG8gTXkgTmFtZSBJcyBNYXJpYW5uZSIsICJ0YWdsaW5lIjogIkNhc3NpcyBJbmZ1c2VkIERvdWJsZSBJUEEuIiwgImZpcnN0X2JyZXdlZCI6ICIyMDE3IiwgImRlc2NyaXB0aW9uIjogIkJyZXdlZCBleGNsdXNpdmVseSBmb3IgdGhlIEZyZW5jaCBtYXJrZXQsIHRoaXMgSGVsbG8gTXkgTmFtZSBicmV3IGZlYXR1cmVzIGEgdHdpc3Qgb2YgZmxhdm91ciBpbnNwaXJlZCBieSBGcmFuY2UuIiwgImltYWdlX3VybCI6IG51bGwsICJhYnYiOiA4LjIsICJpYnUiOiA3MCwgInRhcmdldF9mZyI6IDEwMDksICJ0YXJnZXRfb2ciOiAxMDcwLCAiZWJjIjogMTUsICJzcm0iOiA4LCAicGgiOiA0LjQsICJhdHRlbnVhdGlvbl9sZXZlbCI6IDg3LCAidm9sdW1lIjogeyJ2YWx1ZSI6IDIwLCAidW5pdCI6ICJsaXRyZXMifSwgImJvaWxfdm9sdW1lIjogeyJ2YWx1ZSI6IDI1LCAidW5pdCI6ICJsaXRyZXMifSwgIm1ldGhvZCI6IHsibWFzaF90ZW1wIjogW3sidGVtcCI6IHsidmFsdWUiOiA2NiwgInVuaXQiOiAiY2Vsc2l1cyJ9LCAiZHVyYXRpb24iOiA2NX1dLCAiZmVybWVudGF0aW9uIjogeyJ0ZW1wIjogeyJ2YWx1ZSI6IDE5LCAidW5pdCI6ICJjZWxzaXVzIn19LCAidHdpc3QiOiBudWxsfSwgImluZ3JlZGllbnRzIjogeyJtYWx0IjogW3sibmFtZSI6ICJQYWxlIEFsZSIsICJhbW91bnQiOiB7InZhbHVlIjogNS41MiwgInVuaXQiOiAia2lsb2dyYW1zIn19LCB7Im5hbWUiOiAiQ2FyYW1hbHQiLCAiYW1vdW50IjogeyJ2YWx1ZSI6IDAuMTIsICJ1bml0IjogImtpbG9ncmFtcyJ9fV0sICJob3BzIjogW3sibmFtZSI6ICJTaW1jb2UiLCAiYW1vdW50IjogeyJ2YWx1ZSI6IDI0LCAidW5pdCI6ICJncmFtcyJ9LCAiYWRkIjogIjkwIiwgImF0dHJpYnV0ZSI6ICJCaXR0ZXJpbmcifSwgeyJuYW1lIjogIkNoaW5vb2siLCAiYW1vdW50IjogeyJ2YWx1ZSI6IDIwLCAidW5pdCI6ICJncmFtcyJ9LCAiYWRkIjogIjMwIiwgImF0dHJpYnV0ZSI6ICJGbGF2b3VyIn0sIHsibmFtZSI6ICJTaW1jb2UiLCAiYW1vdW50IjogeyJ2YWx1ZSI6IDMwLCAidW5pdCI6ICJncmFtcyJ9LCAiYWRkIjogIjAiLCAiYXR0cmlidXRlIjogIkFyb21hIn0sIHsibmFtZSI6ICJCbGFja2N1cnJhbnQgQ29uY2VudHJhdGUiLCAiYW1vdW50IjogeyJ2YWx1ZSI6IDE1MDAsICJ1bml0IjogImdyYW1zIn0sICJhZGQiOiAiRmxhbWUgT3V0IiwgImF0dHJpYnV0ZSI6ICJGbGF2b3VyIn0sIHsibmFtZSI6ICJDaXRyYSIsICJhbW91bnQiOiB7InZhbHVlIjogNDAsICJ1bml0IjogImdyYW1zIn0sICJhZGQiOiAiRHJ5IEhvcCIsICJhdHRyaWJ1dGUiOiAiQXJvbWEifSwgeyJuYW1lIjogIkNoaW5vb2siLCAiYW1vdW50IjogeyJ2YWx1ZSI6IDQwLCAidW5pdCI6ICJncmFtcyJ9LCAiYWRkIjogIkRyeSBIb3AiLCAiYXR0cmlidXRlIjogIkFyb21hIn0sIHsibmFtZSI6ICJTaW1jb2UiLCAiYW1vdW50IjogeyJ2YWx1ZSI6IDQwLCAidW5pdCI6ICJncmFtcyJ9LCAiYWRkIjogIkRyeSBIb3AiLCAiYXR0cmlidXRlIjogIkFyb21hIn0sIHsibmFtZSI6ICJDZW50ZW5uaWFsIiwgImFtb3VudCI6IHsidmFsdWUiOiAyMCwgInVuaXQiOiAiZ3JhbXMifSwgImFkZCI6ICJEcnkgSG9wIiwgImF0dHJpYnV0ZSI6ICJBcm9tYSJ9XSwgInllYXN0IjogIld5ZWFzdCAxMjcyIC0gQW1lcmljYW4gQWxlIElJXHUyMTIyIn0sICJmb29kX3BhaXJpbmciOiBbIlNtb2tlZCB2ZW5pc29uIHN0ZXciLCAiU2xvZSBnaW4gbWl4ZXIiLCAiQmxhY2sgZm9yZXN0IGdhdGVhdSJdLCAiYnJld2Vyc190aXBzIjogIlNhdmUgeW91cnNlbGYgYSBsb3Qgb2YgaGFzc2xlIGFuZCBidXkgdGhlIGJsYWNrY3VycmFudCBhcyBhIGNvbmNlbnRyYXRlIG9yIGNvcmRpYWwuIFJpYmVuYSB0aW1lISIsICJjb250cmlidXRlZF9ieSI6ICJKb2huIEplbmttYW4gPGpvaG5qZW5rbWFuPiJ9",
                "kinesisRecordMetadata": {
                    "sequenceNumber": "49619312238026402587703325073056911068574045544789311490",
                    "subsequenceNumber": 0,
                    "partitionKey": "beer_key",
                    "shardId": "shardId-000000000000",
                    "approximateArrivalTimestamp": 1623978964176,
                },
            }
        ],
    }
