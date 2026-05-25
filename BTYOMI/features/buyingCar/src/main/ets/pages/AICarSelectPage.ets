import { CommonConstants } from '@ohos/common';
import { AICarRecommendService } from '../service/AICarRecommendService';
import type { UserPreferences, RecommendResult } from '../model/AICarModel';

interface QuestionOptionType {
  label: string;
  value?: number | string;
  min?: number;
  max?: number;
}

interface Question {
  id: string;
  question: string;
  type: string;
  options: QuestionOptionType[];
}

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
  @Consume('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @State currentStep: number = 0;
  @State preferences: UserPreferences = {
    budgetMin: -1,
    budgetMax: -1,
    rangeRequirement: -1,
    bodyType: '',
    powerType: '',
    features: []
  };
  @State selectedFeatures: string[] = [];
  @State results: RecommendResult[] = [];
  @State showResults: boolean = false;
  @State isLoading: boolean = false;

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

  private questions: Question[] = [
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
        { label: '无所谓', value: 'q3_any' }
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
        { label: '无所谓', value: 'q4_any' }
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

  private recommendService: AICarRecommendService = AICarRecommendService.getInstance();

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

  @Builder
  buildQuestionnaire() {
    Column({ space: 20 }) {
      this.buildHeader();
      this.buildProgress();
      
      Column({ space: 20 }) {
        Text(this.getCurrentQuestionText())
          .fontSize(18)
          .fontWeight(700)
          .textAlign(TextAlign.Center)
          .width('100%');
        
        this.buildCurrentQuestionOptions();
      }
      .width('100%')
      .padding({ top: 30 });
      
      this.buildNavigationButtons();
    }
    .width('100%')
    .padding({ top: CommonConstants.PUBLIC_SPACE, left: CommonConstants.PUBLIC_SPACE, right: CommonConstants.PUBLIC_SPACE });
  }

  @Builder
  buildHeader() {
    Row({ space: 12 }) {
      Image($r('app.media.chevron_backward'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          this.pageInfos.pop();
        });

      Text('AI智能选车')
        .fontSize(18)
        .fontWeight(700)
        .textAlign(TextAlign.Center)
        .flexGrow(1);

      Blank()
        .width(24);
    }
    .width('100%');
  }

  @Builder
  buildProgress() {
    Row({ space: 8 }) {
      ForEach([0, 1, 2, 3, 4], (index: number) => {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(index < this.currentStep ? 24 : 20)
            .height(index < this.currentStep ? 24 : 20)
            .fill(index < this.currentStep ? '#2ECC71' : '#DDDDDD');

          Text((index + 1).toString())
            .fontSize(index < this.currentStep ? 12 : 10)
            .fontWeight(700)
            .fontColor(index < this.currentStep ? '#FFFFFF' : '#999999');
        }

        if (index < 4) {
          Line()
            .width(30)
            .height(2)
            .stroke(index < this.currentStep ? '#2ECC71' : '#DDDDDD');
        }
      });
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 20 });
  }

  @Builder
  buildQuestionContent() {
    Column({ space: 20 }) {
      Text(this.getCurrentQuestionText())
        .fontSize(18)
        .fontWeight(700)
        .textAlign(TextAlign.Center)
        .width('100%');

      this.buildCurrentQuestionOptions();
    }
    .width('100%')
    .padding({ top: 30 });
  }

  private getCurrentQuestionText(): string {
    return this.questions[this.currentStep]?.question || '';
  }

  @Builder
  buildCurrentQuestionOptions() {
    if (this.questions[this.currentStep].type === 'single' || this.questions[this.currentStep].type === 'range') {
      Column({ space: 12 }) {
        Row({ space: 12 }) {
          ForEach(this.questions[this.currentStep].options.slice(0, 2), (option: QuestionOptionType) => {
            this.buildOptionItem(option, this.questions[this.currentStep]);
          });
        }
        Row({ space: 12 }) {
          ForEach(this.questions[this.currentStep].options.slice(2, 4), (option: QuestionOptionType) => {
            this.buildOptionItem(option, this.questions[this.currentStep]);
          });
        }
      }
    } else if (this.questions[this.currentStep].type === 'multiple') {
      Column({ space: 12 }) {
        ForEach(this.questions[this.currentStep].options, (option: QuestionOptionType) => {
          this.buildMultiSelectItem(option);
        });
      };
    }
  }

  @Builder
  buildOptionItem(option: QuestionOptionType, question: Question) {
    Column({ space: 8 }) {
      Text(option.label)
        .fontSize(14)
        .fontColor(this.isOptionSelected(option, question) ? '#2ECC71' : '#333333');

      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(20)
          .height(20)
          .stroke('#DDDDDD')
          .fill(this.isOptionSelected(option, question) ? '#2ECC71' : '#FFFFFF');

        if (this.isOptionSelected(option, question)) {
          Circle()
            .width(8)
            .height(8)
            .fill('#FFFFFF');
        }
      }
    }
    .width('45%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isOptionSelected(option, question) ? '#E8F5E9' : '#FFFFFF')
    .borderRadius(12)
    .onClick(() => this.selectOption(option, question));
  }

  private isOptionSelected(option: QuestionOptionType, question: Question): boolean {
    if (question.type === 'range') {
      return this.preferences.budgetMin === option.min && this.preferences.budgetMax === option.max;
    }
    switch (question.id) {
      case 'q3':
        if (this.preferences.bodyType === '') return false;
        return this.preferences.bodyType === option.value;
      case 'q4':
        if (this.preferences.powerType === '') return false;
        return this.preferences.powerType === option.value;
      case 'q2':
        return this.preferences.rangeRequirement > 0 && this.preferences.rangeRequirement === option.value;
      default:
        return false;
    }
  }

  private selectOption(option: QuestionOptionType, question: Question) {
    switch (question.id) {
      case 'q1':
        this.preferences.budgetMin = option.min || 0;
        this.preferences.budgetMax = option.max || 1000000;
        break;
      case 'q2':
        this.preferences.rangeRequirement = option.value as number || 400;
        break;
      case 'q3':
        this.preferences.bodyType = option.value as string || 'any';
        break;
      case 'q4':
        this.preferences.powerType = option.value as string || 'any';
        break;
    }
  }

  private resetNextStepPreferences(nextStep: number) {
    switch (nextStep) {
      case 1:
        this.preferences.rangeRequirement = -1;
        this.preferences.bodyType = '';
        this.preferences.powerType = '';
        this.selectedFeatures = [];
        this.preferences.features = [];
        break;
      case 2:
        this.preferences.bodyType = '';
        this.preferences.powerType = '';
        this.selectedFeatures = [];
        this.preferences.features = [];
        break;
      case 3:
        this.preferences.powerType = '';
        this.selectedFeatures = [];
        this.preferences.features = [];
        break;
      case 4:
        this.selectedFeatures = [];
        this.preferences.features = [];
        break;
      case 5:
        break;
    }
  }

  private resetCurrentStepPreferences(currentStep: number) {
    switch (currentStep) {
      case 0:
        this.preferences.budgetMin = -1;
        this.preferences.budgetMax = -1;
        break;
      case 1:
        this.preferences.rangeRequirement = -1;
        break;
      case 2:
        this.preferences.bodyType = '';
        break;
      case 3:
        this.preferences.powerType = '';
        break;
      case 4:
        this.selectedFeatures = [];
        this.preferences.features = [];
        break;
    }
  }

  @Builder
  buildMultiSelectItem(option: QuestionOptionType) {
    Row({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(24)
          .height(24)
          .stroke('#DDDDDD')
          .fill(this.selectedFeatures.includes(option.value as string) ? '#2ECC71' : '#FFFFFF');

        if (this.selectedFeatures.includes(option.value as string)) {
          Text('√')
            .fontSize(14)
            .fontWeight(700)
            .fontColor('#FFFFFF');
        }
      }

      Text(option.label)
        .fontSize(16)
        .fontColor('#333333');
    }
    .width('100%')
    .height(48)
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding({ left: 16 })
    .onClick(() => this.toggleFeature(option.value as string));
  }

  private toggleFeature(feature: string) {
    const index = this.selectedFeatures.indexOf(feature);
    if (index > -1) {
      this.selectedFeatures.splice(index, 1);
    } else {
      this.selectedFeatures.push(feature);
    }
    this.preferences.features = [...this.selectedFeatures];
  }

  @Builder
  buildNavigationButtons() {
    Row({ space: 12 }) {
      if (this.currentStep > 0) {
        Button('上一步')
          .width('45%')
          .height(48)
          .backgroundColor('#FFFFFF')
          .fontColor('#333333')
          .borderRadius(24)
          .onClick(() => {
            this.resetCurrentStepPreferences(this.currentStep);
            this.currentStep--;
          });
      } else {
        Blank()
          .width('45%');
      }

      if (this.currentStep < 4) {
        Button('下一步')
          .width('45%')
          .height(48)
          .backgroundColor('#2ECC71')
          .fontColor('#FFFFFF')
          .borderRadius(24)
          .onClick(() => {
            // 重置后续步骤的状态
            this.resetNextStepPreferences(this.currentStep + 1);
            this.currentStep++;
          });
      } else {
        Button('开始推荐')
          .width('45%')
          .height(48)
          .backgroundColor('#2ECC71')
          .fontColor('#FFFFFF')
          .borderRadius(24)
          .onClick(() => {
            this.executeRecommend();
          });
      }
    }
    .width('100%')
    .padding({ top: 20, bottom: 30 });
  }

  async executeRecommend() {
    this.isLoading = true;
    await new Promise<void>((resolve) => setTimeout(resolve, 1500));
    
    await this.recommendService.initialize();
    
    // 创建一个新的 preferences 对象，用于推荐算法
    const preferencesForRecommend: UserPreferences = {
      budgetMin: this.preferences.budgetMin,
      budgetMax: this.preferences.budgetMax,
      rangeRequirement: this.preferences.rangeRequirement,
      bodyType: this.preferences.bodyType === 'q3_any' ? '' : this.preferences.bodyType,
      powerType: this.preferences.powerType === 'q4_any' ? '' : this.preferences.powerType,
      features: this.preferences.features
    };
    
    this.results = this.recommendService.recommend(preferencesForRecommend);
    
    if (this.results.length === 0) {
      const carList = this.recommendService.getCarList();
      const fallbackResults: RecommendResult[] = [];
      for (const car of carList) {
        const result: RecommendResult = {
          car: car,
          score: car.score,
          reasons: [`${car.brand}${car.model} 综合评分：${car.score}分`]
        };
        fallbackResults.push(result);
      }
      fallbackResults.sort((a, b) => b.score - a.score);
      this.results = fallbackResults.slice(0, 3);
    }
    
    this.showResults = true;
    this.isLoading = false;
  }

  @Builder
  buildResults() {
    Column({ space: 20 }) {
      this.buildResultHeader();
      if (this.isLoading) {
        this.buildLoading();
      } else {
        this.buildResultList();
      }
    }
    .width('100%')
    .padding({ top: CommonConstants.PUBLIC_SPACE, left: CommonConstants.PUBLIC_SPACE, right: CommonConstants.PUBLIC_SPACE });
  }

  private resetPreferences() {
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
    this.currentStep = 0;
  }

  @Builder
  buildResultHeader() {
    Row({ space: 12 }) {
      Image($r('app.media.chevron_backward'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          this.resetPreferences();
        });

      Text('推荐结果')
        .fontSize(18)
        .fontWeight(700)
        .textAlign(TextAlign.Center)
        .flexGrow(1);

      Button('重新测试')
        .fontSize(14)
        .fontColor('#2ECC71')
        .backgroundColor('transparent')
        .onClick(() => {
          this.resetPreferences();
        });
    }
    .width('100%');
  }

  @Builder
  buildLoading() {
    Column({ space: 16 }) {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#2ECC71');

      Text('AI正在分析您的需求...')
        .fontSize(16)
        .fontColor('#666666');
    }
    .width('100%')
    .height('60%')
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  buildResultList() {
    Column({ space: 16 }) {
      if (this.results.length === 0) {
        Column({ space: 16 }) {
          Image($r('app.media.search'))
            .width(64)
            .height(64)
            .fillColor('#DDDDDD');

          Text('暂无推荐结果')
            .fontSize(16)
            .fontColor('#999999');

          Button('重新测试')
            .width(120)
            .height(40)
            .backgroundColor('#2ECC71')
            .fontColor('#FFFFFF')
            .borderRadius(20)
            .onClick(() => {
              this.resetPreferences();
            });
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center);
      } else {
        List({ space: 16 }) {
          ForEach(this.results, (result: RecommendResult, index: number) => {
            ListItem() {
              Column({ space: 12 }) {
                Row({ space: 16 }) {
                  Stack({ alignContent: Alignment.TopStart }) {
                    Image($r('app.media.brand_car1'))
                      .width(100)
                      .height(80)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8);

                    Stack({ alignContent: Alignment.Center }) {
                      Text((index + 1).toString())
                        .fontSize(14)
                        .fontWeight(700)
                        .fontColor('#FFFFFF');
                    }
                    .width(24)
                    .height(24)
                    .backgroundColor('#2ECC71')
                    .borderRadius({ topLeft: 8, bottomRight: 8 });
                  }

                  Column({ space: 8 }) {
                    Text(`${result.car.brand} ${result.car.model}`)
                      .fontSize(16)
                      .fontWeight(700)
                      .fontColor('#333333');

                    Row({ space: 16 }) {
                      Text(`${(result.car.price / 10000).toFixed(1)}万`)
                        .fontSize(14)
                        .fontColor('#E74C3C');

                      Text(`${result.car.range}km`)
                        .fontSize(14)
                        .fontColor('#3498DB');

                      Text(`${result.car.powerType}`)
                        .fontSize(14)
                        .fontColor('#9B59B6');
                    }

                    Stack({ alignContent: Alignment.Center }) {
                      Text(`匹配度 ${result.score}%`)
                        .fontSize(12)
                        .fontWeight(700)
                        .fontColor(result.score >= 80 ? '#2ECC71' : result.score >= 60 ? '#F39C12' : '#E74C3C');
                    }
                    .width(80)
                    .height(28)
                    .backgroundColor('rgba(46, 204, 113, 0.1)')
                    .borderRadius(14);
                  }
                }

                Column({ space: 4 }) {
                  ForEach(result.reasons.slice(0, 3), (reason: string) => {
                    Row({ space: 8 }) {
                      Image($r('app.media.search'))
                        .width(14)
                        .height(14)
                        .fillColor('#2ECC71');

                      Text(reason)
                        .fontSize(12)
                        .fontColor('#666666');
                    }
                  });
                }
                .padding({ left: 16 })
                .backgroundColor('#FAFAFA')
                .borderRadius(8)
                .padding({ top: 8, bottom: 8 });
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .padding({ top: 12, bottom: 12, left: 12, right: 12 });
            }
          });
        }
        .width('100%')
        .layoutWeight(1)
        .height('100%');
      }
    }
    .width('100%');
  }
}