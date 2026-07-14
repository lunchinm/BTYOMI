import { BehaviorEvent, UserBehaviorProfile, StatsInfo, PriceRangeInfo, BodyTypeInfo,
  PowerTypeInfo, BrandPreferenceInfo, FeaturePreferenceInfo, ProfileCompletenessResult } from '../model/UserBehaviorModel';
import { preferencesUtil } from '../utils/PreferencesUtil';

const PROFILE_KEY: string = 'user_behavior_profile';

export class BehaviorTracker {
  private static instance: BehaviorTracker;

  private events: BehaviorEvent[] = [];
  private profile: UserBehaviorProfile = this.createDefaultProfile();
  private throttleTimers: Record<string, number> = {};
  private isLoaded: boolean = false;

  private constructor() {}

  public static getInstance(): BehaviorTracker {
    if (!BehaviorTracker.instance) {
      BehaviorTracker.instance = new BehaviorTracker();
    }
    return BehaviorTracker.instance;
  }

  public init(): void {
    if (this.isLoaded) {
      return;
    }
    this.loadProfile();
    this.isLoaded = true;
  }

  private createDefaultProfile(): UserBehaviorProfile {
    const priceRange: PriceRangeInfo = { preferred: '', confidence: 0 };
    const bodyType: BodyTypeInfo = { preferred: '', confidence: 0 };
    const powerType: PowerTypeInfo = { preferred: '', confidence: 0 };
    const brandPreference: BrandPreferenceInfo = { brands: [], scores: {} };
    const featurePreference: FeaturePreferenceInfo = { features: [], scores: {} };
    const stats: StatsInfo = { totalViews: 0, totalFavorites: 0, lastActiveTime: Date.now(), chatCount: 0 };
    const profile: UserBehaviorProfile = {
      priceRange: priceRange,
      bodyType: bodyType,
      powerType: powerType,
      brandPreference: brandPreference,
      featurePreference: featurePreference,
      stats: stats
    };
    return profile;
  }

  public track(event: BehaviorEvent): void {
    this.events.push(event);
    this.updateProfile(event);
    this.profile.stats.lastActiveTime = Date.now();
    this.saveProfile();
  }

  public trackWithThrottle(event: BehaviorEvent, throttleKey: string, delay: number = 200): void {
    const now = Date.now();
    if (!this.throttleTimers[throttleKey] || now - this.throttleTimers[throttleKey] > delay) {
      this.track(event);
      this.throttleTimers[throttleKey] = now;
    }
  }

  private updateProfile(event: BehaviorEvent): void {
    switch (event.eventType) {
      case 'view':
        this.profile.stats.totalViews++;
        break;
      case 'favorite_add':
        this.profile.stats.totalFavorites++;
        this.updatePreferenceFromEvent(event);
        break;
      case 'favorite_remove':
        this.profile.stats.totalFavorites = Math.max(0, this.profile.stats.totalFavorites - 1);
        break;
      case 'chat_send':
        this.profile.stats.chatCount++;
        break;
      case 'search':
        this.updatePreferenceFromEvent(event);
        break;
    }
  }

  private updatePreferenceFromEvent(event: BehaviorEvent): void {
    if (!event.extra) {
      return;
    }
    const bodyType = event.extra['bodyType'];
    if (bodyType && bodyType.length > 0) {
      this.profile.bodyType.preferred = bodyType;
      this.profile.bodyType.confidence = Math.min(1.0, this.profile.bodyType.confidence + 0.2);
    }
    const priceRange = event.extra['priceRange'];
    if (priceRange && priceRange.length > 0) {
      this.profile.priceRange.preferred = priceRange;
      this.profile.priceRange.confidence = Math.min(1.0, this.profile.priceRange.confidence + 0.2);
    }
    const powerType = event.extra['powerType'];
    if (powerType && powerType.length > 0) {
      this.profile.powerType.preferred = powerType;
      this.profile.powerType.confidence = Math.min(1.0, this.profile.powerType.confidence + 0.2);
    }
    const brand = event.extra['brand'];
    if (brand && brand.length > 0) {
      let found = false;
      for (let i = 0; i < this.profile.brandPreference.brands.length; i++) {
        if (this.profile.brandPreference.brands[i] === brand) {
          found = true;
          break;
        }
      }
      if (!found) {
        this.profile.brandPreference.brands.push(brand);
      }
      const currentScore = this.profile.brandPreference.scores[brand];
      if (currentScore !== undefined) {
        this.profile.brandPreference.scores[brand] = currentScore + 1;
      } else {
        this.profile.brandPreference.scores[brand] = 1;
      }
    }
  }

  public getProfile(): UserBehaviorProfile {
    return this.profile;
  }

  public getEvents(): BehaviorEvent[] {
    const result: BehaviorEvent[] = [];
    for (let i = 0; i < this.events.length; i++) {
      result.push(this.events[i]);
    }
    return result;
  }

  public clearProfile(): void {
    this.profile = this.createDefaultProfile();
    this.events = [];
    this.saveProfile();
  }

  public getStats(): StatsInfo {
    const stats: StatsInfo = {
      totalViews: this.profile.stats.totalViews,
      totalFavorites: this.profile.stats.totalFavorites,
      lastActiveTime: this.profile.stats.lastActiveTime,
      chatCount: this.profile.stats.chatCount
    };
    return stats;
  }

  public calculateCompleteness(): ProfileCompletenessResult {
    const weights: Record<string, number> = {
      'priceRange': 0.30,
      'bodyType': 0.25,
      'powerType': 0.20,
      'brand': 0.15,
      'feature': 0.10
    };

    const priceRangeScore: number = this.profile.priceRange.preferred.length > 0 ?
      this.profile.priceRange.confidence : 0;
    const bodyTypeScore: number = this.profile.bodyType.preferred.length > 0 ?
      this.profile.bodyType.confidence : 0;
    const powerTypeScore: number = this.profile.powerType.preferred.length > 0 ?
      this.profile.powerType.confidence : 0;
    const brandScore: number = this.profile.brandPreference.brands.length > 0 ? 0.6 : 0;
    const featureScore: number = this.profile.featurePreference.features.length > 0 ? 0.5 : 0;

    const overallScore: number = priceRangeScore * weights['priceRange'] +
      bodyTypeScore * weights['bodyType'] +
      powerTypeScore * weights['powerType'] +
      brandScore * weights['brand'] +
      featureScore * weights['feature'];

    const missingDimensions: string[] = [];
    if (priceRangeScore === 0) {
      missingDimensions.push('priceRange');
    }
    if (bodyTypeScore === 0) {
      missingDimensions.push('bodyType');
    }
    if (powerTypeScore === 0) {
      missingDimensions.push('powerType');
    }
    if (brandScore === 0) {
      missingDimensions.push('brand');
    }
    if (featureScore === 0) {
      missingDimensions.push('feature');
    }

    const shouldAskMore: boolean = overallScore < 0.5;

    const result: ProfileCompletenessResult = {
      overallScore: overallScore,
      priceRangeScore: priceRangeScore,
      bodyTypeScore: bodyTypeScore,
      powerTypeScore: powerTypeScore,
      brandScore: brandScore,
      featureScore: featureScore,
      missingDimensions: missingDimensions,
      shouldAskMore: shouldAskMore
    };
    return result;
  }

  private saveProfile(): void {
    try {
      const json = JSON.stringify(this.profile);
      preferencesUtil.putPreferencesValue(PROFILE_KEY, json);
    } catch (_e) {
    }
  }

  private loadProfile(): void {
    try {
      const json = preferencesUtil.getPreferencesValue(PROFILE_KEY, '');
      if (json && typeof json === 'string' && (json as string).length > 0) {
        const parsed = JSON.parse(json as string) as UserBehaviorProfile;
        if (parsed && parsed.stats) {
          this.profile = parsed;
        }
      }
    } catch (_e) {
    }
  }
}
