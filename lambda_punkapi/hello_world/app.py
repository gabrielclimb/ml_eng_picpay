import json
import logging
import os

import boto3
import requests as r

log = logging.getLogger()
log.setLevel(logging.INFO)

PUNKAPI_URL = os.getenv['PUNKAPI_URL']
kinesis_client = boto3.client('kinesis')


def get_data_from_punkapi() -> dict:
    """get data from punkapi random endpoint

    Raises:
        r.exceptions.HTTPError: if request get a error, status code
        will be different of 200 and a http erro will rise

    Returns:
        dict: a dict with a random beer 
    """    
    try:
        answer = r.get(PUNKAPI_URL)
        answer.raise_for_status()
    except r.exceptions.HTTPError as error:
        log.error(f"HTTPerror: {error}")
        raise r.exceptions.HTTPError
    return answer.json()[0]


def push_to_kinesis(beer:dict) -> None:
    try:
        log.info("Sending beer data to kinesis.")
        _ = kinesis_client.put_record(
            StreamName = '',
            Data=bytes(beer),
            PartitionKey='',
            )
    except:
        log.error('')
        ...


def lambda_handler(event, context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """

    beer = get_data_from_punkapi()
    push_to_kinesis(beer)

    return {
        "statusCode": 200,
        "body": beer
    }
