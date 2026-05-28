export interface CarInfo {
  id: number;
  brand: string;
  model: string;
  price: number;
  range: number;
  powerType: string;
  bodyType: string;
  seatCount: number;
  acceleration: number;
  features: string[];
  score: number;
  image: string;
  description: string;
}

export interface AICarRecommendation {
  brand: string;
  model: string;
  price: string;
  range: string;
  powerType: string;
  bodyType: string;
  seatCount: string;
  acceleration: string;
  keyFeatures: string[];
  matchReason: string;
  image: string;
}

export interface CarDatabase {
  version: string;
  updateTime: string;
  cars: CarInfo[];
}

export interface RecommendRule {
  id: string;
  name: string;
  description: string;
  weight: number;
  conditions: RuleCondition[];
}

export interface RuleCondition {
  type: string;
  field: string;
  operator?: string;
  valueField?: string;
  minField?: string;
  maxField?: string;
  value?: number | string;
}

export interface QuestionOption {
  label: string;
  value?: number | string;
  min?: number;
  max?: number;
}

export interface Question {
  id: string;
  question: string;
  type: string;
  options?: QuestionOption[];
  placeholder?: string;
}

export interface RecommendRules {
  version: string;
  rules: RecommendRule[];
  questions: Question[];
}

export interface UserPreferences {
  budgetMin: number;
  budgetMax: number;
  rangeRequirement: number;
  bodyType: string;
  powerType: string;
  naturalLanguageDescription: string;
}

export interface RecommendResult {
  car: CarInfo | AICarRecommendation;
  score: number;
  reasons: string[];
}

export interface AIRecommendResponse {
  success: boolean;
  message: string;
  results: RecommendResult[];
  preferences: UserPreferences;
}

export interface VolcengineMessage {
  role: string;
  content: string;
}

export interface VolcengineUsage {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
}

export interface VolcengineError {
  message: string;
  type: string;
  code: string;
}

export interface VolcengineChoice {
  message: VolcengineMessage;
  finish_reason: string;
  index: number;
}

export interface VolcengineResponseFormat {
  type: string;
}

export interface VolcengineRequest {
  model: string;
  messages: VolcengineMessage[];
  temperature?: number;
  max_tokens?: number;
  response_format?: VolcengineResponseFormat;
}

export interface VolcengineResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: VolcengineChoice[];
  usage: VolcengineUsage;
  error?: VolcengineError;
}

export interface AIResponseContent {
  recommendations: AICarRecommendation[];
}
