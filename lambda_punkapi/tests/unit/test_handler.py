import json

from hello_world import app


def test_get_data_from_punkapi(mock_response_punkapi):
    answer = app.get_data_from_punkapi()
    assert [i for i in answer.keys()] == [
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


def test_lambda_handler(apigw_event, mocker):
    # TODO: Ajustar esse teste
    ret = app.lambda_handler(apigw_event, "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 200
    assert "message" in ret["body"]
    assert data["message"] == "hello world"
