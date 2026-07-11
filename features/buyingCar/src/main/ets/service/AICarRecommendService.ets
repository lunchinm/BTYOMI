import http from '@ohos.net.http';
import type {
  CarInfo,
  UserPreferences,
  RecommendResult,
  Question,
  AICarRecommendation,
  VolcengineMessage,
  VolcengineRequest,
  VolcengineResponse,
  AIResponseContent
} from '../model/AICarModel';

interface BudgetRange {
  min: number;
  max: number;
}

export class AICarRecommendService {
  private static instance: AICarRecommendService;
  private carDatabase: CarInfo[] = [];
  private questions: Question[] = [];
  private isInitialized = false;

  private readonly AI_API_URL = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';
  private readonly API_KEY = 'ark-5a920e71-a107-4956-99ca-c090c52a7811-5efaf';
  private readonly MODEL_ID = 'doubao-seed-2-0-mini-260428';

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
        question: '请用自然语言描述您的其他需求',
        type: 'text',
        placeholder: '例如：我需要一辆适合家庭使用的车，空间要大，最好有自动驾驶功能，安全性要好...'
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

  public async recommend(preferences: UserPreferences): Promise<RecommendResult[]> {
    try {
      return await this.recommendByAI(preferences);
    } catch (error) {
      console.warn('AI推荐失败，降级到本地算法:', error);
      return this.recommendByLocal(preferences);
    }
  }

  private async recommendByAI(preferences: UserPreferences): Promise<RecommendResult[]> {
    const systemPrompt = `你是一位专业的汽车推荐顾问。请根据用户提供的购车需求，推荐3款最合适的新能源汽车。

要求：
1. 严格按照以下JSON格式返回结果，不要添加任何额外的文字说明
2. 推荐3款当前市场上真实存在的新能源汽车
3. 每款车的信息要准确，包括品牌、型号、价格、续航、动力类型、车型、座位数、加速时间、主要配置和推荐理由
4. image字段请使用以下值之一：brand_car1, brand_car3

返回格式示例：
{
  "recommendations": [
    {
      "brand": "比亚迪",
      "model": "汉EV",
      "price": "25.98万",
      "range": "605公里",
      "powerType": "纯电动",
      "bodyType": "轿车",
      "seatCount": "5座",
      "acceleration": "3.9秒",
      "keyFeatures": ["自动驾驶", "全景天窗", "座椅加热", "DiLink系统"],
      "matchReason": "比亚迪旗舰电动轿车，搭载刀片电池技术，安全性高",
      "image": "brand_car1"
    }
  ]
}`;

    const userPrompt = `我的购车需求：
- 预算：${preferences.budgetMin / 10000}-${preferences.budgetMax / 10000}万
- 期望续航：${preferences.rangeRequirement}公里以上
- 车型偏好：${preferences.bodyType === 'any' ? '不限' : preferences.bodyType}
- 动力类型偏好：${preferences.powerType === 'any' ? '不限' : preferences.powerType}
- 其他需求：${preferences.naturalLanguageDescription || '无特殊要求'}

请根据以上需求推荐3款最合适的新能源汽车。`;

    const request: VolcengineRequest = {
      model: this.MODEL_ID,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ],
      temperature: 0.7,
      max_tokens: 2000,
    };

    const httpRequest = http.createHttp();
    const response = await httpRequest.request(this.AI_API_URL, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.API_KEY}`
      },
      extraData: JSON.stringify(request)
    });

    httpRequest.destroy();

    if (response.responseCode !== 200) {
      throw new Error(`API请求失败: ${response.responseCode}`);
    }

    const aiResponse: VolcengineResponse = JSON.parse(response.result as string);

    if (aiResponse.error) {
      throw new Error(`API错误: ${aiResponse.error.message}`);
    }

    if (!aiResponse.choices || aiResponse.choices.length === 0) {
      throw new Error('API返回空结果');
    }

    const content = aiResponse.choices[0].message.content;
    const parsedResult = JSON.parse(content) as AIResponseContent;

    if (!parsedResult.recommendations || !Array.isArray(parsedResult.recommendations)) {
      throw new Error('API返回格式不正确');
    }

    return this.convertAIResponseToResults(parsedResult.recommendations);
  }

  private convertAIResponseToResults(aiRecommendations: AICarRecommendation[]): RecommendResult[] {
    return aiRecommendations.map((car, index) => {
      const result: RecommendResult = {
        car,
        score: 100 - index * 5,
        reasons: [car.matchReason]
      };
      return result;
    });
  }

  private recommendByLocal(preferences: UserPreferences): RecommendResult[] {
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

    const featureScore = this.calculateFeatureScore(car.features, preferences.naturalLanguageDescription);
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

  private calculateFeatureScore(carFeatures: string[], userDescription: string): number {
    if (!userDescription || userDescription.trim() === '') {
      return 100;
    }

    let score = 80;
    const keywords = ['自动驾驶', '天窗', '座椅加热', '大屏', '音响', '快充', '智能', '安全', '空间', '家庭'];
    
    for (const keyword of keywords) {
      if (userDescription.includes(keyword) && carFeatures.some(f => f.includes(keyword))) {
        score += 5;
      }
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

    if (preferences.naturalLanguageDescription && preferences.naturalLanguageDescription.trim() !== '') {
      reasons.push('已考虑您描述的其他需求');
    }

    return reasons;
  }

  public async quickRecommend(budgetLevel: string, bodyType: string = 'any'): Promise<RecommendResult[]> {
    const budgetMap: Record<string, BudgetRange> = {
      'low': { min: 0, max: 150000 },
      'medium': { min: 150000, max: 250000 },
      'high': { min: 250000, max: 350000 },
      'premium': { min: 350000, max: 1000000 }
    };

    const defaultBudget: BudgetRange = { min: 0, max: 1000000 };
    const budget = budgetMap[budgetLevel] || defaultBudget;

    const preferences: UserPreferences = {
      budgetMin: budget.min,
      budgetMax: budget.max,
      rangeRequirement: 400,
      bodyType: bodyType,
      powerType: 'any',
      naturalLanguageDescription: ''
    };

    return this.recommend(preferences);
  }
}
