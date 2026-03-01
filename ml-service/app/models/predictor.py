import logging
from typing import List, Dict, Optional
from datetime import datetime, timedelta, date

import pandas as pd
from prophet import Prophet

from app.config import settings

logger = logging.getLogger(__name__)


class BalancePredictor:
    """Prophet-based financial balance predictor."""

    def __init__(self):
        self.model: Optional[Prophet] = None
        self._is_trained = False
        self._last_balance = 0.0

    def train(self, transactions: List[dict], current_balance: float = 0.0) -> bool:
        """
        Train the model on historical transaction data.

        Args:
            transactions: List of dicts with 'date', 'amount', 'type' keys.
            current_balance: The current account balance.

        Returns:
            True if training succeeded, False otherwise.
        """
        self._last_balance = current_balance

        if len(transactions) < settings.MIN_DATA_POINTS:
            logger.warning(
                f"Not enough data points ({len(transactions)}), "
                f"need at least {settings.MIN_DATA_POINTS}"
            )
            self._is_trained = False
            return False

        try:
            df = self._prepare_data(transactions)

            if df.empty or df["y"].abs().sum() == 0:
                logger.warning("All transaction amounts are zero or data is empty")
                self._is_trained = False
                return False

            self.model = Prophet(
                daily_seasonality=False,
                weekly_seasonality=True,
                yearly_seasonality=True,
                changepoint_prior_scale=0.05,
                interval_width=0.80,
            )

            self.model.fit(df)
            self._is_trained = True
            return True

        except Exception as e:
            logger.error(f"Training failed: {e}")
            self._is_trained = False
            return False

    def predict(self, days_ahead: int = 30) -> List[dict]:
        """
        Predict daily balance changes for N days ahead.

        Args:
            days_ahead: Number of days to forecast.

        Returns:
            List of dicts with date, predictedBalance, lowerBound, upperBound.
        """
        if not self._is_trained or self.model is None:
            return self._fallback_predict(days_ahead)

        try:
            future = self.model.make_future_dataframe(periods=days_ahead)
            forecast = self.model.predict(future)

            # Take only the future predictions
            future_forecast = forecast.tail(days_ahead)

            results = []
            cumulative_balance = self._last_balance

            for _, row in future_forecast.iterrows():
                daily_change = float(row["yhat"])
                lower_change = float(row["yhat_lower"])
                upper_change = float(row["yhat_upper"])

                cumulative_balance += daily_change

                results.append({
                    "date": row["ds"].strftime("%Y-%m-%d"),
                    "predictedBalance": round(cumulative_balance, 2),
                    "lowerBound": round(
                        cumulative_balance + (lower_change - daily_change), 2
                    ),
                    "upperBound": round(
                        cumulative_balance + (upper_change - daily_change), 2
                    ),
                })

            return results

        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            return self._fallback_predict(days_ahead)

    def predict_date(self, target_date: date) -> float:
        """Predict balance for a specific date."""
        today = date.today()
        days_ahead = (target_date - today).days

        if days_ahead <= 0:
            return self._last_balance

        predictions = self.predict(days_ahead)
        if predictions:
            return predictions[-1]["predictedBalance"]
        return self._last_balance

    def _prepare_data(self, transactions: List[dict]) -> pd.DataFrame:
        """
        Convert transactions to Prophet-compatible DataFrame.
        Groups by date and calculates net daily change (income - expense).
        """
        records = []
        for tx in transactions:
            amount = float(tx["amount"])
            if tx.get("type") == "expense":
                amount = -amount
            records.append({
                "ds": pd.to_datetime(tx["date"]),
                "y": amount,
            })

        df = pd.DataFrame(records)

        if df.empty:
            return df

        # Group by date and sum net daily changes
        df = df.groupby("ds", as_index=False).agg({"y": "sum"})

        # Fill missing dates with 0
        date_range = pd.date_range(start=df["ds"].min(), end=df["ds"].max(), freq="D")
        full_df = pd.DataFrame({"ds": date_range})
        df = full_df.merge(df, on="ds", how="left").fillna(0)

        return df

    def _fallback_predict(self, days_ahead: int) -> List[dict]:
        """
        Simple linear fallback when Prophet cannot be used.
        Returns flat prediction at current balance.
        """
        results = []
        today = date.today()

        for i in range(1, days_ahead + 1):
            future_date = today + timedelta(days=i)
            results.append({
                "date": future_date.strftime("%Y-%m-%d"),
                "predictedBalance": round(self._last_balance, 2),
                "lowerBound": round(self._last_balance * 0.9, 2),
                "upperBound": round(self._last_balance * 1.1, 2),
            })

        return results
