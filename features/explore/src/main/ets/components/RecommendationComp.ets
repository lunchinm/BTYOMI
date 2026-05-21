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

import { CommonConstants, TabConstants, RecomActivityInfo, recomActivity, LazyDataSource } from '@ohos/common';
import { RecommendationConstants } from '../constants/RecommendationConstants';

interface IGrid {
  title: string
  icon: ResourceStr
}

@Component
export struct RecommendationComp {
  @StorageProp('avoidArea') topHeight: number = 0;
  swiperList: Resource[] = [
    $r('app.media.back0'), $r('app.media.back0'), $r('app.media.back0'), $r('app.media.back0')
  ]
  grids: IGrid[] = [
    { title: '轿车云店', icon: $r('app.media.icon1') },
    { title: '试乘试驾', icon: $r('app.media.icon2') },
    { title: '圈子', icon: $r('app.media.icon3') },
  ];
  activityList: LazyDataSource<RecomActivityInfo> = new LazyDataSource();
  @State tabHeight: number = TabConstants.TAB_COL_HEIGHT + this.topHeight; // tab高度
  defWhiteboardHeight: number = RecommendationConstants.SWIPER_HEIGHT; // 默认白板高度
  scroller: Scroller = new Scroller();
  @State radius: number = 0; // 收缩高度、模糊
  // swiper高度
  @State swiperHeight: number = RecommendationConstants.SWIPER_HEIGHT;
  @State whiteboardHeight: number = RecommendationConstants.SWIPER_HEIGHT;
  flagUP: boolean = true; // 是否时向上滑 true向上滑  false 向下滑
  flagReachStart: Boolean = true; // 是否在起始位置
  animateTime: number = 400;
  uiContext: UIContext = this.getUIContext()

  aboutToAppear(): void {
    this.activityList.pushArrayData(recomActivity.getMainList())
  }

  changeState(scrollOffset: number) {
    this.radius += scrollOffset;
    this.swiperHeight -= scrollOffset;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Swiper() {
        ForEach(this.swiperList, (item: Resource) => {
          Image(item).blur(this.radius / 10)
            .height(this.swiperHeight)
        })
      }
      .autoPlay(this.swiperHeight !== this.tabHeight)
      .indicator(
        this.swiperHeight !== this.tabHeight ?
          new DotIndicator()
            .itemWidth(RecommendationConstants.DOTINDICATOR_WIDTH)
            .itemHeight(RecommendationConstants.DOTINDICATOR_HEIGHT)
            .selectedItemWidth(RecommendationConstants.SELE_DOTINDICATOR_WIDTH)
            .selectedItemHeight(RecommendationConstants.DOTINDICATOR_HEIGHT)
            .color(RecommendationConstants.DOTINDICATOR_DEF_COLOR)
            .selectedColor(RecommendationConstants.DOTINDICATOR_SELE_COLOR)
            .bottom(0) : false
      )
      .width(CommonConstants.COLUMN_WIDTH)
      .height(this.swiperHeight)
      .zIndex(1)

      List({ scroller: this.scroller }) {
        ListItem() {
        }.height(this.whiteboardHeight)

        ListItem() {
          Flex({ justifyContent: FlexAlign.SpaceEvenly }) {
            ForEach(this.grids, (item: IGrid) => {
              Row({ space: 6 }) {
                Image(item.icon)
                  .offset({ y: 3 })
                  .width(24)
                Text(item.title)
                  .fontSize(CommonConstants.S_FONT_SIZE)
              }
              .backgroundColor(Color.White)
              .padding(CommonConstants.PUBLIC_SPACE)
              .width('28%')
              .justifyContent(FlexAlign.Center)
              .height(RecommendationConstants.BOX_HEIGHT)
              .borderRadius(8)
            })
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .margin({ top: CommonConstants.PUBLIC_SPACE * 2, bottom: CommonConstants.PUBLIC_SPACE * 3 })
        }
        .linearGradient({
          angle: 0,
          colors: [['rgb(255, 255, 255)', 0], ['rgb(229, 238, 238)', 1]]
        })

        LazyForEach(this.activityList, (item: RecomActivityInfo) => {
          ListItem() {
            this.listItem(item)
          }
        })
      }
      .height(CommonConstants.COLUMN_HEIGHT)
      .scrollBar(BarState.Off)
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
    }
  }

  @Builder
  listItem(itemData: RecomActivityInfo) {
    Column() {
      Row() {
        Column() {
          Text(itemData.title)
            .fontSize(CommonConstants.L_FONT_SIZE)
            .fontWeight(FontWeight.Bold)
          Row() {
            Row({ space: CommonConstants.PUBLIC_SPACE / 3 }) {
              Image(itemData.headerImg)
                .width(CommonConstants.L_PUBLIC_SPACE)
                .height(CommonConstants.L_PUBLIC_SPACE).borderRadius(15)
              Text(itemData.name)
                .fontWeight(FontWeight.Bold)
                .fontSize(CommonConstants.S_FONT_SIZE)
            }
            .alignItems(VerticalAlign.Center)

            Blank().height(0)
            Image($r('app.media.favor'))
              .width(10)
              .margin({
                right: 2
              })
            Text(`${itemData.seeNum}`)
              .fontSize(CommonConstants.S_FONT_SIZE)
              .fontColor('#999')
          }
          .width(CommonConstants.COLUMN_WIDTH)
        }
        .margin({ right: CommonConstants.PUBLIC_SPACE })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
        .height(CommonConstants.COLUMN_HEIGHT)
        .layoutWeight(1)

        Image(itemData.image)
          .width(117)
          .height(78)
          .borderRadius(8)
          .height(CommonConstants.COLUMN_HEIGHT)
      }
      .height(78)
      .padding({
        right: CommonConstants.L_PUBLIC_SPACE, left: CommonConstants.L_PUBLIC_SPACE,
      })
      .height(78)

      Divider()
        .margin({
          top: CommonConstants.M_PUBLIC_SPACE,
          bottom: CommonConstants.M_PUBLIC_SPACE,
          left: CommonConstants.L_PUBLIC_SPACE
        })
    }
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
          this.swiperHeight = this.tabHeight;
          this.whiteboardHeight = 0;
        })
      } else {
        this.uiContext.animateTo({ duration: this.animateTime }, () => {
          this.radius = 0;
          this.swiperHeight = RecommendationConstants.SWIPER_HEIGHT;
          this.whiteboardHeight = this.defWhiteboardHeight;
        })
        this.scroller.scrollToIndex(0)
      }
    } else { // 向下滑
      if (this.swiperHeight >= RecommendationConstants.SWIPER_HEIGHT) {
        this.uiContext.animateTo({ duration: this.animateTime }, () => {
          this.radius = 0;
          this.swiperHeight = RecommendationConstants.SWIPER_HEIGHT;
          this.whiteboardHeight = this.defWhiteboardHeight;
          this.scroller.scrollToIndex(0)
        })
      } else {
        if (radius >= this.defWhiteboardHeight / 2) {
          this.uiContext.animateTo({ duration: this.animateTime }, () => {
            this.radius = 0;
            this.swiperHeight = RecommendationConstants.SWIPER_HEIGHT;
            this.whiteboardHeight = this.defWhiteboardHeight;
          })
        } else {
          this.uiContext.animateTo({ duration: this.animateTime }, () => {
            this.radius = this.defWhiteboardHeight;
            this.swiperHeight = this.tabHeight;
            this.whiteboardHeight = 0;
          })
        }
      }
    }
  }
}
