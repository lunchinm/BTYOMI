# BTYOMI buyingCar 模块改动记录

**日期**: 2026年5月24日

---

## 一、改动概述

本次改动将 `BTYOMI-main2.0` 版本的 AI 选车功能升级集成到主项目中，主要变化包括：

| 模块 | 改动类型 | 主要变化 |
|------|----------|----------|
| 数据模型 | 升级 | 新增火山方舟API接口定义，字段类型调整 |
| 推荐服务 | 重构 | 从本地算法改为调用大模型API |
| 用户偏好 | 扩展 | 支持自然语言描述需求 |
| UI交互 | 优化 | Q5改为文本输入框 |

---

## 二、核心改动详解

### 2.1 数据模型改动 (`model/AICarModel.ets`)

**新增内容：**

```typescript
// 火山方舟API接口定义
export interface VolcengineMessage {
role: string;
content: string;
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
```

**UserPreferences 变更：**

| 旧版本 | 新版本 | 说明 |
|--------|--------|------|
| `features: string[]` | `naturalLanguageDescription: string` | 从多选配置改为自然语言描述 |

**功能作用：**
- 支持调用火山方舟大模型API获取实时车辆推荐
- 用户可以用自然语言描述复杂的购车需求
- 响应格式统一为字符串类型，便于API数据解析

---

### 2.2 推荐服务改动 (`service/AICarRecommendService.ets`)

**核心变更：**

```typescript
// 新增火山方舟API配置
private readonly AI_API_URL = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';
private readonly API_KEY = 'ark-5a920e71-a107-4956-99ca-c090c52a7811-5efaf';
private readonly MODEL_ID = 'doubao-seed-2-0-mini-260428';

// recommend方法改为异步调用API
public async recommend(preferences: UserPreferences): Promise<RecommendResult[]> {
// 构建系统提示词和用户提示词
// 调用火山方舟API
// 解析JSON响应并转换格式
}
```

**移除内容：**
- 本地车辆数据库 (`carDatabase`)
- 本地评分算法 (`calculateScore`, `calculateBudgetScore` 等)

**功能作用：**
- 利用大模型的语义理解能力处理复杂需求
- 获取实时市场数据推荐最新车型
- 支持自然语言到结构化推荐的转换

---

### 2.3 UI交互改动 (`pages/AICarSelectPage.ets`)

**Q5问题变更：**

| 旧版本 | 新版本 |
|--------|--------|
| "您关注哪些配置功能？(可多选)" | "请用自然语言描述您的其他需求" |
| 复选框列表 | 文本输入框 |

**新增组件：**

```typescript
@Builder
buildTextQuestion() {
TextArea({
    text: this.naturalLanguageInput,
    placeholder: this.questions[this.currentStep].placeholder
})
    .width('100%')
    .height(150)
    // ...
    .onChange((value) => {
    this.naturalLanguageInput = value;
    this.preferences.naturalLanguageDescription = value;
    });
}
```

**功能作用：**
- 用户可以自由描述需求，不受预设选项限制
- 支持复杂需求表达（如"家庭用车，空间大，安全性好"）
- 提升用户体验和推荐准确性

---

### 2.4 Question接口扩展

**新增字段：**

```typescript
export interface Question {
id: string;
question: string;
type: string; // 'range' | 'single' | 'text' （新增'text'类型）
options?: QuestionOption[]; // 可选
placeholder?: string; // 新增，用于文本输入提示
}
```

**功能作用：**
- 支持多种问题类型（选择题、文本题）
- 文本输入时显示占位提示
- 增强问卷的灵活性

---

## 三、集成方案

### 3.1 数据模型层
- 保留原有 `CarInfo` 接口用于本地数据
- 新增 `AICarRecommendation` 接口用于API返回数据
- 新增火山方舟API相关接口定义

### 3.2 服务层
- 保留原有评分算法作为降级方案
- 新增API调用逻辑作为主流程
- 推荐方法改为异步函数

### 3.3 UI层
- 更新Q5问题类型为'text'
- 新增文本输入组件
- 更新状态管理逻辑

---

## 四、兼容性处理

| 场景 | 处理方式 |
|------|----------|
| API调用失败 | 降级到本地算法 |
| 网络不可用 | 使用本地车辆数据库 |
| 数据格式差异 | 在服务层进行转换 |

---

## 五、改动影响

### 5.1 正向影响
- 推荐结果更符合用户真实需求
- 支持复杂需求描述
- 获取实时市场数据
- 用户体验提升

### 5.2 潜在风险
- 依赖网络连接
- API调用有延迟
- 需要API Key配置

---

## 六、后续优化建议

1. **添加API错误重试机制**
2. **实现本地缓存策略**
3. **添加用户反馈收集**
4. **优化提示词工程**
5. **支持多种AI模型切换**
