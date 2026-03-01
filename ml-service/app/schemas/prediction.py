from typing import Optional, List
from datetime import date
from pydantic import BaseModel, Field


class TransactionData(BaseModel):
    date: str
    amount: float
    type: str  # "income" or "expense"


class ScheduledPaymentData(BaseModel):
    name: str
    amount: float
    type: str  # "income" or "expense"
    frequency: str
    nextExecutionDate: str


class PredictionPoint(BaseModel):
    date: str
    predictedBalance: float
    lowerBound: float
    upperBound: float


class PredictionRequest(BaseModel):
    userId: str
    accountId: Optional[str] = None
    targetDate: Optional[str] = None
    daysAhead: int = Field(default=30, ge=1, le=365)
    transactions: List[TransactionData] = []
    currentBalance: float = 0.0


class PredictionResponse(BaseModel):
    predictions: List[PredictionPoint]
    currentBalance: float
    confidence: float


class ChatPredictionRequest(BaseModel):
    userId: str
    question: str
    transactions: List[TransactionData] = []
    currentBalance: float = 0.0
    scheduledPayments: List[ScheduledPaymentData] = []


class ChatPredictionResponse(BaseModel):
    answer: str
    predictions: Optional[List[PredictionPoint]] = None
