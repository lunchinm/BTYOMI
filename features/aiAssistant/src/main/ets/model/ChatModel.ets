export enum MessageType {
  TEXT = 'text',
  OPTIONS = 'options',
  CAR_CARD = 'car_card',
  COMPARISON = 'comparison',
  LOADING = 'loading',
  ERROR = 'error'
}

export interface ErrorState {
  code: string;
  message: string;
  retryable: boolean;
  timestamp: number;
}

export interface ChatMessage {
  id: string;
  role: 'user' | 'assistant';
  type: MessageType;
  content: string;
  options?: string[];
  cars?: CarInfo[];
  comparison?: ComparisonData;
  timestamp: number;
  errorCode?: string;
  retryable?: boolean;
  metadata?: Record<string, string>;
  isStreaming?: boolean;
  recommendResults?: RecommendResult[];
}

export interface ComparisonData {
  cars: CarInfo[];
  compareFields: string[];
}

export interface ChatState {
  messages: ChatMessage[];
  isLoading: boolean;
  isStreaming: boolean;
  currentContext: UserPreferences;
  sessionId: string;
  error: ErrorState | null;
}

export interface UserPreferences {
  budgetMin: number;
  budgetMax: number;
  rangeRequirement: number;
  bodyType: string;
  powerType: string;
  naturalLanguageDescription: string;
}

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

export interface RecommendResult {
  car: CarInfo;
  score: number;
  reasons: string[];
}
