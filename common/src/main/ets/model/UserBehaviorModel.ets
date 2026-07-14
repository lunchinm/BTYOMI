export interface PriceRangeInfo {
  preferred: string;
  confidence: number;
}

export interface BodyTypeInfo {
  preferred: string;
  confidence: number;
}

export interface PowerTypeInfo {
  preferred: string;
  confidence: number;
}

export interface BrandPreferenceInfo {
  brands: string[];
  scores: Record<string, number>;
}

export interface FeaturePreferenceInfo {
  features: string[];
  scores: Record<string, number>;
}

export interface StatsInfo {
  totalViews: number;
  totalFavorites: number;
  lastActiveTime: number;
  chatCount: number;
}

export interface ProfileCompletenessResult {
  overallScore: number;
  priceRangeScore: number;
  bodyTypeScore: number;
  powerTypeScore: number;
  brandScore: number;
  featureScore: number;
  missingDimensions: string[];
  shouldAskMore: boolean;
}

export interface UserBehaviorProfile {
  priceRange: PriceRangeInfo;
  bodyType: BodyTypeInfo;
  powerType: PowerTypeInfo;
  brandPreference: BrandPreferenceInfo;
  featurePreference: FeaturePreferenceInfo;
  stats: StatsInfo;
}

export interface BehaviorEvent {
  eventType: string;
  targetId: string;
  targetType: string;
  timestamp: number;
  pageName: string;
  extra?: Record<string, string>;
}

export class ErrorCodes {
  public static readonly NETWORK_ERROR: string = 'NETWORK_ERROR';
  public static readonly API_TIMEOUT: string = 'API_TIMEOUT';
  public static readonly API_ERROR: string = 'API_ERROR';
  public static readonly PARSE_ERROR: string = 'PARSE_ERROR';
}

export interface DegradationTriggerInfo {
  autoDegrade: boolean;
  message: string;
}

export class DegradationTriggers {
  public static readonly NETWORK_UNAVAILABLE: DegradationTriggerInfo = {
    autoDegrade: true, message: '网络异常，已切换到本地模式'
  } as DegradationTriggerInfo;
  public static readonly API_TIMEOUT: DegradationTriggerInfo = {
    autoDegrade: true, message: '连接超时，已切换到本地模式'
  } as DegradationTriggerInfo;
  public static readonly API_5XX: DegradationTriggerInfo = {
    autoDegrade: true, message: '服务繁忙，已切换到本地模式'
  } as DegradationTriggerInfo;
  public static readonly RETRY_FAILED: DegradationTriggerInfo = {
    autoDegrade: true, message: '连接失败，已切换到本地模式'
  } as DegradationTriggerInfo;
  public static readonly MANUAL_OFFLINE: DegradationTriggerInfo = {
    autoDegrade: true, message: '已切换到本地模式'
  } as DegradationTriggerInfo;
}
