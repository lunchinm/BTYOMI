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

import { CommonConstants, LazyDataSource, CommodityData, CommodityModel } from '@ohos/common';
import { ShoppingMallConstants } from '../constants/ShoppingMallConstants';
import { CommodityItemComp } from '../components/CommodityItemComp';

@Extend(Image)
function iconStyle() {
  .width(ShoppingMallConstants.ICON_WIDTH)
  .height(ShoppingMallConstants.ICON_HEIGHT)
  .fillColor('#000')
}

@Extend(Column)
function iconBgStyle() {
  .width(ShoppingMallConstants.ICON_WIDTH * 3 / 2)
  .height(ShoppingMallConstants.ICON_HEIGHT * 3 / 2)
  .backgroundColor('rgba(218, 231, 239, 0.32)')
  .justifyContent(FlexAlign.Center)
  .borderRadius(50)
}

// ============================================
// 【预览组件说明】
// 使用说明：如果ShoppingMallPage页面中添加了@Consume装饰器
// 1. 如果原页面已有 @Entry 装饰器，保留它，删除此预览组件
// 2. 如果原页面没有 @Entry 装饰器，添加 @Entry 成为预览组件
// 3. 如果原页面有 @Consume('pageInfos')，必须使用此预览组件方式
//
// 复制以下代码到对应的 .ets 文件开头部分即可
// ============================================
@Entry
struct ShoppingMallPagePreview {
  // 【必须】提供 @Consume 所需的上下文数据
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  build() {
    Column() {
      ShoppingMallPage();
    }
    .width('100%')
    .height('100%');
  }
}

@Component
export struct ShoppingMallPage {
  @StorageProp('avoidArea') topHeight: number = 0;
  // 数据
  commodityModel: CommodityModel = CommodityModel.getCommodityModel();
  @State commodityList: LazyDataSource<CommodityData> = new LazyDataSource();
  swiperList: CommodityData[] = this.commodityModel.getSwiperList();
  optionList: ResourceStr[] = ['萌宠乐园', '小华专区', '常用设备', '精品文创',
    '品质生活', '权益卡卷', '软件服务', '限时秒杀'];
  @State currentIndex: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  tabHeight: number = 56;
  defSwiperHeight: number = ShoppingMallConstants.SWIPER_HEIGHT; // swiper默认高度
  defWhiteboardHeight: number = ShoppingMallConstants.SWIPER_HEIGHT + this.tabHeight; // 默认白板高度
  animateTime: number = 400;
  scroller: Scroller = new Scroller();
  @State radius: number = 0; // 收缩高度、模糊
  @State swiperHeight: number = ShoppingMallConstants.SWIPER_HEIGHT; // swiper高度
  @State headerHeight: number = ShoppingMallConstants.HEADER_HEIGHT; // 头部高度
  @State whiteboardHeight: number = ShoppingMallConstants.SWIPER_HEIGHT + this.tabHeight; // 白板高度
  flagUP: boolean = true; // 是否时向上滑 true向上滑  false 向下滑
  flagReachStart: Boolean = true; // 是否在起始位置
  uiContext: UIContext = this.getUIContext()

  aboutToAppear() {
    this.headerHeight += this.topHeight;
    this.commodityList.pushArrayData(this.commodityModel.getAllList());
  }

  changeState(scrollOffset: number) {
    this.radius += scrollOffset;
    this.swiperHeight -= scrollOffset;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row({ space: CommonConstants.PUBLIC_SPACE }) {
        Text('商城').fontSize(CommonConstants.MAX_FONT_SIZE).fontWeight(FontWeight.Bold)
        Blank()
        Column() {
          Image($r('app.media.AI_search')).iconStyle()
        }.iconBgStyle()

        Column() {
          Image($r('app.media.bag')).iconStyle()
        }.iconBgStyle()

        Column() {
          Image($r('app.media.more')).iconStyle()
        }.iconBgStyle()
      }
      .width(CommonConstants.COLUMN_WIDTH)
      .height(this.headerHeight)
      .padding({
        top: CommonConstants.MAIN_PADDING + this.topHeight,
        bottom: CommonConstants.MAIN_PADDING,
        left: CommonConstants.S_MAIN_PADDING * 2,
        right: CommonConstants.MAIN_PADDING
      })
      .zIndex(2)
      .position({ y: 0 })

      Column() {
        Swiper() {
          ForEach(this.swiperList, (item: CommodityData) => {
            Image(item.picture).blur(this.radius / 10).height(this.swiperHeight)
              .onClick(() => {
                this.pageInfos.pushPathByName('CommodityDetailPage', item.id);
              })
          })
        }
        .autoPlay(this.swiperHeight !== this.headerHeight)
        .indicator(
          this.swiperHeight !== this.headerHeight ?
            new DotIndicator()
              .itemWidth(ShoppingMallConstants.DOTINDICATOR_WIDTH)
              .itemHeight(ShoppingMallConstants.DOTINDICATOR_HEIGHT)
              .selectedItemWidth(ShoppingMallConstants.SELE_DOTINDICATOR_WIDTH)
              .selectedItemHeight(ShoppingMallConstants.DOTINDICATOR_HEIGHT)
              .color(ShoppingMallConstants.DOTINDICATOR_DEF_COLOR)
              .selectedColor(ShoppingMallConstants.DOTINDICATOR_SELE_COLOR)
              .bottom(0) : false
        )
        .width(CommonConstants.COLUMN_WIDTH)
        .height(this.swiperHeight)

        Scroll() {
          Row() {
            ForEach(this.optionList, (item: ResourceStr, index: number) => {
              this.tabBuilder(index, item)
            }, (item: ResourceStr) => `${item}`)
          }.width('auto')
          .margin({
            left: CommonConstants.MAIN_MARGIN
          })
          .backgroundImage($r('app.media.background'))
          .backgroundImageSize(ImageSize.Cover)

        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .height(this.tabHeight)
      }
      .zIndex(1)

      WaterFlow({ scroller: this.scroller }) {
        FlowItem() {
        }.height(this.whiteboardHeight)

        FlowItem() {
        }.height(this.whiteboardHeight)

        LazyForEach(this.commodityList, (item: CommodityData) => {
          FlowItem() {
            CommodityItemComp({ commodityData: item })
          }
          .onClick(() => {
            this.pageInfos.pushPathByName('CommodityDetailPage', item.id);
          })
          .margin({
            left: CommonConstants.MAIN_PADDING / 2,
            right: CommonConstants.MAIN_PADDING / 2,
            bottom: CommonConstants.MAIN_MARGIN
          })
        }, (item: CommodityData) => `${JSON.stringify(item)}`)
      }
      .columnsTemplate('1fr 1fr')
      .scrollBar(BarState.Off)
      .height(CommonConstants.COLUMN_HEIGHT)
      .padding({
        left: CommonConstants.MAIN_PADDING / 2,
        right: CommonConstants.MAIN_PADDING / 2,
      })
      .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
        if (this.whiteboardHeight <= this.defWhiteboardHeight) {
          this.whiteboardHeight -= scrollOffset;
        }
        if (!this.flagReachStart) {
          return;
        }
        if (this.radius >= 0 && this.radius <= this.defWhiteboardHeight) {
          this.changeState(scrollOffset)
        }
        if (scrollOffset > 0) {
          this.flagUP = true;
        } // 向上滑
        if (scrollOffset < 0) {
          this.flagUP = false;
        } // 向下滑
        if (scrollState === 2) {
          this.scrollFun()
        }
      })
      .onScrollIndex((start: number) => {
        this.flagReachStart = start === 0;
      })
      .onScrollStop(() => {
        this.scrollFun()
      })
    }.width(CommonConstants.COLUMN_WIDTH)
    .backgroundImage($r('app.media.background'))
    .backgroundImageSize(ImageSize.Cover)
  }

  @Builder
  tabBuilder(index: number, name: ResourceStr) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? ShoppingMallConstants.SELE_COLOR : ShoppingMallConstants.DEFA_COLOR)
        .fontSize(CommonConstants.M_FONT_SIZE)
        .padding(CommonConstants.MAIN_PADDING)
    }
    .justifyContent(FlexAlign.Center)
    .borderRadius(21)
    .backgroundColor(this.currentIndex === index ? ShoppingMallConstants.SELE_BG_COLOR :
      ShoppingMallConstants.DEFA_BG_COLOR)
    .margin({
      top: CommonConstants.M_MAIN_MARGIN,
      bottom: CommonConstants.M_MAIN_MARGIN,
      left: CommonConstants.MAIN_MARGIN,
    })
    .width(ShoppingMallConstants.TAB_WIDTH)
    .onClick(() => {
      this.currentIndex = index;
      // 模拟请求
      this.commodityList.clear();
      setTimeout(() => {
        this.commodityList.pushArrayData(this.commodityModel.getAllList());
      }, 1000)
    })
  }

  scrollFun() {
    if (this.radius === this.defWhiteboardHeight && !this.flagReachStart) {
      return;
    } // 继续向上/向下滑
    let radius = 0;
    if (this.radius < 0) {
      radius = -this.radius;
    } else {
      radius = this.radius;
    }
    if (this.flagUP) { // 向上滑
      if (radius >= this.defWhiteboardHeight / 2) {
        this.uiContext.animateTo({ duration: this.animateTime }, () => {
          this.radius = this.defWhiteboardHeight;
          this.swiperHeight = this.headerHeight;
          this.whiteboardHeight = this.headerHeight + this.tabHeight;
        })
      } else {
        this.uiContext.animateTo({ duration: this.animateTime }, () => {
          this.radius = 0;
          this.swiperHeight = ShoppingMallConstants.SWIPER_HEIGHT;
          this.whiteboardHeight = this.defWhiteboardHeight;
        })
        this.scroller.scrollToIndex(0)
      }
    } else { // 向下滑
      if (this.swiperHeight >= ShoppingMallConstants.SWIPER_HEIGHT) {
        this.uiContext.animateTo({ duration: this.animateTime }, () => {
          this.radius = 0;
          this.swiperHeight = ShoppingMallConstants.SWIPER_HEIGHT;
          this.whiteboardHeight = this.defWhiteboardHeight;
          this.scroller.scrollToIndex(0)
        })
      } else {
        if (radius >= this.defWhiteboardHeight / 2) {
          this.uiContext.animateTo({ duration: this.animateTime }, () => {
            this.radius = 0;
            this.swiperHeight = ShoppingMallConstants.SWIPER_HEIGHT;
            this.whiteboardHeight = this.defWhiteboardHeight;
          })
        } else {
          this.uiContext.animateTo({ duration: this.animateTime }, () => {
            this.radius = this.defWhiteboardHeight;
            this.swiperHeight = this.headerHeight;
            this.whiteboardHeight = this.headerHeight + this.tabHeight;
          })
        }
      }
    }
  }
}
