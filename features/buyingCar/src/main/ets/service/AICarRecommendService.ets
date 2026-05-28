import http from '@ohos.net.http';
import type {
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
  private questions: Question[] = [];
  private isInitialized = false;

  // 火山方舟API配置
  private readonly AI_API_URL = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';
  private readonly API_KEY = 'ark-5a920e71-a107-4956-99ca-c090c52a7811-5efaf'; // 您的API Key
  private readonly MODEL_ID = 'doubao-seed-2-0-mini-260428'; // 替换为您实际部署的模型ID

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
    this.loadQuestions();
    this.isInitialized = true;
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

  /**
   * 调用火山方舟大模型API进行推荐
   * @param preferences 用户偏好
   * @returns 推荐结果
   */
  public async recommend(preferences: UserPreferences): Promise<RecommendResult[]> {
    try {
      // 构建系统提示词
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

      // 构建用户提示词
      const userPrompt = `我的购车需求：
- 预算：${preferences.budgetMin / 10000}-${preferences.budgetMax / 10000}万
- 期望续航：${preferences.rangeRequirement}公里以上
- 车型偏好：${preferences.bodyType === 'any_3' ? '不限' : preferences.bodyType}
- 动力类型偏好：${preferences.powerType === 'any_4' ? '不限' : preferences.powerType}
- 其他需求：${preferences.naturalLanguageDescription || '无特殊要求'}

请根据以上需求推荐3款最合适的新能源汽车。`;

      // 构建API请求
      const request: VolcengineRequest = {
        model: this.MODEL_ID,
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        temperature: 0.7,
        max_tokens: 2000,
      };

      // 调用火山方舟API（使用官方http模块）
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

      // 解析AI返回的JSON
      const content = aiResponse.choices[0].message.content;
      const parsedResult = JSON.parse(content) as AIResponseContent;

      if (!parsedResult.recommendations || !Array.isArray(parsedResult.recommendations)) {
        throw new Error('API返回格式不正确');
      }

      // 转换为推荐结果格式
      return this.convertAIResponseToResults(parsedResult.recommendations);
    } catch (error) {
      console.error('AI推荐出错:', error);
      // 直接抛出错误，让UI层处理，不再返回默认结果
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`未知错误: ${String(error)}`);
      }
    }
  }

  /**
   * 转换AI响应为推荐结果格式
   */
  private convertAIResponseToResults(aiRecommendations: AICarRecommendation[]): RecommendResult[] {
    return aiRecommendations.map((car, index) => {
      const result: RecommendResult = {
        car,
        score: 100 - index * 5, // 按推荐顺序给分
        reasons: [car.matchReason]
      };
      return result;
    });
  }

  /**
   * 快速推荐（保留接口兼容）
   */
  public async quickRecommend(budgetLevel: string, bodyType: string = 'any_3'): Promise<RecommendResult[]> {
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
      powerType: 'any_4',
      naturalLanguageDescription: ''
    };

    return this.recommend(preferences);
  }
}
