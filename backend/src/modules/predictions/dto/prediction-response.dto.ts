export interface PredictionPointDto {
  date: string;
  predictedBalance: number;
  lowerBound: number;
  upperBound: number;
}

export interface PredictionResponseDto {
  predictions: PredictionPointDto[];
  currentBalance: number;
  confidence: number;
}

export interface ChatPredictionResponseDto {
  answer: string;
  predictions?: PredictionPointDto[] | null;
}
