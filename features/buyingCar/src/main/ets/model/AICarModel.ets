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
  options: QuestionOption[];
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
  features: string[];
}

export interface RecommendResult {
  car: CarInfo;
  score: number;
  reasons: string[];
}

export interface AIRecommendResponse {
  success: boolean;
  message: string;
  results: RecommendResult[];
  preferences: UserPreferences;
}