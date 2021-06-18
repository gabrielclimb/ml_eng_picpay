import json

from lambda_databeer_transformation.app import app


class TestEncodeDecode:

    base64 = "dGVzdGluZw=="
    text = "testing"

    def test_encode64(self):
        assert app.encode64(self.text) == bytes(self.base64.encode("utf-8"))

    def test_decode64(self):
        assert app.decode64(self.base64) == self.text


def test_get_record_id_and_data(kinesis_firehose_event):
    record_id, data = app.get_record_id_and_data(kinesis_firehose_event)
    assert data == (
        {
            "id": 287,
            "name": "Hello My Name Is Marianne",
            "tagline": "Cassis Infused Double IPA.",
            "first_brewed": "2017",
            "description": "Brewed exclusively for the French market, this Hello My Name brew features a twist of flavour inspired by France.",
            "image_url": None,
            "abv": 8.2,
            "ibu": 70,
            "target_fg": 1009,
            "target_og": 1070,
            "ebc": 15,
            "srm": 8,
            "ph": 4.4,
            "attenuation_level": 87,
            "volume": {"value": 20, "unit": "litres"},
            "boil_volume": {"value": 25, "unit": "litres"},
            "method": {
                "mash_temp": [
                    {"temp": {"value": 66, "unit": "celsius"}, "duration": 65}
                ],
                "fermentation": {"temp": {"value": 19, "unit": "celsius"}},
                "twist": None,
            },
            "ingredients": {
                "malt": [
                    {
                        "name": "Pale Ale",
                        "amount": {"value": 5.52, "unit": "kilograms"},
                    },
                    {
                        "name": "Caramalt",
                        "amount": {"value": 0.12, "unit": "kilograms"},
                    },
                ],
                "hops": [
                    {
                        "name": "Simcoe",
                        "amount": {"value": 24, "unit": "grams"},
                        "add": "90",
                        "attribute": "Bittering",
                    },
                    {
                        "name": "Chinook",
                        "amount": {"value": 20, "unit": "grams"},
                        "add": "30",
                        "attribute": "Flavour",
                    },
                    {
                        "name": "Simcoe",
                        "amount": {"value": 30, "unit": "grams"},
                        "add": "0",
                        "attribute": "Aroma",
                    },
                    {
                        "name": "Blackcurrant Concentrate",
                        "amount": {"value": 1500, "unit": "grams"},
                        "add": "Flame Out",
                        "attribute": "Flavour",
                    },
                    {
                        "name": "Citra",
                        "amount": {"value": 40, "unit": "grams"},
                        "add": "Dry Hop",
                        "attribute": "Aroma",
                    },
                    {
                        "name": "Chinook",
                        "amount": {"value": 40, "unit": "grams"},
                        "add": "Dry Hop",
                        "attribute": "Aroma",
                    },
                    {
                        "name": "Simcoe",
                        "amount": {"value": 40, "unit": "grams"},
                        "add": "Dry Hop",
                        "attribute": "Aroma",
                    },
                    {
                        "name": "Centennial",
                        "amount": {"value": 20, "unit": "grams"},
                        "add": "Dry Hop",
                        "attribute": "Aroma",
                    },
                ],
                "yeast": "Wyeast 1272 - American Ale II™",
            },
            "food_pairing": [
                "Smoked venison stew",
                "Sloe gin mixer",
                "Black forest gateau",
            ],
            "brewers_tips": "Save yourself a lot of hassle and buy the blackcurrant as a concentrate or cordial. Ribena time!",
            "contributed_by": "John Jenkman <johnjenkman>",
        }
    )
    assert record_id == (
        "49619312238026402587703325073056911068574045544789311490000000"
    )


def test_transform_data(kinesis_firehose_event):
    _, data = app.get_record_id_and_data(kinesis_firehose_event)
    expected_tuple = [287, "Hello My Name Is Marianne", 8.2, 70, 1009, 1070, 15, 8, 4.4]
    assert app.transform_data(data) == expected_tuple

    """Extract data from dict and decode

    Args:
        event (dict): event from kinesis with data on base64

    Returns:
        dict: json from punkapi on utf-8
    """
