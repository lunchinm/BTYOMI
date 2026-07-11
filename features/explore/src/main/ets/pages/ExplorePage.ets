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
import { CommonConstants, TabConstants } from '@ohos/common/Index';
import { RecommendationComp } from '../components/RecommendationComp';
import { ComponentUtils, LengthMetrics, MeasureUtils } from '@kit.ArkUI';
import { RecommendationConstants } from '../constants/RecommendationConstants';

@Preview
@Component
export struct ExplorePage {
  @StorageProp('avoidArea') topHeight: number = 0;
  private displayInfo: display.Display | null = null;
  private animationDuration: number = 300; //动画时间
  @State swiperIndex: number = 0; //内容区当前Index
  @State swiperWidth: number = 0; // vp 内容区宽度
  @State indicatorWidth: number = TabConstants.INDICATOR_WIDTH; // vp页签宽度
  @State indicatorMarginLeft: number = 0; // vp 当前页签距离左边margin
  @State indicatorIndex: number = 0; //当前页签Index
  @State swipeRatio: number = 0; //判断是否翻页，页面滑动超过一半，tabBar切换到下一页。
  private arr: string[] = ['关注', '推荐', '热榜', '兴趣', '精品', '视频'];
  private scroller: Scroller = new Scroller();
  private swiperController: SwiperController = new SwiperController();
  private uiContext: UIContext = this.getUIContext();
  private measureUtil: MeasureUtils = this.uiContext.getMeasureUtils();
  private componentUtils: ComponentUtils = this.uiContext.getComponentUtils();

  aboutToAppear(): void {
    this.displayInfo = display.getDefaultDisplaySync(); //获取屏幕实例
  }

  // 获取组件大小、位置、平移缩放旋转及仿射矩阵属性信息。
  private getTextInfo(index: number): Record<string, number> {
    let componentPost: componentUtils.ComponentInfo = this.componentUtils.getRectangleById(index.toString());
    try {
      return {
        'left': this.uiContext.px2vp(componentPost.windowOffset.x),
        'width': this.uiContext.px2vp(componentPost.size.width)
      };
    } catch (error) {
      return { 'left': 0, 'width': 0 };
    }
  }

  // 当前下划线动画
  private getCurIndicatorInfo(index: number, event: SwiperAnimationEvent): Record<string, number> {
    let nextIndex = index;
    // 滑动范围限制，Swiper不可循环，Scroll保持不可循环
    if (index > 0 && event.currentOffset > 0) {
      nextIndex--; // 左滑
    } else if (index < this.arr.length - 1 && event.currentOffset < 0) {
      nextIndex++; // 右滑
    }
    // 获取当前tabbar的属性信息
    let curInfo = this.getTextInfo(index);
    // 获取目标tabbar的属性信息
    let nextInfo = this.getTextInfo(nextIndex);
    // 滑动页面超过一半时页面切换
    this.swipeRatio = Math.abs(event.currentOffset / this.swiperWidth);
    let curIndex = this.swipeRatio > 0.5 ? nextIndex : index; // 页面滑动超过一半，tabBar切换到下一页。
    let curLeft = curInfo.left + (nextInfo.left - curInfo.left) * this.swipeRatio;
    let curWidth = curInfo.width + (nextInfo.width - curInfo.width) * this.swipeRatio;
    this.indicatorIndex = curIndex;
    return { 'index': curIndex, 'left': curLeft, 'width': curWidth };
  }

  private scrollIntoCenter(currentIndex: number): void {
    const indexInfo = this.getTextInfo(currentIndex);
    let tabPositionLeft = indexInfo.left;
    let tabWidth = indexInfo.width;
    // 获取屏幕宽度
    const screenWidth = this.displayInfo != null ? this.uiContext.px2vp(this.displayInfo.width) : 0;
    const curOffsetX: number = this.scroller.currentOffset().xOffset; // 当前滚动的偏移量
    this.scroller.scrollTo({
      // 将tabbar定位在正中间
      xOffset: curOffsetX + tabPositionLeft - screenWidth / 2 + tabWidth / 2,
      yOffset: 0,
      animation: {
        duration: this.animationDuration,
        curve: Curve.Linear,
      }
    });
    this.scrollUnderline(currentIndex);
  }

  private startAnimateTo(marginLeft: number): void {
    this.uiContext.animateTo({
      duration:this.animationDuration, // 动画时长
      curve: Curve.Linear, // 动画曲线
      iterations: 1, // 播放次数
      playMode: PlayMode.Normal, // 动画模式
    }, () => {
      this.indicatorMarginLeft = marginLeft;
    });
  }

  // 下划线动画
  private scrollUnderline(index: number): void {
    let indexInfo = this.getTextInfo(index);
    let offsetX = (this.getCurTextWidth(index) - this.indicatorWidth) / 2;
    this.startAnimateTo(indexInfo.left + offsetX);
  }

  // 获取当前文本宽度
  private getCurTextWidth(index: number): number {
    const width = this.measureUtil.measureText({
      textContent: this.arr[index],
      fontSize: CommonConstants.M_FONT_SIZE,
      fontWeight: TabConstants.SELE_FONT_WEIGHT
    });
    return this.uiContext.px2vp(width);
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Row({ space: CommonConstants.L_PUBLIC_SPACE }) {
          Row() {
            Image($r('app.media.search'))
              .width(TabConstants.TAB_ICON_WIDTH)
              .height(TabConstants.TAB_ICON_HEIGHT)
              .fillColor('#767A7D')
              .margin({ left: CommonConstants.PUBLIC_SPACE });
            TextInput({ placeholder: '搜你感兴趣的车' })
              .width('60%')
              .backgroundColor(Color.White);
            Image($r('app.media.scan'))
              .width(TabConstants.TAB_ICON_WIDTH)
              .height(TabConstants.TAB_ICON_HEIGHT);
            Image($r('app.media.split'))
              .width(1)
              .height(TabConstants.TAB_ICON_HEIGHT)
              .margin({ left: CommonConstants.PUBLIC_SPACE, right: CommonConstants.PUBLIC_SPACE * 4 / 3 });
            Text('搜索')
              .fontColor('#0A59F7');
          }
          .width(300)
          .height(40)
          .layoutWeight(1)
          .borderRadius(50)
          .backgroundColor(Color.White);

          Badge({
            value: '',
            style: { badgeSize: 6, badgeColor: '#FA2A2D' }
          }) {
            Image($r('app.media.chat'))
              .width(TabConstants.TAB_ICON_WIDTH)
              .height(TabConstants.TAB_ICON_HEIGHT)
              .fillColor(Color.Black)
              .margin({ top: 3, right: 2 });
          };
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({
          left: CommonConstants.L_PUBLIC_SPACE,
          right: CommonConstants.L_PUBLIC_SPACE
        });

        Row() {
          Scroll(this.scroller) {
            Row({ space: CommonConstants.PUBLIC_SPACE * 2 }) {
              ForEach(this.arr, (item: string, index: number) => {
                Column() {
                  Text(item)
                    .fontColor(this.indicatorIndex === index ? TabConstants.SELE_FONT_COLOR :
                      TabConstants.DEF_FONT_COLOR)
                    .fontWeight(TabConstants.DEF_FONT_WEIGHT)
                    .id(index.toString())
                    .onAreaChange((oldValue: Area, newValue: Area) => {
                      let width = Number.parseFloat(newValue.width.toString());
                      if (this.indicatorIndex === index && this.indicatorMarginLeft === 0) {
                        if (newValue.globalPosition.x !== undefined) {
                          let positionX = Number.parseFloat(newValue.globalPosition.x.toString());
                          this.indicatorMarginLeft = Number.isNaN(positionX) ? 0 : positionX;
                        }
                      }
                    })
                    .onClick(() => {
                      this.indicatorIndex = index;
                      // 点击tabbar下划线动效
                      this.scrollUnderline(index);
                      this.scrollIntoCenter(index);
                      // 跟swiper进行联动
                      this.swiperIndex = index;
                      this.uiContext.getPromptAction().showToast({
                        message: '仅作展示',
                        duration: CommonConstants.ADVERTISING_INTERVAL_TIME,
                        bottom: RecommendationConstants.TOAST_HEIGHT
                      });
                    });
                };
              }, (item: string) => item);
            }
            .height(TabConstants.TAB_HEIGHT);
          }
          .padding({ left: 24 })
          .layoutWeight(1)
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(40) })
          // 滚动事件回调, 返回滚动时水平、竖直方向偏移量
          .onWillScroll((xOffset: number) => {
            this.indicatorMarginLeft -= xOffset;
          })
          // 滚动停止事件回调
          // .onScrollStop(() => {
          //   this.scrollUnderline(0, this.indicatorIndex);
          // });

          Image($r('app.media.public_ic_app'))
            .width(CommonConstants.PIC_WIDTH)
            .height(CommonConstants.PIC_HEIGHT)
            .margin({
              left: CommonConstants.L_PUBLIC_SPACE,
              right: CommonConstants.L_PUBLIC_SPACE,
            });

        };

        Column()
          .width(this.indicatorWidth)
          .height(TabConstants.INDICATOR_HEIGHT)
          .backgroundColor(TabConstants.SELE_FONT_COLOR)
          .alignSelf(ItemAlign.Start)
          .margin({ left: this.indicatorMarginLeft });
      }
      .width(CommonConstants.COLUMN_WIDTH)
      .zIndex(10)
      .alignItems(HorizontalAlign.Center)
      .padding({ top: CommonConstants.PUBLIC_SPACE })
      .height(TabConstants.TAB_COL_HEIGHT)
      .padding({ top: this.topHeight + CommonConstants.PUBLIC_SPACE });

      Swiper(this.swiperController) {
        Column() {
          RecommendationComp();
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .height(CommonConstants.COLUMN_HEIGHT)
        .onAreaChange((oldValue: Area, newValue: Area) => {
          let width = Number.parseFloat(newValue.width.toString());
          this.swiperWidth = Number.isNaN(width) ? 0 : width;
        });
      }
      .disableSwipe(true)
      .onChange((index: number) => {
        this.swiperIndex = index;
      })
      .cachedCount(1)
      // 跟自定义tabbar进行联动效果
      .index(this.swiperIndex)
      .indicator(false)
      .curve(Curve.Linear)
      .loop(false)
      .onAnimationStart((targetIndex: number) => {
        // 切换动画开始时触发该回调。下划线跟着页面一起滑动，同时宽度渐变。
        this.indicatorIndex = targetIndex;
        this.scrollUnderline(targetIndex);
      })
      .onAnimationEnd((index: number) => {
        // 切换动画结束时触发该回调。下划线动画停止。
        this.scrollIntoCenter(index);
      })
      .onGestureSwipe((index: number, event: SwiperAnimationEvent) => {
        // 在页面跟手滑动过程中，逐帧触发该回调。
        let currentIndicatorInfo = this.getCurIndicatorInfo(index, event);
        this.indicatorIndex = currentIndicatorInfo.index; //当前页签index
        let positionXOther = (this.getCurTextWidth(index) - this.indicatorWidth) / 2;
        this.indicatorMarginLeft = currentIndicatorInfo.left + positionXOther; //当前页签距离左边margin
      });
    }
    .width(CommonConstants.COLUMN_WIDTH)
    .height(CommonConstants.COLUMN_HEIGHT);
  }
}
