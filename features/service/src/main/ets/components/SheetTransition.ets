/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants } from '@ohos/common';
import { ServiceConstants } from '../constants/ServiceConstants';
import { StationInfo } from '../model/StationModel';

@Component
export struct SheetTransition {
  @Prop addressName: string = '';
  @Prop stationList: StationInfo[] = [];
  @State isShow: boolean = true;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        this.onCancel();
      }
    }),
  });

  onCancel() {
  }

  @Builder
  myBuilder() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Stack({ alignContent: Alignment.Start }) {
          Image($r('app.media.en_search'))
            .width(ServiceConstants.TEXT_INPUT_HEIGHT)
            .zIndex(1);
          TextInput({ placeholder: '搜索目的地和充电站' })
            .placeholderFont({ size: CommonConstants.S_FONT_SIZE })
            .placeholderColor(ServiceConstants.TEXT_PLACEHOLDER_COLOR)
            .backgroundColor(Color.White)
            .height(ServiceConstants.TEXT_INPUT_HEIGHT)
            .padding({ left: ServiceConstants.TEXT_INPUT_HEIGHT });
        }
        .layoutWeight(1)
        .borderRadius(ServiceConstants.TEXT_INPUT_HEIGHT)
        .clip(true);

        Column() {
          Image($r('app.media.ic_empty'))
            .width(CommonConstants.PIC_WIDTH).height(CommonConstants.PIC_HEIGHT);
          Text('筛选').fontSize(CommonConstants.S_FONT_SIZE);
        }
        .margin({ left: CommonConstants.MAIN_PADDING });
      }
      .padding(CommonConstants.MAIN_PADDING);

      Flex({ direction: FlexDirection.Column }) {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Row() {
            Text(this.addressName).fontSize(CommonConstants.M_FONT_SIZE);
            Text('附近推荐').fontSize(CommonConstants.M_FONT_SIZE).margin({ left: '10vp' });
          };

          Row() {
            Text('综合排序').fontSize(CommonConstants.M_FONT_SIZE);
            Image($r('app.media.ic_arrow_drop_down'))
              .width(CommonConstants.PIC_WIDTH).height(CommonConstants.PIC_HEIGHT);
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            this.dialogController.open();
          });
        }
        .padding({ bottom: CommonConstants.MAIN_PADDING });

        Flex() {
          Text('直流').textTagStyle();
          Text('华为超充').textTagStyle();
          Text('即插即充').textTagStyle();
          Text('常用站点').textTagStyle();
        }
        .margin({ bottom: CommonConstants.MAIN_PADDING });

        List({ space: CommonConstants.PUBLIC_SPACE }) {
          ForEach(this.stationList, (item: StationInfo) => {
            ListItem() {
              Column({ space: CommonConstants.PUBLIC_SPACE }) {
                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Text(item.name).fontSize(CommonConstants.M_FONT_SIZE);
                  Row({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
                    Image($r('app.media.ic_collect'))
                      .width(CommonConstants.PIC_WIDTH / 2)
                      .height(CommonConstants.PIC_HEIGHT / 2);
                    Text(`${item.distance}km`).fontSize(CommonConstants.S_FONT_SIZE).fontColor('#a9a9a9');
                  };
                };

                Row() {
                  ForEach(item.tag as string[], (itemTag: string) => {
                    Text(`${itemTag}`)
                      .fontSize(CommonConstants.S_FONT_SIZE)
                      .margin({ right: CommonConstants.PUBLIC_SPACE / 2 })
                      .padding({
                        top: '2vp',
                        right: '5vp',
                        bottom: '2vp',
                        left: '5vp'
                      })
                      .borderRadius(4)
                      .backgroundColor('#e2e2e2');
                  });
                }.width(CommonConstants.COLUMN_WIDTH);

                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Row() {
                    Row() {
                      Text(`直流`)
                        .fontSize(CommonConstants.S_FONT_SIZE)
                        .backgroundColor('#ceffbc')
                        .fontColor('#1ed013')
                        .padding('2vp')
                        .borderRadius(4);
                      Text(`${item.direct}`).fontSize(CommonConstants.M_FONT_SIZE).fontWeight(600);
                    }
                    .margin({ right: '20vp' });

                    Row() {
                      Text(`交流`)
                        .fontSize(CommonConstants.S_FONT_SIZE)
                        .backgroundColor('#c3caf4')
                        .fontColor('#0269da')
                        .padding('2vp')
                        .borderRadius(4);
                      Text(`${item.alternating}`);

                    };
                  };

                  Row() {
                    Text(`￥${item.price}`);
                    Text('/度起')
                      .fontSize(CommonConstants.S_FONT_SIZE)
                      .fontColor('#a9a9a9');
                  }
                  .alignItems(VerticalAlign.Bottom);
                };
              }
              .backgroundColor(Color.White)
              .borderRadius(CommonConstants.BORDER_RADIUS)
              .padding(CommonConstants.MAIN_PADDING);
            };
          });
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .height('100%')
        .scrollBar(BarState.Off)
        .layoutWeight(1);
      }
      .layoutWeight(1)
      .padding(CommonConstants.MAIN_PADDING);
    }
    .width(CommonConstants.COLUMN_WIDTH);
  }

  build() {
    Column() {
      Button('重新推荐')
        .onClick(() => {
          this.isShow = true;
        })
        .fontSize(CommonConstants.L_FONT_SIZE)
        .bindSheet($$this.isShow, this.myBuilder(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],
          showClose: false,
          preferType: SheetType.CENTER,
          enableOutsideInteractive: true,
          shouldDismiss: ((sheetDismiss: SheetDismiss) => {
            sheetDismiss.dismiss();
          })
        });
    }
    .justifyContent(FlexAlign.Center);
  }
}

@CustomDialog
struct CustomDialogExample {
  cancel?: () => void;
  controller?: CustomDialogController;

  build() {
    Column() {
      Text('排序方式').fontSize(CommonConstants.L_FONT_SIZE).margin({ top: 0, bottom: 20 });
      Column() {
        Text('综合排序').textDialogStyle();
        Text('距离优先').textDialogStyle();
        Text('价格优先').textDialogStyle().borderWidth(0);
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.COLUMN_WIDTH);

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            if (this.controller) {
              this.controller.close();
            }
            if (this.cancel) {
              this.cancel();
            }
          })
          .fontColor($r('app.color.main_color')).fontSize(CommonConstants.S_FONT_SIZE)
          .backgroundColor(Color.Transparent);
      }.margin({ bottom: CommonConstants.MAIN_PADDING });
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: CommonConstants.MAIN_PADDING * 2,
      right: CommonConstants.MAIN_PADDING * 2,
      left: CommonConstants.MAIN_PADDING * 2
    })
    .width(CommonConstants.COLUMN_WIDTH);
  }
}

@Extend(Text)
function textDialogStyle() {
  .fontSize(CommonConstants.S_FONT_SIZE)
  .width('100%')
  .padding({ top: '10vp', bottom: '10vp' })
  .borderWidth({ bottom: '1vp' })
  .borderColor('#e2e2e2');
}

@Extend(Text)
function textTagStyle() {
  .textAlign(TextAlign.Center)
  .fontSize(CommonConstants.S_FONT_SIZE)
  .margin({ right: CommonConstants.MAIN_PADDING })
  .padding({
    top: '2vp',
    right: '5vp',
    bottom: '2vp',
    left: '5vp'
  })
  .borderRadius(20)
  .backgroundColor('#e2e2e2');
}
