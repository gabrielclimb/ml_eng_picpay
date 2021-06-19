import base64
import csv
import json
import logging
from io import StringIO
from typing import Tuple

log = logging.getLogger()
log.setLevel(logging.INFO)


def encode64(data: str) -> bytes:
    return base64.b64encode(str(data).encode("utf-8"))


def decode64(data: str) -> str:
    return base64.b64decode(data).decode("utf-8")


def get_record_id_and_data(event: dict) -> Tuple[str, dict]:
    """Extract record id and data from dict and decode

    Args:
        event (dict): json send by kinesis with data beer

    Returns:
        Tuple[str, dict]: record id and beer information
    """
    for record in event["records"]:
        record_id = record["recordId"]
        data = json.loads(decode64(record["data"]))
    return record_id, data


def transform_data(data: dict) -> list:
    """Transform data in dict to a list

    Args:
        data (dict): beer data

    Returns:
        list: all fields from dict i want
    """
    return [
        data["id"],
        data["name"],
        data["abv"],
        data["ibu"],
        data["target_fg"],
        data["target_og"],
        data["ebc"],
        data["srm"],
        data["ph"],
    ]


def transform_to_csv(row: list) -> str:
    """get a matrix and returns a string in csv format

    Args:
        row (list): a matrix ([[]])

    Returns:
        str: csv file as string
    """
    output = StringIO()
    writer = csv.writer(output, delimiter=",")
    writer.writerows(row)
    return output.getvalue()


def lambda_handler(event, context):
    try:
        record_id, data = get_record_id_and_data(event)
        row = transform_data(data)
        output = transform_to_csv([row])
    except Exception as e:
        log.error(f"Error: {e}")
        raise e

    answer = [
        {
            "recordId": record_id,
            "result": "Ok",
            "data": encode64(str(output)),
        }
    ]
    return {"records": answer}
