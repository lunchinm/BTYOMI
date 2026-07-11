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

import { CommonConstants } from '@ohos/common/Index';
import { DetailIconData, DetailIconModel } from '@ohos/common/src/main/ets/model/BuyingCarModel';
import { car, CarInfo, carParamIcon, paramIconModel, ParamInfo } from '../model/BrandModel';

@Component
export struct BuyingCarDetailPage {
  @StorageProp('avoidArea') topHeight: number = 0;
  @StorageProp('bottom') bottom: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State isShow: boolean = false;
  @State checked: boolean = true;
  @State addCount: number = 1;
  @State scrollHeight: number = 0; // 滑动高度 滑动临界点 100
  @State indicatorIndex: number = 0;
  @State typeIndex: number = 0;
  private paramArr: ParamInfo[] = [];
  private bottomParamArr: ParamInfo[] = [];
  private tabArr: string[] = ['综述', '资讯', '降价', '销售'];
  private typeArr: string[] = ['全部在售', '5座', '6座', '24款', '23款'];
  private carArr: CarInfo = car.getCarList()[0];
  detailIconModel: DetailIconModel = DetailIconModel.getDetailIconModel();
  arr: DetailIconData[] = this.detailIconModel.getDetailIcon();

  aboutToAppear() {
    this.paramArr = paramIconModel.getMainList();
    this.bottomParamArr = carParamIcon.getMainList();
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.chevron_backward'))
                .width(CommonConstants.PIC_WIDTH)
                .height(CommonConstants.PIC_HEIGHT)
                .onClick(() => {
                  this.pageInfos.pop();
                });
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .borderRadius(50)
            .backgroundColor('rgba(0, 0, 0, 0.05)');

            Row() {
              Image($r('app.media.share'))
                .width(CommonConstants.PIC_WIDTH)
                .height(CommonConstants.PIC_HEIGHT);
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .borderRadius(50)
            .backgroundColor('rgba(0, 0, 0, 0.05)');
          }
          .width('100%')
          .padding({
            left: CommonConstants.MAIN_MARGIN * 2,
            right: CommonConstants.MAIN_MARGIN * 2,
            top: CommonConstants.MAIN_MARGIN
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Top);

          List({ space: CommonConstants.M_PUBLIC_SPACE * 2 }) {
            ForEach(this.arr, (item: DetailIconData) => {
              ListItem() {
                Row({ space: 4 }) {
                  Image(item.image)
                    .width(CommonConstants.PIC_WIDTH / 2);
                  Text(item.title)
                    .fontSize(CommonConstants.S_FONT_SIZE);
                };
              };
            });
          }
          .height(CommonConstants.PUBLIC_SPACE)
          .divider({
            strokeWidth: 0.5,
            color: 'rgba(0, 0, 0, 0.4)'
          })
          .listDirection(Axis.Horizontal);
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundImage($r('app.media.detail_back'))
        .backgroundImageSize(ImageSize.Cover)
        .backgroundImagePosition({ x: -80 })
        .padding({
          top: this.topHeight,
          bottom: CommonConstants.PUBLIC_SPACE
        });

        Column() {
          Row() {
            Column({ space: 4 }) {
              Text('问界M7')
                .fontSize(22)
                .fontWeight(FontWeight.Bold);
              Row() {
                Image($r('app.media.brand1'))
                  .width(14);
                Text('AITO | 中大型SUV')
                  .fontSize(10)
                  .fontColor('rgba(0, 0, 0, 0.6)');
              };
            }
            .alignItems(HorizontalAlign.Start);

            Column({ space: 2 }) {
              Image($r('app.media.configuration'))
                .width(CommonConstants.L_PUBLIC_SPACE * 2);
              Text('AITO | 中大型SUV')
                .fontSize(10);

            };

          }
          .width(CommonConstants.COLUMN_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween);

          Row() {
            Text('24.98-37.98万')
              .fontSize(14)
              .fontColor(Color.Red);
            Image($r('app.media.triangle'))
              .width(6)
              .fillColor(Color.Red)
              .rotate({ angle: -90 })
              .margin({
                left: CommonConstants.MAIN_MARGIN,
                right: CommonConstants.PUBLIC_SPACE / 2
              });
            Text('指导价24.98-37.98万')
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.4)');
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .margin({
            top: CommonConstants.M_MAIN_MARGIN / 2,
            bottom: CommonConstants.MAIN_MARGIN
          });

          Row({ space: 4 }) {
            Text('销量NO.1 >')
              .tag();
            Text('人气NO.1 >')
              .tag();
            Text('产品力NO.1 >')
              .tag();
          }
          .width(CommonConstants.COLUMN_WIDTH);

          Row() {
            ForEach(this.paramArr, (item: ParamInfo) => {
              Column({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
                Image(item.image)
                  .width(20)
                  .height(14)
                  .objectFit(ImageFit.Contain);
                Text(item.name)
                  .fontSize(10);
              };
            });
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            left: CommonConstants.S_MAIN_PADDING,
            right: CommonConstants.S_MAIN_PADDING,
            top: CommonConstants.L_MAIN_PADDING
          });
        }
        .borderRadius({ topLeft: 16, topRight: 16 })
        .backgroundColor('#fff')
        .offset({ y: -5 })
        .padding({
          top: CommonConstants.L_MAIN_PADDING,
          left: CommonConstants.L_MAIN_PADDING,
          right: CommonConstants.L_MAIN_PADDING,
          bottom: CommonConstants.S_MAIN_PADDING
        });

        Divider()
          .strokeWidth(4)
          .color('#F1F3F5');

        Column() {
          Row({ space: CommonConstants.L_PUBLIC_SPACE }) {
            ForEach(this.tabArr, (item: string, index: number) => {
              Column() {
                Text(item)
                  .fontColor(this.indicatorIndex === index ? CommonConstants.SELE_COLOR : CommonConstants.DEF_COLOR)
                  .fontWeight(this.indicatorIndex === index ? 500 : 400)
                  .fontSize(this.indicatorIndex === index ? CommonConstants.L_FONT_SIZE : CommonConstants.M_FONT_SIZE)
                  .id(index.toString())
                  .onClick(() => {
                    this.indicatorIndex = index;
                  });
              };
            }, (item: string) => item);
          }
          .width(CommonConstants.COLUMN_WIDTH);

          Row({ space: CommonConstants.L_PUBLIC_SPACE / 2 }) {
            ForEach(this.typeArr, (item: string, index: number) => {
              Column() {
                Text(item)
                  .type()
                  .backgroundColor(this.typeIndex === index ? 'rgb(227, 236, 255)' : 'rgb(245, 246, 250)')
                  .fontColor(this.typeIndex === index ? CommonConstants.SELE_COLOR : CommonConstants.DEF_COLOR)
                  .onClick(() => {
                    this.typeIndex = index;
                  });
              };
            }, (item: string) => item);
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .margin({
            top: CommonConstants.MAIN_MARGIN * 2,
            bottom: CommonConstants.M_MAIN_MARGIN * 2,
          });

          Column({ space: CommonConstants.L_PUBLIC_SPACE }) {
            Row({ space: CommonConstants.L_PUBLIC_SPACE / 2 }) {
              Divider()
                .vertical(true)
                .strokeWidth(2)
                .height(10);
              Text(this.carArr.tag[0])
                .fontSize(11)
                .fontColor('#919293');
            }
            .width(CommonConstants.COLUMN_WIDTH);

            Column({ space: CommonConstants.M_MAIN_MARGIN * 3 }) {
              Row() {
                Column() {
                  Text(this.carArr.tag[1])
                    .fontWeight(FontWeight.Bold);
                }
                .width(192);

                Column({ space: CommonConstants.L_PUBLIC_SPACE / 4 }) {
                  Text(this.carArr.price + '万起')
                    .fontSize(14)

                    .fontColor(Color.Red);
                  Text(`指导价¥${this.carArr.price}万`)
                    .fontSize(10)
                    .fontColor('#919293');
                };
              }.width(CommonConstants.COLUMN_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween);

              Row({ space: CommonConstants.L_PUBLIC_SPACE }) {
                ForEach(this.bottomParamArr, (item: ParamInfo) => {
                  Row({ space: CommonConstants.L_PUBLIC_SPACE / 4 }) {
                    Image(item.image)
                      .width(CommonConstants.PUBLIC_SPACE);
                    Text(item.name)
                      .fontSize(10);
                  };
                });

                Button('查成交价')
                  .height(CommonConstants.M_PUBLIC_SPACE * 2)
                  .fontSize(12)
                  .padding({
                    top: CommonConstants.MAIN_PADDING / 2,
                    bottom: CommonConstants.MAIN_PADDING / 2,
                    left: CommonConstants.L_MAIN_PADDING,
                    right: CommonConstants.L_MAIN_PADDING,
                  });

              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width(CommonConstants.COLUMN_WIDTH);
            }
            .width(CommonConstants.COLUMN_WIDTH)
            .borderRadius(10)
            .backgroundColor('#fff')
            .padding(CommonConstants.MAIN_PADDING);
          };

          Row() {
            Divider().vertical(true);
            Image($r('app.media.ic_folds'))
              .width(CommonConstants.PIC_WIDTH / 4)
              .fillColor('rgba(0, 0, 0, 0.6)')
              .offset({ x: -3 });
            Row() {
              Text('加2.0万')
                .fontColor('rgb(229, 60, 34)')
                .fontSize(11);
              Text('升级为下一款，增加')
                .fontSize(11);
              Text('5项')
                .fontSize(11)
                .fontColor('rgb(229, 60, 34)');
              Text('配置')
                .fontSize(11);
            }.layoutWeight(1);

            Row({ space: CommonConstants.PUBLIC_SPACE / 3 }) {
              Text('展开详情')
                .fontSize(11);
              Image($r('app.media.triangle'))
                .height(CommonConstants.PIC_WIDTH / 4)
                .onClick(() => {

                });
            };
          }
          .height(CommonConstants.PUBLIC_SPACE * 4)
          .width(CommonConstants.COLUMN_WIDTH)
          .padding({
            left: CommonConstants.PUBLIC_SPACE,
            right: CommonConstants.PUBLIC_SPACE * 2,
          });
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .linearGradient({
          angle: 180,
          colors: [['rgb(255, 255, 255)', 0], ['rgb(241, 243, 245)', 0.4]]
        })
        .layoutWeight(1)
        .padding({
          left: CommonConstants.L_MAIN_PADDING,
          right: CommonConstants.L_MAIN_PADDING,
          top: CommonConstants.MAIN_PADDING / 2
        });

        this.footer();
      }
      .height('100%');

    }
    .hideTitleBar(true);
  }

  @Builder
  footer() {
    Row() {
      Row({ space: CommonConstants.PUBLIC_SPACE * 2 }) {
        Column({ space: 4 }) {
          Image($r('app.media.ic_car_param1'))
            .width(20)
            .fillColor(Color.Black);
          Text('车型对比')
            .fontSize(10);
        };

        Column({ space: 2 }) {
          Image($r('app.media.ic_concern'))
            .width(15)
            .fillColor(Color.Black);
          Text('关注')
            .fontSize(10);
        };
      }
      .margin({
        left: CommonConstants.MAIN_MARGIN * 2
      });

      Blank();
      Row({ space: 8 }) {
        Button('分期购车')
          .height(CommonConstants.L_PUBLIC_SPACE * 2)
          .fontSize(12)
          .fontColor('#0A59F7')
          .backgroundColor('rgb(241, 243, 245)')
          .padding({
            top: CommonConstants.L_MAIN_PADDING / 2,
            bottom: CommonConstants.L_MAIN_PADDING / 2,
            left: CommonConstants.MAIN_PADDING * 2,
            right: CommonConstants.MAIN_PADDING * 2,
          });
        Button('获取底价')
          .height(CommonConstants.L_PUBLIC_SPACE * 2)
          .fontSize(12)
          .padding({
            top: CommonConstants.L_MAIN_PADDING / 2,
            bottom: CommonConstants.L_MAIN_PADDING / 2,
            left: CommonConstants.MAIN_PADDING * 2,
            right: CommonConstants.MAIN_PADDING * 2,
          });
      }
      .margin({
        right: CommonConstants.MAIN_MARGIN * 2
      });
    }
    .position({ bottom: 0 })
    .backgroundColor('#fff')
    .width(CommonConstants.COLUMN_WIDTH)
    .padding({
      top: CommonConstants.MAIN_PADDING,
      bottom: CommonConstants.MAIN_PADDING,
      left: CommonConstants.MAIN_PADDING,
      right: CommonConstants.MAIN_PADDING
    })
    .alignItems(VerticalAlign.Center);
  }
}

@Extend(Text)
function tag() {
  .fontSize(10)
  .backgroundColor('rgb(245, 246, 250)')
  .padding(CommonConstants.S_MAIN_PADDING / 2)
  .borderRadius(4);
}

@Extend(Text)
function type() {
  .fontSize(10)
  .padding({
    top: CommonConstants.MAIN_PADDING / 3,
    bottom: CommonConstants.MAIN_PADDING / 3,
    left: CommonConstants.MAIN_PADDING,
    right: CommonConstants.MAIN_PADDING,
  })
  .borderRadius(4);
}