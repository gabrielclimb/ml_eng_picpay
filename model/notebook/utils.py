from time import sleep

import boto3
import pandas as pd
import requests as r


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


def get_data_from_table() -> pd.DataFrame:
    """Get beer data from a table using glue

    Returns:
        pd.DataFrame: dataframe with data
    """
    client = boto3.client("athena")

    queryStart = client.start_query_execution(
        QueryString='SELECT * FROM "db_beer"."table_data_beer";',
        QueryExecutionContext={"Database": "db_beer"},
        ResultConfiguration={"OutputLocation": "s3://picpay-athena-query-result/"},
    )

    query_execution = client.get_query_execution(
        QueryExecutionId=queryStart["QueryExecutionId"]
    )
    s3_path = query_execution["QueryExecution"]["ResultConfiguration"]["OutputLocation"]

    return pd.read_csv(s3_path)


def get_data_from_api() -> pd.DataFrame:
    beers = []
    for i in range(1, 100):
        sleep(1)
        ans = r.get(f"https://api.punkapi.com/v2/beers?page={i}&per_page=80")
        if len(ans.json()) == 0:
            break
        for beer in ans.json():
            beers.append(transform_data(beer))
    return pd.DataFrame(
        beers,
        columns=[
            "id",
            "name",
            "abv",
            "ibu",
            "target_fg",
            "target_og",
            "ebc",
            "srm",
            "ph",
        ],
    )
