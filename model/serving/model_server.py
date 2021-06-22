import bentoml
import lightgbm as lgb
import pandas as pd
from bentoml.adapters import DataframeInput
from bentoml.frameworks.sklearn import SklearnModelArtifact

from feature_engineering import ale_or_pilsen, ebc_to_group, group_ph


@bentoml.artifacts([SklearnModelArtifact("model")])
@bentoml.env(pip_dependencies=["lightgbm", "pandas"])
class BeerPredictionService(bentoml.BentoService):
    @bentoml.api(input=DataframeInput(), batch=True)
    def predict(self, df_beer: pd.DataFrame):
        """
        Predict IBU value
        POST ex: [{"name": "ale", "abv": 9.0, "target_fg": 1025.0,
                  "target_og": 1094.0, "ebc": 400.0, "srm": 200.0, "ph": 4.3}]
        """
        print("Dataframe", df_beer)
        df_beer = df_beer[["name", "abv", "target_fg", "target_og", "ebc", "srm", "ph"]]
        df_beer["type"] = df_beer.name.apply(ale_or_pilsen).astype("category")
        df_beer["color_group"] = df_beer.ebc.apply(ebc_to_group).astype("category")
        df_beer["ph_group"] = df_beer.ph.apply(group_ph).astype("category")

        data = df_beer[
            [
                "abv",
                "target_fg",
                "target_og",
                "ebc",
                "srm",
                "ph",
                "type",
                "color_group",
                "ph_group",
            ]
        ]

        return self.artifacts.model.predict(data)
