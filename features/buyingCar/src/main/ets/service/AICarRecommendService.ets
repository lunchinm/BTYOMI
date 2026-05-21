import type { CarInfo, UserPreferences, RecommendResult, Question } from '../model/AICarModel';

interface BudgetRange {
  min: number;
  max: number;
}

export class AICarRecommendService {
  private static instance: AICarRecommendService;
  private carDatabase: CarInfo[] = [];
  private questions: Question[] = [];
  private isInitialized = false;

  private constructor() {}

  public static getInstance(): AICarRecommendService {
    if (!AICarRecommendService.instance) {
      AICarRecommendService.instance = new AICarRecommendService();
    }
    return AICarRecommendService.instance;
  }

  public async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    this.loadCarDatabase();
    this.loadQuestions();
    this.isInitialized = true;
  }

  private loadCarDatabase(): void {
    this.carDatabase = [
      {
        id: 1,
        brand: '比亚迪',
        model: '汉EV',
        price: 259800,
        range: 605,
        powerType: '纯电动',
        bodyType: '轿车',
        seatCount: 5,
        acceleration: 3.9,
        features: ['自动驾驶', '全景天窗', '座椅加热', 'DiLink系统'],
        score: 92,
        image: 'brand_car1',
        description: '比亚迪旗舰电动轿车，搭载刀片电池技术'
      },
      {
        id: 2,
        brand: '特斯拉',
        model: 'Model 3',
        price: 299900,
        range: 567,
        powerType: '纯电动',
        bodyType: '轿车',
        seatCount: 5,
        acceleration: 3.3,
        features: ['自动驾驶', 'OTA升级', '大屏交互', '超级充电'],
        score: 95,
        image: 'brand_car3',
        description: '特斯拉入门级轿车，智能化程度领先'
      },
      {
        id: 3,
        brand: '小鹏',
        model: 'P7',
        price: 239900,
        range: 586,
        powerType: '纯电动',
        bodyType: '轿车',
        seatCount: 5,
        acceleration: 4.3,
        features: ['XPILOT智能驾驶', '丹拿音响', 'Nappa座椅'],
        score: 88,
        image: 'brand_car1',
        description: '小鹏旗舰轿车，智能驾驶体验优秀'
      },
      {
        id: 4,
        brand: '蔚来',
        model: 'ET5',
        price: 328000,
        range: 590,
        powerType: '纯电动',
        bodyType: '轿车',
        seatCount: 5,
        acceleration: 4.3,
        features: ['NAD自动驾驶', '换电技术', '女王副驾'],
        score: 93,
        image: 'brand_car3',
        description: '蔚来中型豪华轿车，换电补能便捷'
      },
      {
        id: 5,
        brand: '理想',
        model: 'L7',
        price: 319800,
        range: 210,
        powerType: '增程式',
        bodyType: 'SUV',
        seatCount: 6,
        acceleration: 5.3,
        features: ['AD Max智驾', '冰箱大屏沙发', 'NOA导航'],
        score: 94,
        image: 'brand_car1',
        description: '理想家庭旗舰SUV，续航无焦虑'
      },
      {
        id: 6,
        brand: '问界',
        model: 'M7',
        price: 249800,
        range: 230,
        powerType: '增程式',
        bodyType: 'SUV',
        seatCount: 6,
        acceleration: 4.8,
        features: ['华为智驾', 'HarmonyOS座舱', '零重力座椅'],
        score: 91,
        image: 'brand_car3',
        description: '华为深度赋能，智能座舱体验出色'
      },
      {
        id: 7,
        brand: '比亚迪',
        model: '宋PLUS EV',
        price: 169800,
        range: 520,
        powerType: '纯电动',
        bodyType: 'SUV',
        seatCount: 5,
        acceleration: 7.9,
        features: ['DiLink 4.0', 'VTOL对外放电', '热泵空调'],
        score: 85,
        image: 'brand_car1',
        description: '紧凑型电动SUV，性价比之选'
      },
      {
        id: 8,
        brand: '大众',
        model: 'ID.3',
        price: 162800,
        range: 450,
        powerType: '纯电动',
        bodyType: '轿车',
        seatCount: 5,
        acceleration: 7.3,
        features: ['MEB平台', 'AR-HUD', 'Travel Assist'],
        score: 82,
        image: 'brand_car3',
        description: '大众纯电入门车型，品质可靠'
      }
    ];
  }

  private loadQuestions(): void {
    this.questions = [
      {
        id: 'q1',
        question: '您的购车预算是多少？',
        type: 'range',
        options: [
          { label: '15万以下', min: 0, max: 150000 },
          { label: '15-25万', min: 150000, max: 250000 },
          { label: '25-35万', min: 250000, max: 350000 },
          { label: '35万以上', min: 350000, max: 1000000 }
        ]
      },
      {
        id: 'q2',
        question: '您期望的续航里程是多少？',
        type: 'single',
        options: [
          { label: '400公里以下', value: 400 },
          { label: '400-500公里', value: 450 },
          { label: '500-600公里', value: 550 },
          { label: '600公里以上', value: 600 }
        ]
      },
      {
        id: 'q3',
        question: '您偏好什么类型的车型？',
        type: 'single',
        options: [
          { label: '轿车', value: '轿车' },
          { label: 'SUV', value: 'SUV' },
          { label: 'MPV', value: 'MPV' },
          { label: '无所谓', value: 'any' }
        ]
      },
      {
        id: 'q4',
        question: '您偏好什么动力类型？',
        type: 'single',
        options: [
          { label: '纯电动', value: '纯电动' },
          { label: '增程式', value: '增程式' },
          { label: '混合动力', value: '混合动力' },
          { label: '无所谓', value: 'any' }
        ]
      },
      {
        id: 'q5',
        question: '您关注哪些配置功能？(可多选)',
        type: 'multiple',
        options: [
          { label: '自动驾驶', value: '自动驾驶' },
          { label: '全景天窗', value: '全景天窗' },
          { label: '座椅加热/通风', value: '座椅加热' },
          { label: '大屏交互', value: '大屏交互' },
          { label: '音响系统', value: '音响' },
          { label: '快充能力', value: '超级充电' }
        ]
      }
    ];
  }

  public getQuestions(): Question[] {
    return this.questions;
  }

  public getCarList(): CarInfo[] {
    return this.carDatabase;
  }

  public getCarById(id: number): CarInfo | undefined {
    return this.carDatabase.find(car => car.id === id);
  }

  public recommend(preferences: UserPreferences): RecommendResult[] {
    const results: RecommendResult[] = [];

    for (const car of this.carDatabase) {
      const score = this.calculateScore(car, preferences);
      const reasons = this.getMatchReasons(car, preferences);
      results.push({
        car,
        score,
        reasons
      });
    }

    results.sort((a, b) => b.score - a.score);

    const highScoreResults = results.filter(r => r.score >= 90);
    
    if (highScoreResults.length >= 3) {
      return highScoreResults;
    } else {
      const remaining = 3 - highScoreResults.length;
      const otherResults = results.filter(r => r.score < 90);
      return [...highScoreResults, ...otherResults.slice(0, remaining)];
    }
  }

  private calculateScore(car: CarInfo, preferences: UserPreferences): number {
    let totalScore = 0;

    const budgetScore = this.calculateBudgetScore(car.price, preferences.budgetMin, preferences.budgetMax);
    totalScore += budgetScore * 0.3;

    const rangeScore = this.calculateRangeScore(car.range, preferences.rangeRequirement);
    totalScore += rangeScore * 0.25;

    const bodyTypeScore = this.calculateBodyTypeScore(car.bodyType, preferences.bodyType);
    totalScore += bodyTypeScore * 0.2;

    const powerTypeScore = this.calculatePowerTypeScore(car.powerType, preferences.powerType);
    totalScore += powerTypeScore * 0.15;

    const featureScore = this.calculateFeatureScore(car.features, preferences.features);
    totalScore += featureScore * 0.1;

    return Math.round(totalScore);
  }

  private calculateBudgetScore(price: number, budgetMin: number, budgetMax: number): number {
    if (budgetMin <= 0 && budgetMax <= 0) {
      return 100;
    }

    const center = budgetMin + (budgetMax - budgetMin) * 0.4;
    const sigma = (budgetMax - budgetMin) / 4;

    if (price >= budgetMin && price <= budgetMax) {
      const z = (price - center) / sigma;
      const score = Math.exp(-z * z / 2) * 100;
      return Math.round(Math.max(60, score));
    } else {
      let distance: number;
      if (price < budgetMin) {
        distance = budgetMin - price;
      } else {
        distance = price - budgetMax;
      }
      const decayRate = 50000;
      const score = Math.max(20, 100 - (distance / decayRate) * 30);
      return Math.round(score);
    }
  }

  private calculateRangeScore(range: number, requirement: number): number {
    if (requirement <= 0) {
      return 100;
    }

    if (range >= requirement) {
      const bonus = Math.min(20, Math.log(range / requirement) * 20);
      return Math.round(Math.min(100, 100 + bonus));
    } else {
      const ratio = range / requirement;
      return Math.round(ratio * 100);
    }
  }

  private calculateBodyTypeScore(carType: string, preferenceType: string): number {
    if (preferenceType === '' || preferenceType === 'any') {
      return 100;
    }
    return carType === preferenceType ? 100 : 30;
  }

  private calculatePowerTypeScore(carPower: string, preferencePower: string): number {
    if (preferencePower === '' || preferencePower === 'any') {
      return 100;
    }

    const powerMatrix: Record<string, Record<string, number>> = {
      '纯电动': { '纯电动': 100, '增程式': 60, '混合动力': 50 },
      '增程式': { '纯电动': 70, '增程式': 100, '混合动力': 60 },
      '混合动力': { '纯电动': 50, '增程式': 60, '混合动力': 100 }
    };

    return powerMatrix[preferencePower]?.[carPower] || 30;
  }

  private calculateFeatureScore(carFeatures: string[], userFeatures: string[]): number {
    if (userFeatures.length === 0) {
      return 100;
    }

    const matched = userFeatures.filter(f => carFeatures.includes(f)).length;
    const ratio = matched / userFeatures.length;
    let score = Math.round(ratio * 100);

    if (matched >= 3) {
      score += 5;
    }
    if (matched === userFeatures.length) {
      score += 10;
    }

    return Math.min(100, score);
  }

  private getMatchReasons(car: CarInfo, preferences: UserPreferences): string[] {
    const reasons: string[] = [];

    if (preferences.budgetMin > 0 && preferences.budgetMax > 0 && car.price >= preferences.budgetMin && car.price <= preferences.budgetMax) {
      reasons.push(`${car.brand}${car.model} 价格(${car.price / 10000}万)符合您的预算`);
    }

    if (preferences.rangeRequirement > 0 && car.range >= preferences.rangeRequirement) {
      reasons.push(`续航${car.range}公里，满足您的需求`);
    }

    if (preferences.bodyType !== '' && preferences.bodyType !== 'any' && car.bodyType === preferences.bodyType) {
      reasons.push(`车型为${car.bodyType}，符合您的偏好`);
    }

    if (preferences.powerType !== '' && preferences.powerType !== 'any' && car.powerType === preferences.powerType) {
      reasons.push(`动力类型为${car.powerType}，符合您的偏好`);
    }

    if (preferences.features.length > 0) {
      const matchedFeatures = preferences.features.filter(f => car.features.includes(f));
      if (matchedFeatures.length > 0) {
        reasons.push(`具备您关注的配置：${matchedFeatures.join('、')}`);
      }
    }

    return reasons;
  }

  public quickRecommend(budgetLevel: string, bodyType: string = 'any'): RecommendResult[] {
    const budgetMap: Record<string, BudgetRange> = {
      'low': { min: 0, max: 150000 } as BudgetRange,
      'medium': { min: 150000, max: 250000 } as BudgetRange,
      'high': { min: 250000, max: 350000 } as BudgetRange,
      'premium': { min: 350000, max: 1000000 } as BudgetRange
    };

    const defaultBudget: BudgetRange = { min: 0, max: 1000000 };
    const budget = budgetMap[budgetLevel] || defaultBudget;

    const preferences: UserPreferences = {
      budgetMin: budget.min,
      budgetMax: budget.max,
      rangeRequirement: 400,
      bodyType: bodyType,
      powerType: 'any',
      features: []
    };

    return this.recommend(preferences);
  }
}