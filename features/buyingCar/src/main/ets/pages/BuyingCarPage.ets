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

import display from '@ohos.display';
import componentUtils from '@ohos.arkui.componentUtils';
import { TabConstants, CommonConstants, VehicleModelActivitiesInfo, IconModel } from '@ohos/common/Index';
import { alphabets, brand, BrandInfo, brandListItem, car, CarInfo, ListItemInfo } from '../model/BrandModel';
import { ComponentUtils, MeasureUtils } from '@kit.ArkUI';

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

@Component
export struct BuyingCarPage {
  @StorageProp('avoidArea') topHeight: number = 0;
  private displayInfo: display.Display | null = null;
  private animationDuration: number = 300;
  @State swiperIndex: number = 0;
  @State swiperWidth: number = 0;
  @State indicatorWidth: number = TabConstants.INDICATOR_WIDTH;
  @State indicatorMarginLeft: number = 0;
  @State indicatorIndex: number = 0;
  @State swipeRatio: number = 0;
  @State selectedIndex: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  private arr: string[] = ['新车', '新能源', '摩托车', '特惠品牌'];
  private tagArr: string[] = ['10万以下', '10-20万', '20-30万', '50万以上', '新能源', '轿车', 'SUV', '更多条件'];
  private iconArr: VehicleModelActivitiesInfo[] = [];
  private brandArr: BrandInfo[] = [];
  private carArr: CarInfo[] = [];
  private listItemArr: ListItemInfo[] = [];
  private scroller: Scroller = new Scroller();
  private listScroller: Scroller = new Scroller();
  private swiperController: SwiperController = new SwiperController();
  private uiContext: UIContext = this.getUIContext();
  private measureUtil: MeasureUtils = this.uiContext.getMeasureUtils();
  private componentUtils: ComponentUtils = this.uiContext.getComponentUtils();

  aboutToAppear(): void {
    this.displayInfo = display.getDefaultDisplaySync();
    this.iconArr = IconModel.getMainList();
    this.brandArr = brand.getBrandList();
    this.carArr = car.getCarList();
    this.listItemArr = brandListItem.getListItem();
  }

  private getTextInfo(index: number): Record<string, number> {
    let modePosition: componentUtils.ComponentInfo = this.componentUtils.getRectangleById(index.toString());
    try {
      return {
        'left': this.uiContext.px2vp(modePosition.windowOffset.x),
        'width': this.uiContext.px2vp(modePosition.size.width)
      };
    } catch (error) {
      return { 'left': 0, 'width': 0 };
    }
  }

  private startAnimateTo(marginLeft: number): void {
    this.uiContext.animateTo({
      duration: this.animationDuration,
      curve: Curve.Linear,
      onFinish: () => {
      }
    }, () => {
      this.indicatorMarginLeft = marginLeft;
    });
  }

  private scrollUnderline(index: number): void {
    let indexInfo = this.getTextInfo(index);
    let offsetX = (this.getCurTextWidth(index) - this.indicatorWidth) / 2;
    this.startAnimateTo(indexInfo.left + offsetX);
  }

  private getCurTextWidth(index: number): number {
    let width: number = 0;
    try {
      let modePosition: componentUtils.ComponentInfo = this.componentUtils.getRectangleById(index.toString());
      width = modePosition.size.width;
    } catch (error) {
      width = 0;
    }
    return this.uiContext.px2vp(width);
  }

  @Builder
  iconBuilder(item: VehicleModelActivitiesInfo) {
    Column({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
      Image(item.image)
        .width(CommonConstants.PIC_WIDTH)
        .height(CommonConstants.PIC_HEIGHT);
      Text(item.title)
        .fontSize(CommonConstants.S_FONT_SIZE);
    };
  }

  @Builder
  brandBuilder(item: BrandInfo) {
    Column({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
      Image(item.image)
        .width(CommonConstants.L_PIC_WIDTH)
        .height(CommonConstants.L_PIC_HEIGHT);
      Text(item.name)
        .fontSize(CommonConstants.S_FONT_SIZE);
    };
  }

  @Builder
  itemHead(text: string) {
    Text(text)
      .fontSize(10)
      .margin(4);
  }

  build() {
    Column() {
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
      .zIndex(10)
      .padding({
        top: this.topHeight + CommonConstants.MAIN_MARGIN,
        left: CommonConstants.MAIN_PADDING,
        right: CommonConstants.MAIN_PADDING
      });

      Stack({ alignContent: Alignment.TopStart }) {
        Scroll(this.scroller) {
          Row({ space: CommonConstants.L_PUBLIC_SPACE }) {
            ForEach(this.arr, (item: string, index: number) => {
              Column() {
                Text(item)
                  .fontColor(this.indicatorIndex === index ? TabConstants.SELE_FONT_COLOR : TabConstants.DEF_FONT_COLOR)
                  .fontWeight(TabConstants.DEF_FONT_WEIGHT)
                  .id(index.toString())
                  .onAreaChange((oldValue: Area, newValue: Area) => {
                    let width = Number.parseFloat(newValue.width.toString());
                    if (this.indicatorIndex === index && this.indicatorMarginLeft === 0) {
                      if (newValue.globalPosition.x !== undefined) {
                        let positionX = Number.parseFloat(newValue.globalPosition.x.toString());
                        let positionXOther = (width - this.indicatorWidth) / 2;
                        this.indicatorMarginLeft = Number.isNaN(positionX) ? 0 : (positionX + positionXOther);
                      }
                    }
                  })
                  .onClick(() => {
                    this.indicatorIndex = index;
                    this.scrollUnderline(index);
                    this.swiperIndex = index;
                  });
              };
            }, (item: string) => item);
          }
          .height(TabConstants.TAB_HEIGHT);
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .onWillScroll((xOffset: number) => {
          this.indicatorMarginLeft -= xOffset;
        })
        .width(CommonConstants.COLUMN_WIDTH)
        .padding({ left: CommonConstants.MAIN_PADDING });

        Row() {
          Blank().width(this.indicatorMarginLeft);
          Blank()
            .width(this.indicatorWidth)
            .height(TabConstants.INDICATOR_HEIGHT)
            .backgroundColor(TabConstants.SELE_FONT_COLOR)
            .borderRadius(TabConstants.INDICATOR_HEIGHT / 2);
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .padding({ left: CommonConstants.MAIN_PADDING });
      }

      Swiper(this.swiperController) {
        Column() {
          Row({ space: CommonConstants.PUBLIC_SPACE }) {
            ForEach(this.iconArr, (item: VehicleModelActivitiesInfo) => {
              Column({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
                Image(item.image)
                  .width(CommonConstants.PIC_WIDTH)
                  .height(CommonConstants.PIC_HEIGHT);
                Text(item.title)
                  .fontSize(CommonConstants.S_FONT_SIZE);
              }
              .width(CommonConstants.COLUMN_WIDTH)
              .height(40)
              .borderRadius(50)
              .backgroundColor('#fff')
              .padding({
                left: CommonConstants.PUBLIC_SPACE,
                right: CommonConstants.L_PUBLIC_SPACE
              });
            });
          }
          .justifyContent(FlexAlign.Center)
          .width(CommonConstants.COLUMN_WIDTH);

          Row({ space: CommonConstants.PUBLIC_SPACE * 2 }) {
            ForEach(this.iconArr, (item: VehicleModelActivitiesInfo) => {
              this.iconBuilder(item);
            });
          }
          .margin({
            top: CommonConstants.MAIN_MARGIN * 2,
            bottom: CommonConstants.PUBLIC_SPACE
          });

          Column() {
            Row({ space: 30 }) {
              ForEach(this.brandArr, (item: BrandInfo) => {
                this.brandBuilder(item);
              });
            };

            Grid() {
              ForEach(this.tagArr, (item: string) => {
                GridItem() {
                  Text(item)
                    .fontSize(10);
                }
                .height(CommonConstants.COLUMN_HEIGHT)
                .width(CommonConstants.COLUMN_WIDTH)
                .borderRadius(4)
                .backgroundColor('#F5F6FA');
              });
            }
            .layoutWeight(1)
            .rowsTemplate('1fr 1fr')
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(4)
            .rowsGap(4)
            .padding({
              left: CommonConstants.S_MAIN_PADDING,
              right: CommonConstants.S_MAIN_PADDING,
              bottom: CommonConstants.MAIN_PADDING,
              top: CommonConstants.MAIN_PADDING,
            });
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .backgroundColor('#fff');

          Column() {
            Stack({ alignContent: Alignment.TopStart }) {
              Text('精选');
            }
            .width(CommonConstants.COLUMN_WIDTH)
            .padding({ left: CommonConstants.MAIN_PADDING });

            Row({ space: CommonConstants.PUBLIC_SPACE }) {
              ForEach(this.carArr, (item: CarInfo) => {
                Column({ space: CommonConstants.PUBLIC_SPACE / 6 }) {
                  Image(item.image)
                    .width(60);
                  Text(item.name)
                    .fontSize(10);
                }
                .height(CommonConstants.COLUMN_HEIGHT)
                .width(CommonConstants.COLUMN_WIDTH)
                .borderRadius(4)
                .backgroundColor('#F5F6FA');
              });
            }
            .width(CommonConstants.COLUMN_WIDTH)
            .padding({ left: CommonConstants.MAIN_PADDING });
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .backgroundColor('#fff')
          .margin({ top: CommonConstants.MAIN_MARGIN });
        }
        .width('100%');

        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            Text('新能源');
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .padding({ left: CommonConstants.MAIN_PADDING });
        }
        .width('100%');

        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            Text('摩托车');
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .padding({ left: CommonConstants.MAIN_PADDING });
        }
        .width('100%');

        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            Text('特惠品牌');
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .padding({ left: CommonConstants.MAIN_PADDING });
        }
        .width('100%');
      }
      .index(this.swiperIndex)
      .autoPlay(false)
      .interval(4000)
      .indicator(false)
      .loop(false)
      .duration(this.animationDuration)
      .curve(Curve.Linear)
      .onChange((index: number) => {
        this.swiperIndex = index;
        this.indicatorIndex = index;
        this.scrollUnderline(index);
      });

      Column() {
        List({ scroller: this.listScroller }) {
          ForEach(this.listItemArr, (item: ListItemInfo) => {
            ListItemGroup({ header: this.itemHead(item.alphabet) }) {
              ForEach(item.brandInfo, (project: BrandInfo, index: number) => {
                ListItem() {
                  Row({ space: CommonConstants.PUBLIC_SPACE }) {
                    Image(project.image)
                      .width(CommonConstants.PIC_WIDTH);
                    Text(project.name)
                      .fontSize(12);
                  }
                  .width(CommonConstants.COLUMN_WIDTH)
                  .padding({ top: CommonConstants.PUBLIC_SPACE })
                  .justifyContent(FlexAlign.Start);
                }
                .clip(true)
                .borderRadius({
                  topLeft: index === 0 ? 12 : 0,
                  topRight: index === 0 ? 12 : 0,
                  bottomLeft: index === item.brandInfo.length - 1 ? 12 : 0,
                  bottomRight: index === item.brandInfo.length - 1 ? 12 : 0,
                })
                .width(CommonConstants.COLUMN_WIDTH)
                .backgroundColor('#fff');
              });
            };
          });
        }
        .layoutWeight(1)
        .onScrollIndex((firstIndex: number) => {
          this.selectedIndex = firstIndex;
        })
        .scrollBar(BarState.Off)
        .height('600vp')
        .width(CommonConstants.COLUMN_WIDTH)
        .margin({ top: CommonConstants.MAIN_MARGIN })
        .width('100%')
        .height('100%');

        Column() {
          Text('⭐')
            .fontSize(10);
          AlphabetIndexer({ arrayValue: alphabets, selected: $$this.selectedIndex })
            .onSelect((index) => {
              this.listScroller.scrollToIndex(index, true);
            });
        }
        .zIndex(10)
        .offset({ x: 320, y: this.topHeight + 160 });
      }
      .width(CommonConstants.COLUMN_WIDTH)
      .height(CommonConstants.COLUMN_HEIGHT);
    }
    .width(CommonConstants.COLUMN_WIDTH)
    .height(CommonConstants.COLUMN_HEIGHT);
  }
}