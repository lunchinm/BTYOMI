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

import { CommodityModel, CommodityData, CommonConstants } from '@ohos/common/Index';
import { ShoppingMallConstants } from '../constants/ShoppingMallConstants';

@Extend(Text)
function addOrBuy(fColor: string | Color, bgColor?: string | Color) {
  .fontColor(fColor)
  .fontSize(CommonConstants.S_FONT_SIZE)
  .width('50%')
  .padding({
    top: CommonConstants.MAIN_PADDING / 2,
    bottom: CommonConstants.MAIN_PADDING / 2
  })
  .textAlign(TextAlign.Center)
  .backgroundColor(bgColor);
}

@Component
export struct CommodityDetailPage {
  @StorageProp('avoidArea') topHeight: number = 0;
  @StorageProp('bottom') bottom: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  commodityModel: CommodityModel = CommodityModel.getCommodityModel();
  commodityData?: CommodityData;
  @State isShow: boolean = false;
  @State checked: boolean = true;
  @State addCount: number = 1;
  @State scrollHeight: number = 0; //  滑动高度 滑动临界点 100

  @Builder
  footer(addCar?: Function, buy?: Function) {
    Row() {
      Badge({
        value: '0',
        style: { badgeSize: 14, badgeColor: Color.Red }
      }) {
        Image($r('app.media.shopping_cart'))
          .width(ShoppingMallConstants.ICON_WIDTH);
      };

      Blank();
      Row() {
        Text('加入购物车').addOrBuy(ShoppingMallConstants.CHECKED_COLOR)
          .onClick(() => {
            addCar ? addCar() : '';
          });
        Text('立即购买').addOrBuy(Color.White, ShoppingMallConstants.CHECKED_COLOR)
          .onClick(() => {
            buy ? buy() : '';
          });
      }
      .border({ width: 2, color: ShoppingMallConstants.CHECKED_COLOR })
      .width(220);
    }
    .width(CommonConstants.COLUMN_WIDTH)
    .padding({
      top: CommonConstants.MAIN_PADDING,
      bottom: CommonConstants.MAIN_PADDING + this.bottom,
      left: CommonConstants.MAIN_PADDING,
      right: CommonConstants.MAIN_PADDING
    })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  bindSheetBuilder() {
    Column({ space: CommonConstants.MAIN_PADDING * 2 }) {
      Column({ space: CommonConstants.MAIN_PADDING * 2 }) {
        Row() {
          Text('×').fontSize(24)
            .onClick(() => {
              this.isShow = false;
            });
        }
        .justifyContent(FlexAlign.End).width(CommonConstants.COLUMN_WIDTH);

        Row({ space: CommonConstants.PUBLIC_SPACE }) {
          Image(this.commodityData?.picture)
            .width(100).height(100);
          Column({ space: CommonConstants.PUBLIC_SPACE }) {
            Text(this.commodityData?.description)
              .fontWeight(FontWeight.Bold);
            Blank();
            Text() {
              Span('￥');
              Span(`${this.commodityData?.price}`)
                .fontSize(CommonConstants.M_FONT_SIZE)
                .fontWeight(FontWeight.Bold);
            }
            .fontSize(CommonConstants.S_FONT_SIZE);

            Text(`已选：${this.checked ? '图片色' : ''}`).fontSize(CommonConstants.S_FONT_SIZE);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
        };

        Column({ space: CommonConstants.PUBLIC_SPACE }) {
          Text('图片色')
            .fontSize(CommonConstants.M_FONT_SIZE)
            .fontColor(ShoppingMallConstants.NOT_CHECKED_COLOR);
          Text('图片色')
            .fontColor(this.checked ? ShoppingMallConstants.CHECKED_COLOR : ShoppingMallConstants.NOT_CHECKED_COLOR)
            .fontSize(CommonConstants.M_FONT_SIZE)
            .padding({
              top: CommonConstants.MAIN_PADDING / 2,
              bottom: CommonConstants.MAIN_PADDING / 2,
              left: CommonConstants.MAIN_PADDING,
              right: CommonConstants.MAIN_PADDING
            })
            .border({
              width: 1,
              color: this.checked ? ShoppingMallConstants.CHECKED_COLOR : ShoppingMallConstants.NOT_CHECKED_COLOR
            })
            .onClick(() => {
              this.checked = !this.checked;
            });
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .alignItems(HorizontalAlign.Start);

        Column({ space: CommonConstants.PUBLIC_SPACE }) {
          Text('数量')
            .fontSize(CommonConstants.M_FONT_SIZE)
            .fontColor(ShoppingMallConstants.NOT_CHECKED_COLOR);
          Counter() {
            Text(this.addCount.toString())
              .fontSize(CommonConstants.M_FONT_SIZE);
          }
          .onInc(() => {
            this.addCount++;
          })
          .onDec(() => {
            this.addCount > 1 ? (this.addCount--) : '';
          });
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .alignItems(HorizontalAlign.Start);
      }
      .padding({
        top: CommonConstants.MAIN_PADDING * 2,
        left: CommonConstants.MAIN_PADDING * 2,
        right: CommonConstants.MAIN_PADDING * 2,
      });

      Row() {
        this.footer();
      }.width(CommonConstants.COLUMN_WIDTH)
      .padding({
        right: CommonConstants.MAIN_PADDING,
        left: CommonConstants.MAIN_PADDING,
      });
    };
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(ShoppingMallConstants.ICON_WIDTH)
            .fillColor(this.scrollHeight > ShoppingMallConstants.SCROLL_hEIGHT ? Color.Black : Color.White)
            .onClick(() => {
              this.pageInfos.pop();
            });
          Blank();
          Image($r('app.media.share_windows'))
            .width(ShoppingMallConstants.ICON_WIDTH)
            .fillColor(this.scrollHeight > ShoppingMallConstants.SCROLL_hEIGHT ? Color.Black : Color.White);
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .padding({
          top: CommonConstants.MAIN_PADDING + this.topHeight,
          bottom: CommonConstants.MAIN_PADDING,
          left: CommonConstants.MAIN_PADDING,
          right: CommonConstants.MAIN_PADDING
        })
        .position({ y: 0 })
        .zIndex(1)
        .backgroundColor(`rgba(255, 255, 255, ${this.scrollHeight > ShoppingMallConstants.SCROLL_hEIGHT ? 0.9 : 0})`);

        Flex({ direction: FlexDirection.Column }) {
          Scroll() {
            Column({ space: CommonConstants.PUBLIC_SPACE }) {
              Image(this.commodityData?.picture)
                .width(CommonConstants.COLUMN_WIDTH).height(ShoppingMallConstants.SWIPER_HEIGHT);
              Column({ space: CommonConstants.PUBLIC_SPACE * 2 }) {
                Text(this.commodityData?.description)
                  .fontSize(CommonConstants.L_FONT_SIZE)
                  .fontWeight(FontWeight.Bold);
                Text() {
                  Span('￥').fontSize(CommonConstants.M_FONT_SIZE);
                  Span(`${this.commodityData?.price}`)
                    .fontSize(CommonConstants.L_FONT_SIZE)
                    .fontWeight(FontWeight.Bold);
                };

                Column({ space: CommonConstants.PUBLIC_SPACE }) {
                  Text() {
                    Span('当前库存：')
                      .fontSize(CommonConstants.M_FONT_SIZE);
                    Span(`${this.commodityData?.inventory}`)
                      .fontSize(CommonConstants.M_FONT_SIZE)
                      .fontWeight(FontWeight.Bold);
                  }.fontColor(ShoppingMallConstants.NOT_CHECKED_COLOR);

                  Divider().backgroundColor(ShoppingMallConstants.LINE_COLOR).strokeWidth(1);
                  Row() {
                    Text('购买须知').fontSize(CommonConstants.M_FONT_SIZE);
                    Blank();
                    Image($r('app.media.mi_ic_right_arrow'))
                      .width(ShoppingMallConstants.ICON_WIDTH / 2);
                  }.width(CommonConstants.COLUMN_WIDTH);

                  Divider().backgroundColor(ShoppingMallConstants.LINE_COLOR).strokeWidth(1);
                }
                .width(CommonConstants.COLUMN_WIDTH)
                .alignItems(HorizontalAlign.Start);

                Column() {
                  Image(this.commodityData?.picture);
                }
                .width(CommonConstants.COLUMN_WIDTH)
                .height(800);
              }
              .padding(CommonConstants.MAIN_PADDING)
              .alignItems(HorizontalAlign.Start)
              .width(CommonConstants.COLUMN_WIDTH);
            };
          }
          .layoutWeight(1)
          .onWillScroll((xOffset: number, yOffset: number) => {
            this.scrollHeight += yOffset;
          });

          Divider().backgroundColor(Color.Red).strokeWidth(0.5);
          this.footer(
            () => {
              this.isShow = true;
            },
            () => {
              this.isShow = true;
            }
          );
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .height(CommonConstants.COLUMN_HEIGHT);
      }
      .width(CommonConstants.COLUMN_WIDTH)
      .height(CommonConstants.COLUMN_HEIGHT)
      .bindSheet($$this.isShow, this.bindSheetBuilder(), {
        height: SheetSize.FIT_CONTENT,
        showClose: false
      });
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      try {
        const id = ctx?.pathInfo?.param as string;
        this.commodityData = this.commodityModel.getCommodityDetail(id);
      } catch (e) {
        // ...
      }
    });
  }
}
