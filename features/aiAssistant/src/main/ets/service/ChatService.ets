import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import { ChatMessage, MessageType, CarInfo, ComparisonData, ChatState, ErrorState, RecommendResult, UserPreferences } from '../model/ChatModel';
import { ErrorCodes, UserBehaviorProfile, DegradationTriggers, ProfileCompletenessResult, BehaviorTracker, BehaviorEvent } from '@ohos/common';
import { ChatHistoryManager } from './ChatHistoryManager';
import { NetworkMonitor } from './NetworkMonitor';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export interface QuestionResponse {
  content: string;
  options: string[];
}

interface ChatMessageForAPI {
  role: string;
  content: string;
}

interface APIRequest {
  model: string;
  messages: ChatMessageForAPI[];
  temperature: number;
  max_tokens: number;
  stream: boolean;
}

interface APIChoice {
  message: ChatMessageForAPI;
  delta: ChatMessageForAPI;
}

interface APIResponse {
  choices: APIChoice[];
  error?: string;
}

interface StreamChunk {
  choices: StreamChoice[];
}

interface StreamChoice {
  delta: StreamDelta;
  finish_reason: string;
}

interface StreamDelta {
  content: string;
  role: string;
}

interface BudgetRange {
  min: number;
  max: number;
}

export class ChatService {
  private static instance: ChatService;
  private readonly LOG_DOMAIN: number = 0xF011;
  private readonly LOG_TAG: string = 'ChatService';

  private messages: ChatMessage[] = [];
  private sessionId: string = '';
  private isDegraded: boolean = false;
  private retryCount: number = 0;
  private readonly MAX_RETRY: number = 3;
  private isLoading: boolean = false;
  private isStreamingActive: boolean = false;
  private currentRequest: http.HttpRequest | null = null;
  private behaviorTracker: BehaviorTracker = BehaviorTracker.getInstance();
  private chatHistory: ChatHistoryManager = ChatHistoryManager.getInstance();
  private networkMonitor: NetworkMonitor = NetworkMonitor.getInstance();
  private streamingMessageId: string = '';

  private readonly AI_API_URL: string = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';
  private readonly API_KEY: string = 'ark-5a920e71-a107-4956-99ca-c090c52a7811-5efaf';
  private readonly MODEL_ID: string = 'doubao-seed-2-0-mini-260428';
  private readonly PRIVACY_KEY: string = 'ai_privacy_accepted';
  private readonly KNOWN_CARS: string[] = [
    '比亚迪汉EV', '比亚迪汉', '特斯拉Model 3', '特斯拉Model Y',
    '小鹏P7', '小鹏G6', '蔚来ET5', '蔚来ES6',
    '理想L7', '理想L6', '问界M7', '问界M5',
    '比亚迪宋PLUS', '比亚迪宋', '大众ID.3', '大众ID.4',
    '比亚迪秦PLUS', '比亚迪秦', '特斯拉Model S', '特斯拉Model X',
    '小鹏G9', '蔚来EC6', '理想L9', '理想L8',
    '问界M9', '极氪001', '极氪007', '智界S7',
    '小米SU7', '极狐阿尔法S', '飞凡R7', '阿维塔11',
    '岚图FREE', '岚图梦想家', '智己L7', '哪吒S',
    '零跑C11', '零跑C01', '埃安AION S', '埃安AION Y'
  ];

  private readonly CAR_DATABASE: CarInfo[] = [
    { id: 1, brand: '比亚迪', model: '汉EV', price: 259800, range: 605, powerType: '纯电动', bodyType: '轿车', seatCount: 5, acceleration: 3.9, features: ['自动驾驶', '全景天窗', '座椅加热', 'DiLink系统'], score: 92, image: 'brand_car1', description: '比亚迪旗舰电动轿车，搭载刀片电池技术' },
    { id: 2, brand: '特斯拉', model: 'Model 3', price: 299900, range: 567, powerType: '纯电动', bodyType: '轿车', seatCount: 5, acceleration: 3.3, features: ['自动驾驶', 'OTA升级', '大屏交互', '超级充电'], score: 95, image: 'brand_car3', description: '特斯拉入门级轿车，智能化程度领先' },
    { id: 3, brand: '小鹏', model: 'P7', price: 239900, range: 586, powerType: '纯电动', bodyType: '轿车', seatCount: 5, acceleration: 4.3, features: ['XPILOT智能驾驶', '丹拿音响', 'Nappa座椅'], score: 88, image: 'brand_car1', description: '小鹏旗舰轿车，智能驾驶体验优秀' },
    { id: 4, brand: '蔚来', model: 'ET5', price: 328000, range: 590, powerType: '纯电动', bodyType: '轿车', seatCount: 5, acceleration: 4.3, features: ['NAD自动驾驶', '换电技术', '女王副驾'], score: 93, image: 'brand_car3', description: '蔚来中型豪华轿车，换电补能便捷' },
    { id: 5, brand: '理想', model: 'L7', price: 319800, range: 210, powerType: '增程式', bodyType: 'SUV', seatCount: 6, acceleration: 5.3, features: ['AD Max智驾', '冰箱大屏沙发', 'NOA导航'], score: 94, image: 'brand_car1', description: '理想家庭旗舰SUV，续航无焦虑' },
    { id: 6, brand: '问界', model: 'M7', price: 249800, range: 230, powerType: '增程式', bodyType: 'SUV', seatCount: 6, acceleration: 4.8, features: ['华为智驾', 'HarmonyOS座舱', '零重力座椅'], score: 91, image: 'brand_car3', description: '华为深度赋能，智能座舱体验出色' },
    { id: 7, brand: '比亚迪', model: '宋PLUS EV', price: 169800, range: 520, powerType: '纯电动', bodyType: 'SUV', seatCount: 5, acceleration: 7.9, features: ['DiLink 4.0', 'VTOL对外放电', '热泵空调'], score: 85, image: 'brand_car1', description: '紧凑型电动SUV，性价比之选' },
    { id: 8, brand: '大众', model: 'ID.3', price: 162800, range: 450, powerType: '纯电动', bodyType: '轿车', seatCount: 5, acceleration: 7.3, features: ['MEB平台', 'AR-HUD', 'Travel Assist'], score: 82, image: 'brand_car3', description: '大众纯电入门车型，品质可靠' },
    { id: 9, brand: '吉利', model: '银河E5', price: 149800, range: 660, powerType: '纯电动', bodyType: 'SUV', seatCount: 5, acceleration: 6.9, features: ['骁龙8155', 'Flyme Auto', 'L2智驾'], score: 86, image: 'brand_car1', description: '吉利纯电SUV，空间大续航长性价比高' },
    { id: 10, brand: '极氪', model: '007', price: 229900, range: 688, powerType: '纯电动', bodyType: '轿车', seatCount: 5, acceleration: 2.84, features: ['浩瀚智驾', '金砖电池', '8295芯片'], score: 90, image: 'brand_car3', description: '极氪豪华纯电轿车，性能与智驾兼备' },
    { id: 11, brand: '小米', model: 'SU7', price: 215900, range: 668, powerType: '纯电动', bodyType: '轿车', seatCount: 5, acceleration: 2.78, features: ['Xiaomi Pilot', '澎湃OS', '超级电机'], score: 96, image: 'brand_car1', description: '小米首款轿车，性能强悍智能领先' },
    { id: 12, brand: '深蓝', model: 'SL03', price: 159900, range: 515, powerType: '纯电动', bodyType: '轿车', seatCount: 5, acceleration: 5.9, features: ['Deepal智驾', 'AR-HUD', '向日葵屏'], score: 84, image: 'brand_car3', description: '深蓝中型轿车，性价比出色配置丰富' }
  ];

  private constructor() {
    this.generateSessionId();
  }

  public static getInstance(): ChatService {
    if (!ChatService.instance) {
      ChatService.instance = new ChatService();
    }
    return ChatService.instance;
  }

  private generateSessionId(): void {
    this.sessionId = 'session_' + Date.now() + '_' + Math.random().toString(36).substring(2, 11);
  }

  public getSessionId(): string {
    return this.sessionId;
  }

  public loadHistory(): void {
    const saved: ChatMessage[] = this.chatHistory.loadSession();
    if (saved.length > 0) {
      this.messages = saved;
    }
  }

  public getState(): ChatState {
    const state: ChatState = {
      messages: this.copyMessages(),
      isLoading: this.isLoading,
      isStreaming: this.isStreamingActive,
      currentContext: {
        budgetMin: 0,
        budgetMax: 0,
        rangeRequirement: 0,
        bodyType: '',
        powerType: '',
        naturalLanguageDescription: ''
      },
      sessionId: this.sessionId,
      error: null
    };
    return state;
  }

  public getIsLoading(): boolean {
    return this.isLoading;
  }

  public cancelCurrentRequest(): void {
    if (this.currentRequest) {
      this.currentRequest.destroy();
      this.currentRequest = null;
    }
    this.isStreamingActive = false;
    if (this.isLoading) {
      this.isLoading = false;
      this.removeLoadingMessage();
    }
  }

  public initNetworkMonitor(): void {
    this.networkMonitor.register();
    this.networkMonitor.setCallbacks(
      () => {
        if (this.isDegraded) {
          this.scheduleRecovery();
        }
      },
      () => {}
    );
  }

  private scheduleRecovery(): void {
    this.networkMonitor.scheduleRecoveryCheck(() => {
      this.isDegraded = false;
    }, 30000);
  }

  public getMessages(): ChatMessage[] {
    const result: ChatMessage[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      result.push(this.messages[i]);
    }
    return result;
  }

  public sendUserMessage(content: string, pageName: string): ChatMessage[] {
    this.isLoading = true;

    const userMessage: ChatMessage = {
      id: this.generateId(),
      role: 'user',
      type: MessageType.TEXT,
      content: content,
      timestamp: Date.now()
    };
    this.messages.push(userMessage);

    const extra: Record<string, string> = {};
    extra['content'] = content;
    const event: BehaviorEvent = {
      eventType: 'chat_send',
      targetId: '',
      targetType: 'message',
      timestamp: Date.now(),
      pageName: pageName,
      extra: extra
    };
    this.behaviorTracker.track(event);

    this.extractPreferencesFromMessage(content, pageName);

    const loadingMessage: ChatMessage = {
      id: this.generateId(),
      role: 'assistant',
      type: MessageType.LOADING,
      content: '',
      timestamp: Date.now()
    };
    this.messages.push(loadingMessage);

    return this.copyMessages();
  }

  public async getAIResponse(userProfile?: UserBehaviorProfile, completeness?: ProfileCompletenessResult): Promise<ChatMessage[]> {
    hilog.info(this.LOG_DOMAIN, this.LOG_TAG, `getAIResponse: isDegraded=${this.isDegraded}, isOnline=${this.networkMonitor.isOnline}`);
    if (this.isDegraded) {
      return this.getDegradedResponse();
    }

    if (!this.networkMonitor.isOnline) {
      this.isDegraded = true;
      this.removeLoadingMessage();
      this.isLoading = false;
      const degradeMsg: ChatMessage = {
        id: this.generateId(),
        role: 'assistant',
        type: MessageType.TEXT,
        content: DegradationTriggers.NETWORK_UNAVAILABLE.message,
        timestamp: Date.now()
      };
      this.messages.push(degradeMsg);
      this.chatHistory.saveSession(this.messages);
      this.scheduleRecovery();
      return this.copyMessages();
    }

    try {
      await this.requestAIResponse(userProfile, completeness);
      this.removeLoadingMessage();
      this.isLoading = false;
      this.isStreamingActive = false;
      this.retryCount = 0;
      this.chatHistory.saveSession(this.messages);
    } catch (error) {
      this.removeLoadingMessage();
      this.isLoading = false;
      this.isStreamingActive = false;
      const shouldDegrade = this.handleAPIError(error);
      if (shouldDegrade) {
        this.isDegraded = true;
        const degradeMsg: ChatMessage = {
          id: this.generateId(),
          role: 'assistant',
          type: MessageType.TEXT,
          content: DegradationTriggers.NETWORK_UNAVAILABLE.message,
          timestamp: Date.now()
        };
        this.messages.push(degradeMsg);
        this.chatHistory.saveSession(this.messages);
        return this.copyMessages();
      }
      const errorMessage = this.handleError(error);
      this.messages.push(errorMessage);
    }
    this.chatHistory.saveSession(this.messages);
    return this.copyMessages();
  }

  private async requestAIResponse(userProfile?: UserBehaviorProfile, completeness?: ProfileCompletenessResult): Promise<void> {
    const systemPrompt = this.buildSystemPrompt(userProfile, completeness);
    const systemTokenCount: number = this.estimateTokenCount(systemPrompt);
    const userPrompt = this.buildUserPrompt(systemTokenCount);

    const systemMsg: ChatMessageForAPI = { role: 'system', content: systemPrompt };
    const userMsg: ChatMessageForAPI = { role: 'user', content: userPrompt };
    const request: APIRequest = {
      model: this.MODEL_ID,
      messages: [systemMsg, userMsg],
      temperature: 0.7,
      max_tokens: 2048,
      stream: true
    };

    const httpRequest = http.createHttp();
    this.currentRequest = httpRequest;

    try {
      const response = await httpRequest.request(this.AI_API_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.API_KEY}`
        },
        extraData: JSON.stringify(request),
        connectTimeout: 10000,
        readTimeout: 30000
      });

      httpRequest.destroy();
      this.currentRequest = null;

      if (response.responseCode === 200 || response.responseCode === 201) {
        const resultStr = response.result as string;
        const fullContent = this.parseStreamResponse(resultStr);
        hilog.info(this.LOG_DOMAIN, this.LOG_TAG, `parseStreamResponse got content length=${fullContent.length}, content=[${fullContent.substring(0, 200)}]`);
        if (fullContent.length > 0) {
          const parsed2: QuestionResponse = this.parseOptionsFromContent(fullContent);
          const validatedContent: string = this.validateCarMentions(parsed2.content);
          const recommendResults: RecommendResult[] | undefined = this.tryExtractRecommendResults(fullContent);
          hilog.info(this.LOG_DOMAIN, this.LOG_TAG, `tryExtractRecommendResults: results=${recommendResults !== undefined ? recommendResults.length : 'undefined'}`);
          if (recommendResults) {
            for (let ri = 0; ri < recommendResults.length; ri++) {
              hilog.info(this.LOG_DOMAIN, this.LOG_TAG, `  result[${ri}]: ${recommendResults[ri].car.brand} ${recommendResults[ri].car.model} score=${recommendResults[ri].score}`);
            }
          }
          const aiMessage: ChatMessage = {
            id: this.generateId(),
            role: 'assistant',
            type: MessageType.TEXT,
            content: validatedContent,
            options: parsed2.options.length > 0 ? parsed2.options : undefined,
            recommendResults: recommendResults,
            timestamp: Date.now()
          };
          this.messages.push(aiMessage);
          return;
        }
        throw new Error('API返回格式不正确');
      }

      if (response.responseCode >= 500) {
        throw new Error('API_5XX');
      }

      throw new Error(`API请求失败: ${response.responseCode}`);
    } catch (err) {
      httpRequest.destroy();
      this.currentRequest = null;
      if (err instanceof Error) {
        throw err;
      }
      throw new Error(String(err));
    }
  }

  private parseStreamResponse(resultStr: string): string {
    let fullContent: string = '';
    const lines: string[] = resultStr.split('\n');
    for (let i = 0; i < lines.length; i++) {
      const line: string = lines[i].trim();
      if (line.length === 0 || line.indexOf('data:') !== 0) {
        continue;
      }
      const dataStr: string = line.substring(5).trim();
      if (dataStr === '[DONE]') {
        break;
      }
      try {
        const chunk: StreamChunk = JSON.parse(dataStr) as StreamChunk;
        if (chunk.choices && chunk.choices.length > 0 && chunk.choices[0].delta && chunk.choices[0].delta.content) {
          fullContent += chunk.choices[0].delta.content;
        }
      } catch (_e) {
        const nonStreamParsed: APIResponse = JSON.parse(resultStr) as APIResponse;
        if (nonStreamParsed.choices && nonStreamParsed.choices.length > 0 && nonStreamParsed.choices[0].message && nonStreamParsed.choices[0].message.content) {
          return nonStreamParsed.choices[0].message.content;
        }
      }
    }
    if (fullContent.length === 0) {
      try {
        const nonStreamParsed: APIResponse = JSON.parse(resultStr) as APIResponse;
        if (nonStreamParsed.choices && nonStreamParsed.choices.length > 0 && nonStreamParsed.choices[0].message && nonStreamParsed.choices[0].message.content) {
          return nonStreamParsed.choices[0].message.content;
        }
      } catch (_e2) {
      }
    }
    return fullContent;
  }

  private tryExtractRecommendResults(content: string): RecommendResult[] | undefined {
    hilog.info(this.LOG_DOMAIN, this.LOG_TAG, `tryExtractRecommendResults: content=[${content.substring(0, 300)}]`);
    const mentionedCars: CarInfo[] = [];
    for (let i = 0; i < this.CAR_DATABASE.length; i++) {
      const car: CarInfo = this.CAR_DATABASE[i];
      const fullName: string = car.brand + car.model;
      const fullNameWithSpace: string = car.brand + ' ' + car.model;
      const matchFull: boolean = content.indexOf(fullName) >= 0;
      const matchFullSpace: boolean = content.indexOf(fullNameWithSpace) >= 0;
      const matchModel: boolean = content.indexOf(car.model) >= 0;
      if (matchFull || matchFullSpace || matchModel) {
        hilog.info(this.LOG_DOMAIN, this.LOG_TAG, `  matched car: ${car.brand} ${car.model} (full=${matchFull}, space=${matchFullSpace}, model=${matchModel})`);
        let alreadyAdded: boolean = false;
        for (let j = 0; j < mentionedCars.length; j++) {
          if (mentionedCars[j].id === car.id) {
            alreadyAdded = true;
            break;
          }
        }
        if (!alreadyAdded) {
          mentionedCars.push(car);
        }
      }
    }

    if (mentionedCars.length === 0) {
      hilog.warn(this.LOG_DOMAIN, this.LOG_TAG, `tryExtractRecommendResults: NO cars matched from ${this.CAR_DATABASE.length} cars in database`);
      return undefined;
    }

    const results: RecommendResult[] = [];
    for (let i = 0; i < mentionedCars.length; i++) {
      const car: CarInfo = mentionedCars[i];
      const reasons: string[] = this.generateReasons(car, content);
      const baseScore: number = car.score;
      const positionBonus: number = i === 0 ? 5 : i === 1 ? 2 : 0;
      const finalScore: number = Math.min(baseScore + positionBonus, 99);
      const result: RecommendResult = {
        car: car,
        score: finalScore,
        reasons: reasons
      };
      results.push(result);
    }

    return results.length > 0 ? results : undefined;
  }

  private generateReasons(car: CarInfo, content: string): string[] {
    const reasons: string[] = [];
    if (content.indexOf('万') >= 0 || content.indexOf('预算') >= 0 || content.indexOf('价格') >= 0) {
      reasons.push(`${car.brand}${car.model} 售价${(car.price / 10000).toFixed(1)}万`);
    }
    if (content.indexOf('续航') >= 0 || content.indexOf('里程') >= 0) {
      reasons.push(`续航${car.range}km`);
    }
    if (content.indexOf('SUV') >= 0 && car.bodyType === 'SUV') {
      reasons.push(`${car.bodyType}车型符合需求`);
    } else if (content.indexOf('轿车') >= 0 && car.bodyType === '轿车') {
      reasons.push(`${car.bodyType}车型符合需求`);
    }
    if (content.indexOf('纯电') >= 0 && car.powerType === '纯电动') {
      reasons.push('纯电动力零排放');
    } else if (content.indexOf('增程') >= 0 && car.powerType === '增程式') {
      reasons.push('增程式续航无忧');
    }
    if (reasons.length === 0) {
      reasons.push(`${car.brand}${car.model} 综合评分${car.score}分`);
      if (car.features.length > 0) {
        reasons.push(`核心亮点：${car.features[0]}`);
      }
    }
    return reasons;
  }

  public quickRecommend(budgetLevel: string, bodyType: string): RecommendResult[] {
    const budgetMap: Record<string, BudgetRange> = {
      '10万以下': { min: 0, max: 150000 },
      '10-20万': { min: 150000, max: 250000 },
      '20-30万': { min: 250000, max: 350000 },
      '30万以上': { min: 350000, max: 1000000 }
    };

    const defaultBudget: BudgetRange = { min: 0, max: 1000000 };
    const budget: BudgetRange = budgetMap[budgetLevel] || defaultBudget;

    const scored: RecommendResult[] = [];
    for (let i = 0; i < this.CAR_DATABASE.length; i++) {
      const car: CarInfo = this.CAR_DATABASE[i];
      let totalScore: number = 0;
      const reasons: string[] = [];

      const budgetCenter: number = (budget.min + budget.max) / 2;
      const budgetDist: number = Math.abs(car.price - budgetCenter) / (budget.max - budget.min + 1);
      const budgetScore: number = Math.max(0, 1 - budgetDist) * 30;
      totalScore += budgetScore;
      if (car.price >= budget.min && car.price <= budget.max) {
        reasons.push(`售价${(car.price / 10000).toFixed(1)}万，符合预算`);
      }

      if (bodyType.length > 0 && bodyType !== 'any' && bodyType !== '都行' && bodyType !== '无所谓') {
        if (car.bodyType === bodyType) {
          totalScore += 25;
          reasons.push(`${car.bodyType}车型符合偏好`);
        } else {
          totalScore += 5;
        }
      } else {
        totalScore += 15;
      }

      const rangeScore: number = Math.min(car.range / 600, 1) * 20;
      totalScore += rangeScore;
      reasons.push(`续航${car.range}km`);

      totalScore += car.score / 100 * 15;

      if (car.features.length > 0) {
        reasons.push(`核心亮点：${car.features[0]}`);
      }

      const result: RecommendResult = {
        car: car,
        score: Math.round(totalScore),
        reasons: reasons.slice(0, 3)
      };
      scored.push(result);
    }

    scored.sort((a: RecommendResult, b: RecommendResult) => b.score - a.score);
    return scored.slice(0, 3);
  }

  public clearConversation(): void {
    this.cancelCurrentRequest();
    this.messages = [];
    this.generateSessionId();
    this.isDegraded = false;
    this.retryCount = 0;
    this.isLoading = false;
    this.isStreamingActive = false;
    this.chatHistory.clearSession();
  }

  public async checkPrivacyAccepted(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const pref = await preferences.getPreferences(context, 'ai_assistant_prefs');
      const accepted = await pref.get(this.PRIVACY_KEY, false);
      return accepted as boolean;
    } catch (_e) {
      return false;
    }
  }

  public async setPrivacyAccepted(context: common.UIAbilityContext): Promise<void> {
    try {
      const pref = await preferences.getPreferences(context, 'ai_assistant_prefs');
      await pref.put(this.PRIVACY_KEY, true);
      await pref.flush();
    } catch (_e) {
    }
  }

  public getCarDatabase(): CarInfo[] {
    const result: CarInfo[] = [];
    for (let i = 0; i < this.CAR_DATABASE.length; i++) {
      result.push(this.CAR_DATABASE[i]);
    }
    return result;
  }

  private buildSystemPrompt(userProfile?: UserBehaviorProfile, completeness?: ProfileCompletenessResult): string {
    let prompt = '你是一个专业的AI选车顾问，名叫"车顾问"。\n\n';
    prompt += '【角色设定】\n';
    prompt += '- 专业、耐心、友好，用通俗易懂的语言回答\n';
    prompt += '- 熟悉中国汽车市场，了解主流车型参数\n';
    prompt += '- 优先推荐市场口碑好、性价比高的车型\n';
    prompt += '- 你只能推荐以下数据库中的车型，绝不能推荐其他车型：\n';
    prompt += '  比亚迪汉EV、比亚迪宋PLUS EV、特斯拉Model 3、小鹏P7、蔚来ET5、理想L7、问界M7、大众ID.3、吉利银河E5、极氪007、小米SU7、深蓝SL03\n\n';
    prompt += '【能力边界】\n';
    prompt += '- 可以回答关于车型推荐、参数对比、购车建议的问题\n';
    prompt += '- 不能回答与汽车无关的问题\n';
    prompt += '- 如果不确定答案，明确告知用户\n';
    prompt += '- 只能推荐上述数据库中的车型，如果用户需求与数据库车型不匹配，从数据库中选择最接近的并说明\n\n';
    prompt += '【输出格式约束】\n';
    prompt += '- 追问模式：每次只问一个维度，必须提供选项供选择，每个选项独占一行，格式严格如下：\n';
    prompt += '  请问...？\nA.选项1\nB.选项2\nC.选项3\nD.都行/无所谓\n';
    prompt += '  注意：主观偏好类问题必须包含"都行/无所谓"选项，客观问题不需要\n';
    prompt += '- 推荐模式：用自然语言直接推荐2-3款车型，说明品牌、型号、价格和核心优势\n';
    prompt += '  推荐时必须使用完整品牌+车型名，例如"比亚迪宋PLUS EV"、"问界M7"，不要简写\n';
    prompt += '- 对比模式：用户要求对比时，列出2款车型的关键参数对比\n';
    prompt += '- 回复简洁，不超过300字\n';

    if (completeness) {
      if (completeness.shouldAskMore) {
        prompt += '\n【当前模式：追问模式】\n';
        prompt += '- 用户信息完整度仅' + Math.round(completeness.overallScore * 100) + '%，信息不足\n';
        prompt += '- 必须使用追问模式，每次只问一个缺失维度\n';
        prompt += '- 如果用户主动提供了信息，先确认再继续追问下一维度\n';
        if (completeness.missingDimensions.length > 0) {
          const dimensionMap: Record<string, string> = {
            'priceRange': '预算范围',
            'bodyType': '车身类型（轿车/SUV/MPV等）',
            'powerType': '动力类型（纯电/混动/燃油）',
            'brand': '品牌偏好',
            'feature': '关注的功能特性'
          };
          const missingLabels: string[] = [];
          for (let i = 0; i < completeness.missingDimensions.length; i++) {
            const label = dimensionMap[completeness.missingDimensions[i]];
            if (label) {
              missingLabels.push(label);
            }
          }
          prompt += '- 缺失维度：' + missingLabels.join('、') + '\n';
        }
      } else {
        prompt += '\n【当前模式：推荐模式】\n';
        prompt += '- 用户信息完整度已达' + Math.round(completeness.overallScore * 100) + '%，可以直接推荐\n';
        prompt += '- 用自然语言推荐2-3款最匹配的车型\n';
        prompt += '- 推荐时必须使用完整品牌+车型名，方便系统匹配数据\n';
        prompt += '- 推荐后询问"是否需要对比详细参数？"引导深度交互\n';
        if (completeness.priceRangeScore > 0) {
          prompt += '- 推荐时优先匹配用户预算范围\n';
        }
        if (completeness.bodyTypeScore > 0) {
          prompt += '- 推荐时优先匹配用户偏好的车身类型\n';
        }
        if (completeness.powerTypeScore > 0) {
          prompt += '- 推荐时优先匹配用户偏好的动力类型\n';
        }
        if (completeness.brandScore > 0) {
          prompt += '- 推荐时优先考虑用户关注的品牌\n';
        }
      }
    }

    if (userProfile) {
      prompt += '\n【用户画像】\n';
      if (userProfile.priceRange.preferred.length > 0) {
        prompt += `- 偏好价位: ${userProfile.priceRange.preferred}\n`;
      }
      if (userProfile.bodyType.preferred.length > 0) {
        prompt += `- 偏好车型: ${userProfile.bodyType.preferred}\n`;
      }
      if (userProfile.powerType.preferred.length > 0) {
        prompt += `- 偏好动力: ${userProfile.powerType.preferred}\n`;
      }
      if (userProfile.brandPreference.brands.length > 0) {
        prompt += `- 关注品牌: ${userProfile.brandPreference.brands.join('、')}\n`;
      }
      if (userProfile.featurePreference.features.length > 0) {
        prompt += `- 关注功能: ${userProfile.featurePreference.features.join('、')}\n`;
      }
    }
    return prompt;
  }

  private readonly MAX_CONTEXT_ROUNDS: number = 20;
  private readonly MAX_TOKEN_BUDGET: number = 6000;

  private estimateTokenCount(text: string): number {
    return Math.ceil(text.length / 2);
  }

  private buildUserPrompt(systemTokenCount: number): string {
    const availableTokens: number = this.MAX_TOKEN_BUDGET - systemTokenCount;
    const nonLoadingMessages: ChatMessage[] = [];
    let estimatedTokens: number = 0;

    for (let i = this.messages.length - 1; i >= 0; i--) {
      if (this.messages[i].type !== MessageType.LOADING && this.messages[i].type !== MessageType.ERROR) {
        const msgTokens: number = this.estimateTokenCount(this.messages[i].content) + 10;
        if (estimatedTokens + msgTokens > availableTokens && nonLoadingMessages.length > 0) {
          break;
        }
        nonLoadingMessages.unshift(this.messages[i]);
        estimatedTokens += msgTokens;
        if (nonLoadingMessages.length >= this.MAX_CONTEXT_ROUNDS * 2) {
          break;
        }
      }
    }
    let prompt = '';
    for (let i = 0; i < nonLoadingMessages.length; i++) {
      const msg = nonLoadingMessages[i];
      const role = msg.role === 'user' ? '用户' : '助手';
      prompt += `${role}: ${msg.content}\n`;
    }
    return prompt;
  }

  private handleAPIError(error: Error | string): boolean {
    this.retryCount++;
    const errorStr = error instanceof Error ? error.message : String(error);

    if (errorStr === 'API_5XX') {
      return true;
    }
    if (errorStr.includes('timeout') || errorStr.includes('Timeout')) {
      return this.retryCount >= this.MAX_RETRY;
    }
    if (errorStr.includes('network') || errorStr.includes('Network') || errorStr.includes('fail')) {
      return this.retryCount >= this.MAX_RETRY;
    }
    return false;
  }

  private async getDegradedResponse(): Promise<ChatMessage[]> {
    hilog.warn(this.LOG_DOMAIN, this.LOG_TAG, 'getDegradedResponse: using degraded/simulated response');
    await this.simulateAIResponse();
    this.removeLoadingMessage();
    this.chatHistory.saveSession(this.messages);
    return this.copyMessages();
  }

  private copyMessages(): ChatMessage[] {
    const result: ChatMessage[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      result.push(this.messages[i]);
    }
    return result;
  }

  private async simulateAIResponse(): Promise<void> {
    await new Promise<void>((resolve: () => void) => setTimeout(resolve, 1500));

    const question0: QuestionResponse = {
      content: '请问你更看重续航里程还是智能驾驶功能呢？',
      options: ['续航里程', '智能驾驶', '两者兼顾']
    };
    const question1: QuestionResponse = {
      content: '你更倾向于选择什么价位的车型？',
      options: ['10万以下', '10-20万', '20-30万', '30万以上']
    };
    const question2: QuestionResponse = {
      content: '你偏好哪种车身类型？',
      options: ['轿车', 'SUV', 'MPV', '跑车']
    };
    const question3: QuestionResponse = {
      content: '你更关注车辆的哪些性能指标？',
      options: ['加速性能', '舒适性', '空间大小', '安全性']
    };
    const question4: QuestionResponse = {
      content: '你是否有特定的品牌偏好？',
      options: ['国产', '日系', '德系', '美系']
    };
    const questionResponses: QuestionResponse[] = [question0, question1, question2, question3, question4];

    const textResponses: string[] = [
      '好的，我来帮你分析一下。你想要20万左右的SUV，对吗？',
      '根据你的需求，我推荐以下几款车型：比亚迪 宋PLUS EV、问界 M7、理想 L7。',
      '收到！让我为你推荐最合适的车型。',
      '综合你的需求，我认为以下车型比较适合你：比亚迪 汉EV、小鹏 P7、蔚来 ET5。',
      '好的，我明白了。让我为你推荐几款符合要求的车型。比亚迪 宋PLUS EV性价比很高，特斯拉 Model 3智能化领先，大众 ID.3入门首选。'
    ];

    const isQuestionResponse = Math.random() > 0.5;
    const isComparisonResponse = Math.random() > 0.7;
    let aiMessage: ChatMessage;

    if (isComparisonResponse) {
      const car1: CarInfo = {
        id: 1, brand: '比亚迪', model: '宋PLUS EV', price: 169800, range: 520,
        powerType: '纯电动', bodyType: 'SUV', seatCount: 5, acceleration: 7.9,
        features: ['DiLink 4.0'], score: 85, image: '', description: ''
      };
      const car2: CarInfo = {
        id: 6, brand: '问界', model: 'M7', price: 249800, range: 230,
        powerType: '增程式', bodyType: 'SUV', seatCount: 6, acceleration: 4.8,
        features: ['华为智驾'], score: 91, image: '', description: ''
      };
      const comparison: ComparisonData = {
        cars: [car1, car2],
        compareFields: ['价格', '续航', '动力', '座位', '加速', '评分']
      };
      aiMessage = {
        id: this.generateId(),
        role: 'assistant',
        type: MessageType.COMPARISON,
        content: '为你对比以下两款车型：',
        comparison: comparison,
        timestamp: Date.now()
      };
    } else if (isQuestionResponse) {
      const question = questionResponses[Math.floor(Math.random() * questionResponses.length)];
      aiMessage = {
        id: this.generateId(),
        role: 'assistant',
        type: MessageType.TEXT,
        content: question.content,
        options: question.options,
        timestamp: Date.now()
      };
    } else {
      const randomResponse = textResponses[Math.floor(Math.random() * textResponses.length)];
      const recommendResults: RecommendResult[] | undefined = this.tryExtractRecommendResults(randomResponse);
      aiMessage = {
        id: this.generateId(),
        role: 'assistant',
        type: MessageType.TEXT,
        content: randomResponse,
        recommendResults: recommendResults,
        timestamp: Date.now()
      };
    }
    this.messages.push(aiMessage);
  }

  private removeLoadingMessage(): void {
    const loadingIndex = this.messages.findIndex((m: ChatMessage) => m.type === MessageType.LOADING);
    if (loadingIndex !== -1) {
      this.messages.splice(loadingIndex, 1);
    }
  }

  private handleError(_error: Error | string): ChatMessage {
    const errorCode: string = ErrorCodes.NETWORK_ERROR;
    const errorMessage: ChatMessage = {
      id: this.generateId(),
      role: 'assistant',
      type: MessageType.ERROR,
      content: '网络异常，请检查网络连接后重试',
      timestamp: Date.now(),
      errorCode: errorCode,
      retryable: true
    };
    return errorMessage;
  }

  public clearHistory(): void {
    this.messages = [];
    this.generateSessionId();
  }

  public getHistory(): ChatMessage[] {
    const result: ChatMessage[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      result.push(this.messages[i]);
    }
    return result;
  }

  public isDegradedMode(): boolean {
    return this.isDegraded;
  }

  public setDegradedMode(degraded: boolean): void {
    this.isDegraded = degraded;
  }

  private generateId(): string {
    return 'msg_' + Date.now() + '_' + Math.random().toString(36).substring(2, 11);
  }

  public extractPreferencesFromMessage(content: string, pageName: string): void {
    const searchExtra: Record<string, string> = {};
    if (content.indexOf('SUV') >= 0) {
      searchExtra['bodyType'] = 'SUV';
    } else if (content.indexOf('轿车') >= 0) {
      searchExtra['bodyType'] = '轿车';
    } else if (content.indexOf('MPV') >= 0) {
      searchExtra['bodyType'] = 'MPV';
    } else if (content.indexOf('跑车') >= 0) {
      searchExtra['bodyType'] = '跑车';
    }

    if (content.indexOf('纯电') >= 0 || content.indexOf('电动') >= 0) {
      searchExtra['powerType'] = '纯电动';
    } else if (content.indexOf('混动') >= 0 || content.indexOf('插混') >= 0) {
      searchExtra['powerType'] = '混合动力';
    } else if (content.indexOf('增程') >= 0) {
      searchExtra['powerType'] = '增程式';
    } else if (content.indexOf('燃油') >= 0 || content.indexOf('油车') >= 0) {
      searchExtra['powerType'] = '燃油';
    }

    if (content.indexOf('10万') >= 0 || content.indexOf('十万') >= 0) {
      searchExtra['priceRange'] = '10万以下';
    } else if (content.indexOf('15万') >= 0 || content.indexOf('20万') >= 0) {
      searchExtra['priceRange'] = '10-20万';
    } else if (content.indexOf('25万') >= 0 || content.indexOf('30万') >= 0) {
      searchExtra['priceRange'] = '20-30万';
    } else if (content.indexOf('50万') >= 0 || content.indexOf('百万') >= 0) {
      searchExtra['priceRange'] = '30万以上';
    }

    if (content.indexOf('比亚迪') >= 0) {
      searchExtra['brand'] = '比亚迪';
    } else if (content.indexOf('特斯拉') >= 0) {
      searchExtra['brand'] = '特斯拉';
    } else if (content.indexOf('蔚来') >= 0) {
      searchExtra['brand'] = '蔚来';
    } else if (content.indexOf('理想') >= 0) {
      searchExtra['brand'] = '理想';
    } else if (content.indexOf('小鹏') >= 0) {
      searchExtra['brand'] = '小鹏';
    } else if (content.indexOf('问界') >= 0) {
      searchExtra['brand'] = '问界';
    } else if (content.indexOf('极氪') >= 0) {
      searchExtra['brand'] = '极氪';
    } else if (content.indexOf('小米') >= 0) {
      searchExtra['brand'] = '小米';
    } else if (content.indexOf('大众') >= 0) {
      searchExtra['brand'] = '大众';
    }

    if (Object.keys(searchExtra).length > 0) {
      const searchEvent: BehaviorEvent = {
        eventType: 'search',
        targetId: content,
        targetType: 'chat_input',
        timestamp: Date.now(),
        pageName: pageName,
        extra: searchExtra
      };
      this.behaviorTracker.track(searchEvent);
    }
  }

  private validateCarMentions(content: string): string {
    let validated: string = content;
    for (let i = 0; i < this.KNOWN_CARS.length; i++) {
      const knownCar: string = this.KNOWN_CARS[i];
      if (validated.indexOf(knownCar) >= 0) {
        return validated;
      }
    }
    const hasSpecificInfo: boolean = validated.indexOf('万起') >= 0 ||
      validated.indexOf('续航') >= 0 && validated.indexOf('km') >= 0 ||
      validated.indexOf('加速') >= 0 && validated.indexOf('s') >= 0;
    if (hasSpecificInfo) {
      validated += '\n\n⚠️ 以上信息仅供参考，请以实际车型参数为准。';
    }
    return validated;
  }

  private parseOptionsFromContent(content: string): QuestionResponse {
    const options: string[] = [];

    const prefixes: string[] = [
      'A.', 'B.', 'C.', 'D.', 'E.', 'F.',
      'A、', 'B、', 'C、', 'D、', 'E、', 'F、',
      'A)', 'B)', 'C)', 'D)', 'E)', 'F)'
    ];

    const positions: number[] = [];
    const matchedPrefixes: string[] = [];
    for (let i = 0; i < prefixes.length; i++) {
      const idx: number = content.indexOf(prefixes[i]);
      if (idx >= 0) {
        positions.push(idx);
        matchedPrefixes.push(prefixes[i]);
      }
    }

    if (positions.length >= 2) {
      const sortedIndices: number[] = [];
      for (let i = 0; i < positions.length; i++) {
        sortedIndices.push(i);
      }
      for (let i = 0; i < sortedIndices.length - 1; i++) {
        for (let j = i + 1; j < sortedIndices.length; j++) {
          if (positions[sortedIndices[i]] > positions[sortedIndices[j]]) {
            const tmp: number = sortedIndices[i];
            sortedIndices[i] = sortedIndices[j];
            sortedIndices[j] = tmp;
          }
        }
      }

      const firstPos: number = positions[sortedIndices[0]];
      let cleanContent: string = content.substring(0, firstPos).trim();

      for (let k = 0; k < sortedIndices.length; k++) {
        const startIdx: number = positions[sortedIndices[k]] + matchedPrefixes[sortedIndices[k]].length;
        let endIdx: number = content.length;
        if (k + 1 < sortedIndices.length) {
          endIdx = positions[sortedIndices[k + 1]];
        }
        let optionText: string = content.substring(startIdx, endIdx).trim();
        if (optionText.length > 20) {
          optionText = optionText.substring(0, 20);
        }
        if (optionText.length > 0) {
          options.push(optionText);
        }
      }

      if (options.length >= 2) {
        const result: QuestionResponse = {
          content: cleanContent,
          options: options
        };
        return result;
      }
    }

    const result: QuestionResponse = {
      content: content,
      options: []
    };
    return result;
  }
}
