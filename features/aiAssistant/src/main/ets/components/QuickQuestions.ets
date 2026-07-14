import { BehaviorTracker, UserBehaviorProfile, ProfileCompletenessResult } from '@ohos/common';

@Component
export struct QuickQuestions {
  onQuestionClick: (question: string) => void = () => {};
  @Prop questions: string[] = [];

  private behaviorTracker: BehaviorTracker = BehaviorTracker.getInstance();

  aboutToAppear(): void {
    if (this.questions.length === 0) {
      this.questions = this.generateQuestions();
    }
  }

  private generateQuestions(): string[] {
    this.behaviorTracker.init();
    const profile: UserBehaviorProfile = this.behaviorTracker.getProfile();
    const completeness: ProfileCompletenessResult = this.behaviorTracker.calculateCompleteness();

    const result: string[] = [];

    if (profile.priceRange.preferred.length > 0) {
      result.push(`${profile.priceRange.preferred}推荐`);
    } else {
      result.push('15万纯电SUV');
    }

    if (profile.bodyType.preferred.length > 0) {
      result.push(`热门${profile.bodyType.preferred}车型`);
    } else {
      result.push('续航最长的车型');
    }

    if (profile.powerType.preferred.length > 0) {
      result.push(`${profile.powerType.preferred}车型对比`);
    } else {
      result.push('家庭用车推荐');
    }

    if (profile.brandPreference.brands.length > 0) {
      result.push(`${profile.brandPreference.brands[0]}最新车型`);
    } else {
      result.push('性价比高的车型');
    }

    return result;
  }

  build() {
    Column() {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        ForEach(this.questions, (question: string) => {
          Button(question)
            .constraintSize({ maxWidth: 150 })
            .height(36)
            .backgroundColor('#F0F5FF')
            .fontColor('#007DFF')
            .borderRadius(18)
            .fontSize(14)
            .margin({ right: 12, bottom: 12 })
            .onClick(() => {
              this.onQuestionClick(question);
            });
        }, (question: string) => question);
      }
      .padding({ left: 16, right: 16, top: 10, bottom: 20 });
    }
    .width('100%');
  }
}
