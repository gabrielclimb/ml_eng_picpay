import os

import boto3
import argparse
import lightgbm as lgb
import pandas as pd
from scipy.stats import randint, uniform
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.model_selection import RandomizedSearchCV, train_test_split

from utils import get_data_from_table
from server.feature_engineering import ale_or_pilsen, ebc_to_group, group_ph


def feature_engineering(dataframe: pd.DataFrame) -> pd.DataFrame:
    dataframe["type"] = dataframe.name.apply(ale_or_pilsen).astype("category")
    dataframe["color_group"] = dataframe.ebc.apply(ebc_to_group).astype("category")
    dataframe["ph_group"] = dataframe.ph.apply(group_ph).astype("category")
    return df_beer


def train_model_lgb(
    X_train: pd.DataFrame, X_test: pd.DataFrame, y_train: pd.Series, y_test: pd.Series
):

    grid_params = {
        "colsample_bytree": 1.0,
        "importance_type": ["gain", "split"],
        "max_depth": [5, 10, 20, 30, 40],
        "min_child_samples": [10, 20, 30, 40],
        "min_child_weight": [0.001],
        "min_split_gain": [0.001],
        "n_estimators": [100, 200, 300, 400, 500],
        "num_leaves": [20, 30, 40],
        "random_state": [42],
        "reg_alpha": [0.01],
        "reg_lambda": [0.01],
        "subsample": [0.1, 0.2, 0.5, 1.0],
        "subsample_for_bin": [5000, 10000, 200000],
        "subsample_freq": [0, 1],
        "num_leaves": randint(6, 50),
        "min_data": [1, 2, 4, 8, 10],
        "learning_rate": [0.9],
        "min_child_samples": randint(10, 500),
        "boosting_type": ["gbdt"],
        "subsample": uniform(loc=0.2, scale=0.8),
        "colsample_bytree": uniform(loc=0.4, scale=0.6),
        "bagging_fraction": [0.2, 0.4, 0.6, 0.8],
    }

    lgb_regressor = lgb.LGBMRegressor(objective="regression", silent=True)

    model = RandomizedSearchCV(
        estimator=lgb_regressor,
        param_distributions=grid_params,
        n_iter=100,
        scoring="neg_root_mean_squared_error",
        cv=3,
        n_jobs=-1,
        refit=True,
        random_state=42,
        verbose=False,
    )

    model.fit(
        X_train,
        y_train,
        eval_metric="rmse",
        eval_set=(X_test, y_test),
        early_stopping_rounds=50,
    )

    return model


def bentoml_model_pack(model, version: str) -> None:
    # Produtização

    try:
        os.environ["BENTOML_HOME"]
    except KeyError:
        print(f"{os.getcwd()}/bentoml")
        os.environ["BENTOML_HOME"] = f"{os.getcwd()}/bentoml"

    bento_service = BeerPredictionService()
    bento_service.pack("model", model)
    bento_service.save(version=version)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--version",
        action="store",
        required=True,
        help="Model Version",
    )
    args = parser.parse_args()

    df_beer = get_data_from_table()
    df_beer = df_beer.drop(columns=["id"]).dropna()

    df_beer = feature_engineering(df_beer)
    df_beer = df_beer.drop(columns=["name"])

    X = df_beer.drop(columns=["ibu"])
    y = df_beer.ibu

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.3,
        random_state=42,
    )

    # Lightgbm
    model = train_model_lgb(X_train, X_test, y_train, y_test)

    y_pred_tunning_lgb = model.predict(X_test)

    print(
        f"LightgbmRegressor\nRMSE={mean_squared_error(y_test, y_pred_tunning_lgb, squared=False)}\nMAE={mean_absolute_error(y_test, y_pred_tunning_lgb)}\n"
    )
    print("Packing model")
    bentoml_model_pack(model, args.version)
