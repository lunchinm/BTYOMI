import { ChatMessage, MessageType, CarInfo, ComparisonData, RecommendResult } from '../model/ChatModel';
import pasteboard from '@ohos.pasteboard';
import hilog from '@ohos.hilog';

@Component
export struct ChatMessageBubble {
  @Prop message: ChatMessage = {
    id: '',
    role: 'user',
    type: MessageType.TEXT,
    content: '',
    timestamp: Date.now()
  };
  onRetry: (message: ChatMessage) => void = () => {};
  onOptionClick: (option: string) => void = () => {};
  onFavoriteCar: (car: CarInfo, isFavorited: boolean) => void = () => {};

  private textController: TextController = new TextController();
  @State private selectionStart: number = -1;
  @State private selectionEnd: number = -1;
  @State private favoritedCarIds: number[] = [];
  private readonly LOG_DOMAIN: number = 0xF011;
  private readonly LOG_TAG: string = 'ChatBubble';

  private isCarFavorited(carId: number): boolean {
    for (let i = 0; i < this.favoritedCarIds.length; i++) {
      if (this.favoritedCarIds[i] === carId) {
        return true;
      }
    }
    return false;
  }

  private toggleFavorite(carId: number): void {
    const newArr: number[] = [];
    let found: boolean = false;
    for (let i = 0; i < this.favoritedCarIds.length; i++) {
      if (this.favoritedCarIds[i] === carId) {
        found = true;
      } else {
        newArr.push(this.favoritedCarIds[i]);
      }
    }
    if (!found) {
      newArr.push(carId);
    }
    this.favoritedCarIds = newArr;
  }

  private copyToClipboard(text: string): void {
    const pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteData);
  }

  private clearSelection(): void {
    this.textController.closeSelectionMenu();
    this.selectionStart = -1;
    this.selectionEnd = -1;
  }

  build() {
    Column() {
      if (this.message.role === 'user') {
        this.buildUserBubble();
      } else {
        this.buildAssistantBubble();
      }
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
    .onClick(() => {
      if (this.selectionStart >= 0 || this.selectionEnd >= 0) {
        this.clearSelection();
      }
    })
  }

  @Builder
  buildUserBubble() {
    Row() {
      Column() {
        Text(this.message.content, { controller: this.textController })
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius({ topLeft: 18, topRight: 4, bottomLeft: 18, bottomRight: 18 })
          .fontSize(15)
          .maxLines(10)
          .copyOption(CopyOptions.LocalDevice)
          .selection(this.selectionStart, this.selectionEnd)
          .onTextSelectionChange((start: number, end: number) => {
            this.selectionStart = start;
            this.selectionEnd = end;
          });
      }
      .constraintSize({ maxWidth: '75%' })
      .alignItems(HorizontalAlign.End);

      Column() {
        Text('👤')
          .fontSize(20)
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .borderRadius(18)
          .backgroundColor('#E8E8E8');
      }
      .width(36)
      .height(36)
      .margin({ left: 8 })
      .flexShrink(0);
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.End)
    .padding({ left: 16, right: 16 });
  }

  @Builder
  buildAssistantBubble() {
    Column() {
      Row() {
        Column() {
          Text('🤖')
            .fontSize(20)
            .width(36)
            .height(36)
            .textAlign(TextAlign.Center)
            .borderRadius(18)
            .backgroundColor('#E8E8E8');
        }
        .width(36)
        .height(36)
        .margin({ right: 8 })
        .flexShrink(0);

        Column() {
          if (this.message.type === MessageType.LOADING) {
            this.buildLoadingIndicator();
          } else if (this.message.type === MessageType.ERROR) {
            this.buildErrorIndicator();
          } else if (this.message.type === MessageType.COMPARISON && this.message.comparison) {
            this.buildComparisonMessage();
          } else {
            Text(this.message.content, { controller: this.textController })
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor('#F5F5F5')
              .fontColor('#333333')
              .borderRadius({ topLeft: 4, topRight: 18, bottomLeft: 18, bottomRight: 18 })
              .fontSize(15)
              .copyOption(CopyOptions.LocalDevice)
              .selection(this.selectionStart, this.selectionEnd)
              .onTextSelectionChange((start: number, end: number) => {
                this.selectionStart = start;
                this.selectionEnd = end;
              });
          }

          if (this.message.type !== MessageType.LOADING && this.message.type !== MessageType.ERROR) {
            Text('复制')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 2 })
              .onClick(() => {
                this.copyToClipboard(this.message.content);
              });
          }
        }
        .constraintSize({ maxWidth: '75%' })
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start);

      if (this.message.recommendResults && this.message.recommendResults.length > 0) {
        this.buildRecommendCards(this.message.recommendResults);
      }

      if (this.message.options && this.message.options.length > 0) {
        Row() {
          this.buildOptionsButtons();
        }
        .margin({ left: 44 });
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 });
  }

  @Builder
  buildRecommendCards(results: RecommendResult[]) {
    Column({ space: 8 }) {
      ForEach(results, (result: RecommendResult, index: number) => {
        this.buildRecommendCard(result, index);
      }, (result: RecommendResult, index: number) => `${result.car.id}_${index}`);
    }
    .width('85%')
    .margin({ top: 8, left: 44 });
  }

  @Builder
  buildRecommendCard(result: RecommendResult, index: number) {
    Column({ space: 6 }) {
      Row({ space: 8 }) {
        Stack({ alignContent: Alignment.TopStart }) {
          Text('🚙')
            .fontSize(28)
            .width(56)
            .height(48)
            .textAlign(TextAlign.Center)
            .backgroundColor('#F0F5FF')
            .borderRadius(6);

          Stack({ alignContent: Alignment.Center }) {
            Text((index + 1).toString())
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
          }
          .width(18)
          .height(18)
          .backgroundColor('#2ECC71')
          .borderRadius({ topLeft: 6, bottomRight: 6 });
        }

        Column({ space: 4 }) {
          Text(`${result.car.brand} ${result.car.model}`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');

          Row({ space: 8 }) {
            Text(`${(result.car.price / 10000).toFixed(1)}万`)
              .fontSize(12)
              .fontColor('#E74C3C')
              .fontWeight(FontWeight.Medium);

            Text(`${result.car.range}km`)
              .fontSize(12)
              .fontColor('#3498DB');

            Text(result.car.powerType)
              .fontSize(12)
              .fontColor('#9B59B6');
          }

          Stack({ alignContent: Alignment.Center }) {
            Text(`匹配度 ${result.score}%`)
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor(result.score >= 80 ? '#2ECC71' : result.score >= 60 ? '#F39C12' : '#E74C3C');
          }
          .width(64)
          .height(20)
          .backgroundColor('rgba(46, 204, 113, 0.1)')
          .borderRadius(10);
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1);

        Column() {
          Text(this.isCarFavorited(result.car.id) ? '❤️' : '♡')
            .fontSize(18)
            .fontColor(this.isCarFavorited(result.car.id) ? '#E74C3C' : '#CCCCCC')
            .onClick(() => {
              hilog.info(this.LOG_DOMAIN, this.LOG_TAG, `♡ clicked: car=${result.car.brand} ${result.car.model} id=${result.car.id}`);
              this.toggleFavorite(result.car.id);
              this.onFavoriteCar(result.car, this.isCarFavorited(result.car.id));
            });
        }
        .width(28)
        .height(28)
        .justifyContent(FlexAlign.Center);
      }
      .width('100%');

      if (result.reasons.length > 0) {
        Column({ space: 3 }) {
          ForEach(result.reasons.slice(0, 2), (reason: string) => {
            Row({ space: 4 }) {
              Text('✓')
                .fontSize(11)
                .fontColor('#2ECC71')
                .fontWeight(FontWeight.Bold);

              Text(reason)
                .fontSize(11)
                .fontColor('#666666');
            }
          }, (reason: string) => reason);
        }
        .width('100%')
        .padding({ left: 6, top: 4, bottom: 4 })
        .backgroundColor('#FAFAFA')
        .borderRadius(4);
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .padding({ left: 10, right: 10, top: 10, bottom: 10 });
  }

  @Builder
  buildComparisonMessage() {
    Column() {
      Text(this.message.content, { controller: this.textController })
        .padding({ left: 16, right: 16, top: 10, bottom: 8 })
        .backgroundColor('#F5F5F5')
        .fontColor('#333333')
        .borderRadius({ topLeft: 4, topRight: 18, bottomLeft: 0, bottomRight: 0 })
        .fontSize(15)
        .copyOption(CopyOptions.LocalDevice)
        .selection(this.selectionStart, this.selectionEnd)
        .onTextSelectionChange((start: number, end: number) => {
          this.selectionStart = start;
          this.selectionEnd = end;
        });

      if (this.message.comparison) {
        Scroll() {
          this.buildComparisonTable(this.message.comparison);
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off);
      }
    }
  }

  @Builder
  buildComparisonTable(data: ComparisonData) {
    Column() {
      Row() {
        Column() {
          Text('参数')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#999999');
        }
        .width(60)
        .padding({ left: 8, right: 8, top: 8, bottom: 8 });

        ForEach(data.cars, (car: CarInfo) => {
          Column() {
            Text(`${car.brand} ${car.model}`)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .maxLines(1);
          }
          .width(90)
          .padding({ left: 4, right: 4, top: 8, bottom: 8 });
        }, (car: CarInfo, idx: number) => `${car.id}_${idx}`);
      }
      .width('100%')
      .backgroundColor('#F5F5F5');

      ForEach(data.compareFields, (field: string) => {
        Row() {
          Column() {
            Text(field)
              .fontSize(12)
              .fontColor('#999999');
          }
          .width(60)
          .padding({ left: 8, right: 8, top: 6, bottom: 6 });

          ForEach(data.cars, (car: CarInfo) => {
            Column() {
              Text(this.getCarFieldValue(car, field))
                .fontSize(12)
                .fontColor('#333333')
                .maxLines(1);
            }
            .width(90)
            .padding({ left: 4, right: 4, top: 6, bottom: 6 });
          }, (car: CarInfo, idx: number) => `${car.id}_${idx}_field`);
        }
        .width('100%');
      }, (field: string) => field);
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ top: 4, left: 8, right: 8, bottom: 8 });
  }

  private getCarFieldValue(car: CarInfo, field: string): string {
    if (field === '价格') {
      return `${car.price / 10000}万`;
    }
    if (field === '续航') {
      return `${car.range}km`;
    }
    if (field === '动力') {
      return car.powerType;
    }
    if (field === '车型') {
      return car.bodyType;
    }
    if (field === '座位') {
      return `${car.seatCount}座`;
    }
    if (field === '加速') {
      return `${car.acceleration}s`;
    }
    if (field === '评分') {
      return `${car.score}分`;
    }
    return '-';
  }

  @Builder
  buildOptionsButtons() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(this.message.options, (option: string) => {
        Button(option)
          .height(36)
          .backgroundColor('#F0F5FF')
          .fontColor('#007DFF')
          .borderRadius(18)
          .fontSize(14)
          .margin({ right: 12, bottom: 8 })
          .onClick(() => {
            this.onOptionClick(option);
          });
      }, (option: string) => option);
    }
    .padding({ left: 0, right: 0, top: 8 });
  }

  @Builder
  buildLoadingIndicator() {
    Row() {
      Text('●')
        .fontSize(14)
        .fontColor('#999999')
        .animation({
          delay: 0,
          iterations: -1,
          curve: Curve.EaseInOut,
          duration: 800,
          playMode: PlayMode.Normal
        });
      Text('●')
        .fontSize(14)
        .fontColor('#999999')
        .animation({
          delay: 200,
          iterations: -1,
          curve: Curve.EaseInOut,
          duration: 800,
          playMode: PlayMode.Normal
        });
      Text('●')
        .fontSize(14)
        .fontColor('#999999')
        .animation({
          delay: 400,
          iterations: -1,
          curve: Curve.EaseInOut,
          duration: 800,
          playMode: PlayMode.Normal
        });
    }
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor('#F5F5F5')
    .borderRadius({ topLeft: 4, topRight: 18, bottomLeft: 18, bottomRight: 18 });
  }

  @Builder
  buildErrorIndicator() {
    Column() {
      Text(this.message.content)
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .backgroundColor('#FFF5F5')
        .fontColor('#FF4D4F')
        .borderRadius({ topLeft: 4, topRight: 18, bottomLeft: 18, bottomRight: 18 })
        .fontSize(15);

      if (this.message.retryable) {
        Button('重试')
          .width(80)
          .height(32)
          .backgroundColor('#FF4D4F')
          .fontColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 8 })
          .onClick(() => {
            this.onRetry(this.message);
          });
      }
    }
  }
}
