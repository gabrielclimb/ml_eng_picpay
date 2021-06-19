import json
import os
from lambda_punkapi.app import app


BEER_KEYS = [
    "id",
    "name",
    "tagline",
    "first_brewed",
    "description",
    "image_url",
    "abv",
    "ibu",
    "target_fg",
    "target_og",
    "ebc",
    "srm",
    "ph",
    "attenuation_level",
    "volume",
    "boil_volume",
    "method",
    "ingredients",
    "food_pairing",
    "brewers_tips",
    "contributed_by",
]


def test_get_data_from_punkapi():
    answer = app.get_data_from_punkapi()
    assert [i for i in answer.keys()] == BEER_KEYS


def test_lambda_handler(create_infra):
    answer = app.lambda_handler("event", "context")
    beer = answer["body"]
    assert beer["name"] == "Hopped-Up Brown Ale - Prototype Challenge"
