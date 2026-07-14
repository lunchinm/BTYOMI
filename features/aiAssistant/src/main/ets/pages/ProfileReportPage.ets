import { BehaviorTracker, UserBehaviorProfile, ProfileCompletenessResult } from '@ohos/common';
import { ChatService } from '../service/ChatService';

@Component
export struct ProfileReportPage {
  @Consume('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageProp('avoidArea') topHeight: number = 0;

  @State profile: UserBehaviorProfile | null = null;
  @State completeness: ProfileCompletenessResult | null = null;

  private behaviorTracker: BehaviorTracker = BehaviorTracker.getInstance();

  aboutToAppear(): void {
    this.profile = this.behaviorTracker.getProfile();
    this.completeness = this.behaviorTracker.calculateCompleteness();
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('←')
            .fontSize(20)
            .fontColor('#333333')
            .padding({ left: 8, right: 8 })
            .onClick(() => {
              this.pageInfos.pop();
            });

          Text('用户偏好报告')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center);

          Text('')
            .width(36);
        }
        .width('100%')
        .height(56)
        .padding({ left: 8, right: 16 })
        .alignItems(VerticalAlign.Center);

        Scroll() {
          Column({ space: 16 }) {
            this.buildCompletenessSection();

            if (this.profile) {
              this.buildProfileSection();
            }

            Button('清除画像数据')
              .width('80%')
              .height(44)
              .backgroundColor('#FF4D4F')
              .fontColor('#FFFFFF')
              .borderRadius(22)
              .margin({ top: 8, bottom: 24 })
              .onClick(() => {
                this.behaviorTracker.clearProfile();
                this.profile = this.behaviorTracker.getProfile();
                this.completeness = this.behaviorTracker.calculateCompleteness();
              });
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 });
        }
        .width('100%')
        .layoutWeight(1);
      }
      .width('100%')
      .height('100%')
      .padding({ top: this.topHeight });
    }
    .hideTitleBar(true);
  }

  @Builder
  buildCompletenessSection() {
    Column({ space: 12 }) {
      Text('信息完整度')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%');

      if (this.completeness) {
        Row() {
          Progress({ value: this.completeness.overallScore * 100, total: 100, type: ProgressType.Linear })
            .width('60%')
            .color('#2ECC71')
            .style({ strokeWidth: 8 });

          Text(`${Math.round(this.completeness.overallScore * 100)}%`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2ECC71')
            .margin({ left: 12 });
        }
        .width('100%');

        Column({ space: 8 }) {
          this.buildDimensionBar('预算', this.completeness.priceRangeScore);
          this.buildDimensionBar('车型', this.completeness.bodyTypeScore);
          this.buildDimensionBar('动力', this.completeness.powerTypeScore);
          this.buildDimensionBar('品牌', this.completeness.brandScore);
          this.buildDimensionBar('功能', this.completeness.featureScore);
        }
        .width('100%');

        if (this.completeness.missingDimensions.length > 0) {
          Column() {
            Text('待完善：')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ bottom: 4 });

            Text(this.formatMissingDimensions(this.completeness.missingDimensions))
              .fontSize(13)
              .fontColor('#F39C12');
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFBEB')
          .borderRadius(8);
        }
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16);
  }

  @Builder
  buildDimensionBar(label: string, score: number) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#666666')
        .width(40);

      Progress({ value: score * 100, total: 100, type: ProgressType.Linear })
        .width('50%')
        .color(score > 0 ? '#3498DB' : '#E0E0E0')
        .style({ strokeWidth: 6 });

      Text(`${Math.round(score * 100)}%`)
        .fontSize(12)
        .fontColor(score > 0 ? '#3498DB' : '#CCCCCC')
        .margin({ left: 8 });
    }
    .width('100%');
  }

  @Builder
  buildProfileSection() {
    Column({ space: 12 }) {
      Text('偏好详情')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%');

      if (this.profile) {
        this.buildPreferenceItem('偏好价位', this.profile.priceRange.preferred, this.profile.priceRange.confidence);
        this.buildPreferenceItem('偏好车型', this.profile.bodyType.preferred, this.profile.bodyType.confidence);
        this.buildPreferenceItem('偏好动力', this.profile.powerType.preferred, this.profile.powerType.confidence);

        if (this.profile.brandPreference.brands.length > 0) {
          this.buildPreferenceItem('关注品牌', this.profile.brandPreference.brands.join('、'), 0.8);
        }

        if (this.profile.featurePreference.features.length > 0) {
          this.buildPreferenceItem('关注功能', this.profile.featurePreference.features.join('、'), 0.8);
        }

        Column() {
          Text('行为统计')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 });

          Row() {
            Column() {
              Text(`${this.profile.stats.totalViews}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333');
              Text('浏览次数')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 });
            }
            .layoutWeight(1);

            Column() {
              Text(`${this.profile.stats.totalFavorites}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333');
              Text('收藏数')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 });
            }
            .layoutWeight(1);

            Column() {
              Text(this.formatLastActive(this.profile.stats.lastActiveTime))
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333');
              Text('最后活跃')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 });
            }
            .layoutWeight(1);
          }
          .width('100%');
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F5F5F5')
        .borderRadius(8);
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16);
  }

  @Builder
  buildPreferenceItem(label: string, value: string, confidence: number) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#999999')
        .width(60);

      Text(value.length > 0 ? value : '未设置')
        .fontSize(14)
        .fontColor(value.length > 0 ? '#333333' : '#CCCCCC')
        .layoutWeight(1);

      if (value.length > 0 && confidence > 0) {
        Stack({ alignContent: Alignment.Center }) {
          Text(`${Math.round(confidence * 100)}%`)
            .fontSize(10)
            .fontColor('#2ECC71');
        }
        .width(40)
        .height(20)
        .backgroundColor('rgba(46, 204, 113, 0.1)')
        .borderRadius(10);
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 });
  }

  private formatMissingDimensions(dimensions: string[]): string {
    const dimensionMap: Record<string, string> = {
      'priceRange': '预算范围',
      'bodyType': '车身类型',
      'powerType': '动力类型',
      'brand': '品牌偏好',
      'feature': '功能偏好'
    };
    const labels: string[] = [];
    for (let i = 0; i < dimensions.length; i++) {
      const label = dimensionMap[dimensions[i]];
      if (label) {
        labels.push(label);
      }
    }
    return labels.join('、');
  }

  private formatLastActive(timestamp: number): string {
    if (timestamp === 0) {
      return '从未';
    }
    const diff: number = Date.now() - timestamp;
    const diffMinutes: number = Math.floor(diff / 60000);
    if (diffMinutes < 1) {
      return '刚刚';
    }
    if (diffMinutes < 60) {
      return `${diffMinutes}分钟前`;
    }
    const diffHours: number = Math.floor(diffMinutes / 60);
    if (diffHours < 24) {
      return `${diffHours}小时前`;
    }
    const diffDays: number = Math.floor(diffHours / 24);
    return `${diffDays}天前`;
  }
}
