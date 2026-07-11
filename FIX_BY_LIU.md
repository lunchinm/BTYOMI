# 预览功能修复变更记录

**修复时间**：2026-04-30

## 修复目的
修复华为鸿蒙项目在 DevEco Studio 中使用 Huawei Previewer 预览时无法显示的问题。

---

## 修复内容

### 1. `features/buyingCar/src/main/ets/pages/BuyingCarPage.ets`

**问题**：组件使用 `@Consume('pageInfos')` 装饰器，预览器不允许直接预览包含此类装饰器的组件

**解决方案**：添加 `@Entry` 包装组件提供上下文数据

```typescript
// 添加的代码
@Entry
struct BuyingCarPagePreview {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  
  build() {
    Column() {
      BuyingCarPage();
    }
    .width('100%')
    .height('100%');
  }
}
```

**注意**：移除了错误的 `@Entry @Component` 同时使用（`@Entry` 已隐含 `@Component`）

---

### 2. `features/service/src/main/ets/components/SheetTransition.ets`

#### 2.1 `@Prop` 属性缺少默认值

**问题**：预览器要求组件公共属性必须有运行时独立的默认值

**修复**：
```typescript
// 修复前
@Prop addressName: string;
@Prop stationList: StationInfo[];

// 修复后
@Prop addressName: string = '';
@Prop stationList: StationInfo[] = [];
```

#### 2.2 `controller` 属性缺少默认值

**问题**：`CustomDialogController` 需要有效的 `builder` 参数，无法创建默认实例

**修复**：将其改为可选属性
```typescript
// 修复前
controller: CustomDialogController;

// 修复后
controller?: CustomDialogController;
```

**同步修改**：使用时添加空值检查
```typescript
if (this.controller) {
  this.controller.close();
}
```

#### 2.3 List 组件缺少宽高属性

**问题**：预览器建议为 List 组件显式设置宽高

**修复**：
```typescript
List({ space: CommonConstants.PUBLIC_SPACE }) {
  // ...
}
.width(CommonConstants.COLUMN_WIDTH)
.height('100%')
```

---

## 修复总结

| 文件 | 问题类型 | 修复方案 |
|------|----------|----------|
| BuyingCarPage.ets | 装饰器冲突 | 添加包装组件提供 `@Provide` 上下文 |
| SheetTransition.ets | 属性缺少默认值 | 为 `@Prop` 添加默认值 |
| SheetTransition.ets | 属性无法初始化 | 将 `controller` 改为可选属性 |
| SheetTransition.ets | List 缺少尺寸 | 添加 `width` 和 `height` 属性 |

---

## 验证方式
打开 `BuyingCarPage.ets` 文件，点击右侧 Previewer 面板即可正常预览页面效果。

---

## 预览功能添加指南（2026-05-03 新增）

### 一、问题背景
在 HarmonyOS 开发中，使用了 `@Consume` 装饰器的组件无法直接在 DevEco Previewer 中预览，会报错：

```
A component attribute that can be initialized locally requires a valid, runtime-independent default value.
```

这是因为 `@Consume` 依赖于父组件通过 `@Provide` 提供的上下文数据，而 Previewer 无法模拟这种层级关系。

### 二、解决方案
为需要预览的组件创建一个**包装组件**，由包装组件提供 `@Provide` 上下文数据。

### 三、已添加预览的页面

| 文件路径 | 预览组件名称 |
|---------|-------------|
| features/shoppingMall/src/main/ets/pages/ShoppingMallPage.ets | ShoppingMallPagePreview |
| features/service/src/main/ets/pages/ServicePage.ets | ServicePagePreview |
| features/mine/src/main/ets/pages/MinePage.ets | MinePagePreview |
| features/buyingCar/src/main/ets/pages/BuyingCarPage.ets | BuyingCarPagePreview |
| features/explore/src/main/ets/pages/ExplorePage.ets | 已有 @Preview 装饰器 |

### 四、添加预览的标准模板

```typescript
// ============================================
// 【预览组件说明】
// 使用说明：如果XXXPage页面中添加了@Consume装饰器
// 1. 如果原页面已有 @Entry 装饰器，保留它，删除此预览组件
// 2. 如果原页面没有 @Entry 装饰器，添加 @Entry 成为预览组件
// 3. 如果原页面有 @Consume('pageInfos')，必须使用此预览组件方式
//
// 复制以下代码到对应的 .ets 文件开头部分即可
// ============================================
@Entry
struct XXXPagePreview {
  // 【必须】提供 @Consume 所需的上下文数据
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  build() {
    Column() {
      XXXPage();
    }
    .width('100%')
    .height('100%');
  }
}
```

### 五、使用步骤
1. 打开需要添加预览的 .ets 文件
2. 在文件开头的 import 语句之后，添加上述模板代码
3. 将模板中的 `XXXPage` 替换为实际页面组件名称
4. 保存文件
5. 在 DevEco Studio 中打开该文件，点击右上角 Previewer 按钮即可预览

### 六、注意事项

#### 6.1 不要同时使用 @Entry 和 @Component
错误示例：
```typescript
@Entry
@Component  // 【错误】@Entry 已隐含 @Component，不需要再写
struct MyPage {
  // ...
}
```

正确示例：
```typescript
@Entry
struct MyPage {  // 【正确】只需要 @Entry
  // ...
}
```

#### 6.2 组件属性需要默认值
Previewer 要求组件的公共属性必须有默认值，否则会报错。例如：

```typescript
// 【错误】属性没有默认值
@Prop name: string;

// 【正确】属性有默认值
@Prop name: string = '';
```

如果属性无法提供默认值，可以考虑：
- 将属性声明为可选：`@Prop name?: string;`
- 将属性声明为私有：`private name: string;`

#### 6.3 NavDestination 页面的预览
继承自 `NavDestination` 的页面（如 CommodityDetailPage、SettingsPage 等）不需要单独的预览组件，因为它们是通过导航跳转进入的。这些页面的预览需要通过父页面导航到该页面后才能预览。

---

## AI 智能选车功能实现（2026-05-10 新增）

### 一、实现内容

#### 1. 创建 AI 选车主页面

**文件**：[`features/buyingCar/src/main/ets/pages/AICarSelectPage.ets`](file:///c:\treatest\BTYOMI\BTYOMI\features\buyingCar\src\main\ets\pages\AICarSelectPage.ets)

**功能**：
- 5 步式调查问卷（预算、续航、车型、动力类型、配置）
- 进度指示器显示当前步骤
- 推荐结果展示
- 重新测试功能

**关键代码**：
```typescript
@Entry
@Component
struct AICarSelectPagePreview {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  
  build() {
    Column() {
      AICarSelectPage();
    }
    .width('100%')
    .height('100%');
  }
}

@Component
export struct AICarSelectPage {
  @Consume('pageInfos') pageInfos: NavPathStack;
  
  @State currentStep: number = 0;
  @State preferences: UserPreferences = {
    budgetMin: -1,
    budgetMax: -1,
    rangeRequirement: -1,
    bodyType: '',
    powerType: '',
    features: []
  };
}
```

#### 2. 创建推荐服务

**文件**：[`features/buyingCar/src/main/ets/service/AICarRecommendService.ets`](file:///c:\treatest\BTYOMI\BTYOMI\features\buyingCar\src\main\ets\service\AICarRecommendService.ets)

**功能**：
- 静态车型数据库（比亚迪、特斯拉、小鹏、蔚来、理想等）
- 基于用户偏好的评分算法
- 智能推荐逻辑

**优化后的算法**：
```typescript
public recommend(preferences: UserPreferences): RecommendResult[] {
  const results: RecommendResult[] = [];
  
  for (const car of this.carDatabase) {
    const score = this.calculateScore(car, preferences);
    const reasons = this.getMatchReasons(car, preferences);
    results.push({ car, score, reasons });
  }
  
  results.sort((a, b) => b.score - a.score);
  
  const highScoreResults = results.filter(r => r.score >= 90);
  
  if (highScoreResults.length > 0) {
    return highScoreResults.slice(0, 5);
  } else {
    return results.slice(0, 3);
  }
}
```

#### 3. 选车页面添加入口

**文件**：[`features/buyingCar/src/main/ets/pages/BuyingCarPage.ets`](file:///c:\treatest\BTYOMI\BTYOMI\features\buyingCar\src\main\ets\pages\BuyingCarPage.ets)

**修改内容**：
- 将 AI 选车入口移至页面最顶部
- 调整布局结构，确保入口不被覆盖
- 使用 `pageInfos.pushPath()` 进行导航

**关键代码**：
```typescript
build() {
  Column() {
    // AI智能选车入口（在最顶部）
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Image($r('app.media.AI_search'))
            .width(40)
            .height(40)
            .fillColor('#2ECC71');
        }
        .width(60)
        .height(60)
        .backgroundColor('rgba(46, 204, 113, 0.1)')
        .borderRadius(16);
        
        Column({ space: 4 }) {
          Text('AI智能选车')
            .fontSize(16)
            .fontWeight(700)
            .fontColor('#333333');
          
          Text('AI帮您找到最合适的车')
            .fontSize(12)
            .fontColor('#999999');
        }
        .flexGrow(1);
        
        Image($r('app.media.chevron_backward'))
          .width(20)
          .height(20)
          .fillColor('#CCCCCC');
      }
      .width('100%')
      .height(80)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.pageInfos.pushPath({ name: 'AICarSelectPage' });
      });
    }
    .width('100%')
    .padding({ top: this.topHeight + CommonConstants.MAIN_MARGIN, left: CommonConstants.MAIN_PADDING, right: CommonConstants.MAIN_PADDING });
    
    // 其他内容...
  }
}
```

#### 4. 添加路由配置

**文件**：[`entry/src/main/ets/pages/NavigationPage.ets`](file:///c:\treatest\BTYOMI\BTYOMI\entry\src\main\ets\pages\NavigationPage.ets)

**修改内容**：
- 导入 AICarSelectPage
- 在 PagesMap 中添加路由

**关键代码**：
```typescript
import { BuyingCarDetailPage, AICarSelectPage } from '@ohos/buyingCar';

@Builder
PagesMap(name: string) {
  if (name === 'AICarSelectPage') {
    AICarSelectPage();
  }
}
```

### 二、修复的问题

#### 2.1 选项默认选中问题

**问题**：初始值与选项匹配，导致进入新问题时自动选中

**修复**：将初始值设为不匹配选项的值
```typescript
@State preferences: UserPreferences = {
  budgetMin: -1,
  budgetMax: -1,
  rangeRequirement: -1,
  bodyType: '',
  powerType: '',
  features: []
};
```

#### 2.2 推荐结果为空问题

**问题**：评分算法过于严格，导致无推荐结果

**修复**：
- 移除了 `score > 0` 的过滤
- 添加了降级策略：先显示 >=90 分的，否则显示最高分的 3 款
- 添加了兜底逻辑：直接使用车辆数据库

#### 2.3 布局覆盖问题

**问题**：AI 选车入口被 Stack 布局中的其他组件覆盖

**修复**：调整布局结构，将 AI 选车入口放在独立的 Column 中

### 三、修复总结

| 文件 | 问题类型 | 修复方案 |
|------|----------|----------|
| AICarSelectPage.ets | 新建页面 | 实现 AI 选车问卷和推荐展示 |
| AICarRecommendService.ets | 新建服务 | 实现车型数据库和推荐算法 |
| BuyingCarPage.ets | 布局覆盖 | 调整布局结构，添加 AI 选车入口 |
| NavigationPage.ets | 路由缺失 | 添加 AICarSelectPage 路由配置 |

### 四、验证方式

1. 打开应用，点击底部导航栏的"选车"
2. 页面顶部显示"AI智能选车"入口卡片
3. 点击卡片进入 AI 选车页面
4. 完成 5 步问卷后查看推荐结果
5. 确认可以正常重新测试

---

## AI 智能选车页面显示修复（2026-05-17）

### 一、问题描述
点击 AI 选车入口后，页面能预览但启动项目后点击进入却看不到任何内容。

### 二、问题根因分析

1. **缺少 NavDestination 包装**：在 HarmonyOS 的 Navigation 导航架构中，通过 `pushPath` 导航的页面需要使用 `NavDestination` 组件进行包装

2. **路由栈初始化问题**：`@Consume('pageInfos')` 在路由栈未正确传递时可能为 undefined

### 三、修复内容

#### 1. `features/buyingCar/src/main/ets/pages/AICarSelectPage.ets`

**问题**：缺少 NavDestination 包装，导致页面无法正常显示

**修复**：添加 NavDestination 组件包装并隐藏标题栏

```typescript
build() {
  NavDestination() {
    Column() {
      if (!this.showResults) {
        this.buildQuestionnaire();
      } else {
        this.buildResults();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5');
  }
  .hideTitleBar(true);
}
```

**问题**：路由栈未初始化可能导致 undefined

**修复**：为 @Consume 属性添加默认值

```typescript
@Consume('pageInfos') pageInfos: NavPathStack = new NavPathStack();
```

### 四、修复总结

| 文件 | 问题类型 | 修复方案 |
|------|----------|----------|
| AICarSelectPage.ets | 页面无法显示 | 添加 NavDestination 组件包装 |
| AICarSelectPage.ets | 路由栈未初始化 | 为 @Consume 添加默认值 |

### 五、验证方式

1. 启动应用，点击底部导航栏的"选车"
2. 点击"AI智能选车"入口卡片
3. 确认能正常显示问卷页面（预算、续航等问题）
4. 完成问卷后能正常显示推荐结果

---

## AI 智能选车推荐算法优化（2026-05-20）

### 一、优化目的
提升推荐算法的精准度，使推荐结果更符合用户的真实偏好。

### 二、优化策略

针对不同维度的特性，采用差异化的评分分布：

| 维度 | 特性 | 推荐分布 | 原因 |
|------|------|----------|------|
| 预算 | 连续区间，偏好低价 | 偏左截断正态分布 | 体现性价比偏好 |
| 续航 | 连续值，越长越好 | 指数分布（右递增） | 边际效益递减 |
| 车型 | 离散匹配 | 阶跃函数 | 硬性偏好，无中间状态 |
| 动力类型 | 离散，有替代性 | 偏好权重矩阵 | 体现类型替代性 |
| 配置功能 | 多选，越多越好 | 线性比例+奖励 | 直观且鼓励匹配 |

### 三、具体算法实现

#### 1. 预算评分（30%权重）

```typescript
private calculateBudgetScore(price: number, budgetMin: number, budgetMax: number): number {
  const center = budgetMin + (budgetMax - budgetMin) * 0.4;
  const sigma = (budgetMax - budgetMin) / 4;

  if (price >= budgetMin && price <= budgetMax) {
    const z = (price - center) / sigma;
    const score = Math.exp(-z * z / 2) * 100;
    return Math.round(Math.max(60, score));
  } else {
    let distance = price < budgetMin ? budgetMin - price : price - budgetMax;
    const decayRate = 50000;
    const score = Math.max(20, 100 - (distance / decayRate) * 30);
    return Math.round(score);
  }
}
```

**说明**：
- 中心值设为预算区间的40%位置（体现性价比偏好）
- 使用正态分布，区间内得分范围60-100分
- 区间外线性衰减，最多扣30分

#### 2. 续航评分（25%权重）

```typescript
private calculateRangeScore(range: number, requirement: number): number {
  if (range >= requirement) {
    const bonus = Math.min(20, Math.log(range / requirement) * 20);
    return Math.round(Math.min(100, 100 + bonus));
  } else {
    return Math.round((range / requirement) * 100);
  }
}
```

**说明**：
- 满足需求后，续航越长加分越多（最多+20分）
- 低于需求按比例扣分
- 使用对数函数实现边际效益递减

#### 3. 车型评分（20%权重）

```typescript
private calculateBodyTypeScore(carType: string, preferenceType: string): number {
  if (preferenceType === '' || preferenceType === 'any') {
    return 100;
  }
  return carType === preferenceType ? 100 : 30;
}
```

**说明**：
- 完全匹配得100分，不匹配得30分（保底分）
- 选择"无所谓"时得100分

#### 4. 动力类型评分（15%权重）

```typescript
private calculatePowerTypeScore(carPower: string, preferencePower: string): number {
  const powerMatrix: Record<string, Record<string, number>> = {
    '纯电动': { '纯电动': 100, '增程式': 60, '混合动力': 50 },
    '增程式': { '纯电动': 70, '增程式': 100, '混合动力': 60 },
    '混合动力': { '纯电动': 50, '增程式': 60, '混合动力': 100 }
  };
  return powerMatrix[preferencePower]?.[carPower] || 30;
}
```

**说明**：
- 使用偏好矩阵体现动力类型的替代性
- 选纯电的用户可能接受增程（60分）
- 选增程的用户对纯电接受度更高（70分）

#### 5. 配置功能评分（10%权重）

```typescript
private calculateFeatureScore(carFeatures: string[], userFeatures: string[]): number {
  const matched = userFeatures.filter(f => carFeatures.includes(f)).length;
  let score = Math.round((matched / userFeatures.length) * 100);
  
  if (matched >= 3) score += 5;
  if (matched === userFeatures.length) score += 10;
  
  return Math.min(100, score);
}
```

**说明**：
- 按匹配比例计算基础得分
- 匹配3项以上+5分奖励
- 全部匹配+10分奖励

### 四、修改的文件

| 文件 | 修改内容 |
|------|----------|
| [AICarRecommendService.ets](file:///c:\treatest\BTYOMI\BTYOMI\features\buyingCar\src\main\ets\service\AICarRecommendService.ets) | 重构 `calculateScore()` 方法，拆分为5个独立的评分函数 |

### 五、优化效果

1. **预算感知**：15-25万预算的用户，17万的车比24万的车得分更高
2. **续航偏好**：600km续航比500km续航明显更有优势
3. **类型替代**：选纯电的用户，增程式车型也能获得合理分数
4. **配置奖励**：具备更多用户关注配置的车辆获得额外加分

### 六、验证方式

1. 进入AI选车页面，选择不同的预算区间
2. 观察推荐结果是否符合预期的价格偏好
3. 选择不同的动力类型偏好，验证替代车型的得分
4. 选择多个配置功能，验证奖励机制是否生效

---

## AI 智能选车问卷交互修复（2026-05-21）

### 一、问题描述

发现三个交互问题：
1. **选项选中状态混乱**：选择"无所谓"后会影响下一题的选中状态
2. **匹配度显示重复**：推荐结果中既显示匹配度又显示评分，且数值不一致
3. **重新测试未重置**：点击重新测试后没有真正重置问卷，而是简单返回

### 二、问题根因分析

#### 问题1：选项选中状态混乱

**主要根因**：
1. **页面状态保留**：通过 `pushPath()` 跳转的页面实例不会被销毁，而是进入后台挂起状态，所有状态会自动保留
2. **选项值冲突**：q3 和 q4 的"无所谓"选项都使用相同的 value `'any'`，导致状态混淆
3. **@Consume 状态共享**：`@Consume('pageInfos')` 可能导致页面间状态共享

**问题链路**：
- 用户选择 q3 的"无所谓" → `bodyType = 'any'`
- 点击"下一步"进入 q4 → `powerType` 未被重置或被错误设置
- 由于 q4 的"无所谓" value 也是 `'any'`，导致 q4 的"无所谓"被自动选中

#### 问题2：匹配度显示重复

**根因**：`getMatchReasons()` 方法中包含了一句 `"综合评分：${car.score}分"`，但 `car.score` 是车辆固有的评分，与用户偏好计算出的匹配度不一致。

#### 问题3：重新测试未重置

**根因**：`resetPreferences()` 方法存在但没有被所有"重新测试"按钮调用，或者 `aboutToAppear()` 生命周期方法没有被正确实现。

### 三、修复内容

#### 1. 选项值唯一化

**问题**：q3 和 q4 的"无所谓"选项都使用相同的 value `'any'`

**修复**：为不同问题的"无所谓"选项使用不同的 value 值

```typescript
// 修复前
{ label: '无所谓', value: 'any' }  // q3
{ label: '无所谓', value: 'any' }  // q4

// 修复后
{ label: '无所谓', value: 'q3_any' }  // q3
{ label: '无所谓', value: 'q4_any' }  // q4
```

#### 2. 数据转换

**问题**：推荐算法期望的 'any' 值与 UI 层使用的 'q3_any'/'q4_any' 不匹配

**修复**：在调用推荐算法前，将特殊值转换回空字符串

```typescript
async executeRecommend() {
  // ... 其他代码
  
  // 创建用于推荐算法的 preferences 对象
  const preferencesForRecommend: UserPreferences = {
    budgetMin: this.preferences.budgetMin,
    budgetMax: this.preferences.budgetMax,
    rangeRequirement: this.preferences.rangeRequirement,
    bodyType: this.preferences.bodyType === 'q3_any' ? '' : this.preferences.bodyType,
    powerType: this.preferences.powerType === 'q4_any' ? '' : this.preferences.powerType,
    features: this.preferences.features
  };
  
  this.results = this.recommendService.recommend(preferencesForRecommend);
  // ... 其他代码
}
```

#### 3. 页面状态重置

**问题**：页面实例状态被保留，导致重新进入时状态不正确

**修复**：添加 `aboutToAppear()` 生命周期方法

```typescript
aboutToAppear() {
  this.currentStep = 0;
  this.preferences = {
    budgetMin: -1,
    budgetMax: -1,
    rangeRequirement: -1,
    bodyType: '',
    powerType: '',
    features: []
  };
  this.selectedFeatures = [];
  this.results = [];
  this.showResults = false;
  this.isLoading = false;
}
```

#### 4. 步骤状态隔离

**问题**：多步骤表单中，后续步骤的状态可能受前面步骤影响

**修复**：添加步骤状态重置方法

```typescript
// 进入下一步时重置后续步骤的状态
private resetNextStepPreferences(nextStep: number) {
  switch (nextStep) {
    case 3:
      this.preferences.powerType = '';
      this.selectedFeatures = [];
      this.preferences.features = [];
      break;
    // ... 其他步骤
  }
}

// 返回上一步时重置当前步骤的状态
private resetCurrentStepPreferences(currentStep: number) {
  switch (currentStep) {
    case 2:
      this.preferences.bodyType = '';
      break;
    // ... 其他步骤
  }
}
```

#### 5. 匹配度显示修复

**问题**：`getMatchReasons()` 方法中包含冗余的评分显示

**修复**：移除"综合评分：XX分"的显示，只保留匹配原因

```typescript
private getMatchReasons(car: CarInfo, preferences: UserPreferences): string[] {
  const reasons: string[] = [];
  
  if (preferences.budgetMin > 0 && preferences.budgetMax > 0 && 
      car.price >= preferences.budgetMin && car.price <= preferences.budgetMax) {
    reasons.push(`${car.brand}${car.model} 价格(${car.price / 10000}万)符合您的预算`);
  }
  
  if (preferences.rangeRequirement > 0 && car.range >= preferences.rangeRequirement) {
    reasons.push(`续航${car.range}公里，满足您的需求`);
  }
  
  if (preferences.bodyType !== '' && preferences.bodyType !== 'any' && 
      car.bodyType === preferences.bodyType) {
    reasons.push(`车型为${car.bodyType}，符合您的偏好`);
  }
  
  if (preferences.powerType !== '' && preferences.powerType !== 'any' && 
      car.powerType === preferences.powerType) {
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
```

#### 6. 编译错误修复

**问题**：ArkTS 不支持对象展开运算符 `...obj`

**修复**：使用显式的属性赋值方式

```typescript
// 错误
const obj = { ...this.preferences };

// 正确
const obj = {
  budgetMin: this.preferences.budgetMin,
  budgetMax: this.preferences.budgetMax,
  // ... 其他属性
};
```

### 四、修改的文件

| 文件 | 修改内容 |
|------|----------|
| AICarSelectPage.ets | 选项值唯一化、添加数据转换、页面状态重置、步骤状态隔离 |
| AICarRecommendService.ets | 修复匹配度显示 |

### 五、修复效果

1. **选项独立性**：每个问题的"无所谓"选项互不影响
2. **状态清洁性**：每次进入页面或重新测试时，状态都会被正确重置
3. **推荐准确性**：推荐结果只显示与用户偏好相关的匹配原因

### 六、验证方式

1. 选择 q3 的"无所谓"，点击下一步进入 q4，确认 q4 的"无所谓"未被选中
2. 完成问卷后点击"重新测试"，确认问卷被真正重置
3. 检查推荐结果，确认只显示匹配原因，不显示冗余的评分信息

---

## AI 智能选车推荐算法优化（2026-05-21 补充）

### 一、优化目的
确保推荐结果至少包含3个车型，优先推荐高分车型。

### 二、优化策略

**推荐逻辑**：
1. 为所有车型计算匹配度评分
2. 按评分从高到低排序
3. 筛选90分及以上的车型
4. 应用推荐策略：
   - 如果90分及以上的车型 ≥ 3辆：返回所有90分及以上的车型
   - 如果90分及以上的车型 < 3辆：返回所有90分及以上的车型，再从剩余车型中取排名靠前的补齐到3辆

### 三、具体实现

**修改文件**：[`AICarRecommendService.ets`](file:///c:\treatest\BTYOMI\BTYOMI\features\buyingCar\src\main\ets\service\AICarRecommendService.ets)

**修改方法**：`recommend()`

```typescript
public recommend(preferences: UserPreferences): RecommendResult[] {
  const results: RecommendResult[] = [];

  for (const car of this.carDatabase) {
    const score = this.calculateScore(car, preferences);
    const reasons = this.getMatchReasons(car, preferences);
    results.push({ car, score, reasons });
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
```

### 四、优化效果

1. **保证数量**：推荐结果至少包含3个车型
2. **优先高分**：90分及以上的车型优先推荐
3. **智能补齐**：高分车型不足时，从剩余车型中取排名靠前的补齐

### 五、验证方式

1. 测试不同的偏好组合，确认推荐结果至少包含3个车型
2. 选择偏好条件较宽松（如选择"无所谓"），验证是否推荐了所有90分及以上的车型
3. 选择偏好条件较严格，验证是否正确补齐了3个车型