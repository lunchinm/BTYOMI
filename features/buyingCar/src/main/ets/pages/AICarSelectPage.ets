import { CommonConstants } from '@ohos/common';
import { AICarRecommendService } from '../service/AICarRecommendService';
import type { UserPreferences, RecommendResult, Question, CarInfo, AICarRecommendation } from '../model/AICarModel';

interface QuestionOptionType {
  label: string;
  value?: number | string;
  min?: number;
  max?: number;
}

function isCarInfo(car: CarInfo | AICarRecommendation): boolean {
  return (car as CarInfo).id !== undefined;
}

function getCarImage(car: CarInfo | AICarRecommendation): string {
  if (isCarInfo(car)) {
    return (car as CarInfo).image;
  }
  return (car as AICarRecommendation).image;
}

function getCarBrand(car: CarInfo | AICarRecommendation): string {
  if (isCarInfo(car)) {
    return (car as CarInfo).brand;
  }
  return (car as AICarRecommendation).brand;
}

function getCarModel(car: CarInfo | AICarRecommendation): string {
  if (isCarInfo(car)) {
    return (car as CarInfo).model;
  }
  return (car as AICarRecommendation).model;
}

function getCarPrice(car: CarInfo | AICarRecommendation): string {
  if (isCarInfo(car)) {
    return `${((car as CarInfo).price / 10000).toFixed(1)}万`;
  }
  return (car as AICarRecommendation).price;
}

function getCarRange(car: CarInfo | AICarRecommendation): string {
  if (isCarInfo(car)) {
    return `${(car as CarInfo).range}km`;
  }
  return (car as AICarRecommendation).range;
}

function getCarPowerType(car: CarInfo | AICarRecommendation): string {
  if (isCarInfo(car)) {
    return (car as CarInfo).powerType;
  }
  return (car as AICarRecommendation).powerType;
}

function getCarResourceName(car: CarInfo | AICarRecommendation): string {
  const imageName: string = getCarImage(car);
  if (imageName === '') {
    return 'app.media.brand_car1';
  }
  return 'app.media.' + imageName;
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
    naturalLanguageDescription: ''
  };
  @State results: RecommendResult[] = [];
  @State showResults: boolean = false;
  @State isLoading: boolean = false;
  @State naturalLanguageInput: string = '';

  aboutToAppear() {
    this.currentStep = 0;
    this.preferences = {
      budgetMin: -1,
      budgetMax: -1,
      rangeRequirement: -1,
      bodyType: '',
      powerType: '',
      naturalLanguageDescription: ''
    };
    this.results = [];
    this.showResults = false;
    this.isLoading = false;
    this.naturalLanguageInput = '';
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
      question: '请用自然语言描述您的其他需求',
      type: 'text',
      placeholder: '例如：我需要一辆适合家庭使用的车，空间要大，最好有自动驾驶功能，安全性要好...'
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

        if (this.questions[this.currentStep].type === 'text') {
          this.buildTextQuestion();
        } else {
          this.buildChoiceQuestion();
        }
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

  private getCurrentQuestionText(): string {
    return this.questions[this.currentStep]?.question || '';
  }

  @Builder
  buildChoiceQuestion() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        ForEach(this.questions[this.currentStep].options?.slice(0, 2) || [], (option: QuestionOptionType) => {
          this.buildOptionItem(option, this.questions[this.currentStep]);
        });
      }
      Row({ space: 12 }) {
        ForEach(this.questions[this.currentStep].options?.slice(2, 4) || [], (option: QuestionOptionType) => {
          this.buildOptionItem(option, this.questions[this.currentStep]);
        });
      }
    }
  }

  @Builder
  buildTextQuestion() {
    TextArea({ placeholder: this.questions[this.currentStep].placeholder })
      .width('100%')
      .height(150)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
      .fontSize(14)
      .onChange((value: string) => {
        this.naturalLanguageInput = value;
        this.preferences.naturalLanguageDescription = value;
      });
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
        this.preferences.bodyType = option.value as string || 'q3_any';
        break;
      case 'q4':
        this.preferences.powerType = option.value as string || 'q4_any';
        break;
    }
  }

  private resetNextStepPreferences(nextStep: number) {
    switch (nextStep) {
      case 1:
        this.preferences.rangeRequirement = -1;
        this.preferences.bodyType = '';
        this.preferences.powerType = '';
        this.naturalLanguageInput = '';
        this.preferences.naturalLanguageDescription = '';
        break;
      case 2:
        this.preferences.bodyType = '';
        this.preferences.powerType = '';
        this.naturalLanguageInput = '';
        this.preferences.naturalLanguageDescription = '';
        break;
      case 3:
        this.preferences.powerType = '';
        this.naturalLanguageInput = '';
        this.preferences.naturalLanguageDescription = '';
        break;
      case 4:
        this.naturalLanguageInput = '';
        this.preferences.naturalLanguageDescription = '';
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
        this.naturalLanguageInput = '';
        this.preferences.naturalLanguageDescription = '';
        break;
    }
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
    try {
      await this.recommendService.initialize();

      const preferencesForRecommend: UserPreferences = {
        budgetMin: this.preferences.budgetMin,
        budgetMax: this.preferences.budgetMax,
        rangeRequirement: this.preferences.rangeRequirement,
        bodyType: this.preferences.bodyType === 'q3_any' ? '' : this.preferences.bodyType,
        powerType: this.preferences.powerType === 'q4_any' ? '' : this.preferences.powerType,
        naturalLanguageDescription: this.preferences.naturalLanguageDescription
      };

      this.results = await this.recommendService.recommend(preferencesForRecommend);
      this.showResults = true;
    } catch (error) {
      AlertDialog.show({
        title: '推荐失败',
        message: `无法获取推荐结果：${error.message}`,
        confirm: {
          value: '确定',
          action: () => {
            this.isLoading = false;
          }
        }
      });
    } finally {
      this.isLoading = false;
    }
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
      naturalLanguageDescription: ''
    };
    this.naturalLanguageInput = '';
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
                    Image($r(getCarResourceName(result.car)))
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
                    Text(`${getCarBrand(result.car)} ${getCarModel(result.car)}`)
                      .fontSize(16)
                      .fontWeight(700)
                      .fontColor('#333333');

                    Row({ space: 16 }) {
                      Text(getCarPrice(result.car))
                        .fontSize(14)
                        .fontColor('#E74C3C');

                      Text(getCarRange(result.car))
                        .fontSize(14)
                        .fontColor('#3498DB');

                      Text(getCarPowerType(result.car))
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
