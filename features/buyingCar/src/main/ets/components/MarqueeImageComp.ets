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

import { CommonConstants, LazyDataSource } from '@ohos/common'

@Component
export struct MarqueeImageComp {
  @Prop imgList: ResourceStr[];
  totalImageList: LazyDataSource<ResourceStr> = new LazyDataSource()
  timeOut: number = 35; // 偏移间隔时间
  toggle: number = 1; // 每次偏移量
  @State positionX: number = 0;
  timer: number | null = null;
  imageWidth: number = 100;
  imageWidthList: number[] = [];
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right });
  deviationPositionX: number = 0; // 偏移原点

  autoPlay() { // 播放
    if (this.timer) {
      clearInterval(this.timer);
    }
    this.timer = setInterval(() => {
      // 第次增量
      this.positionX -= this.toggle;
      // 当positionX值的绝对值大于row自身宽度的一半时
      const space = (this.totalImageList.totalCount() * 2 - 1) * (CommonConstants.PUBLIC_SPACE / 2);
      const imageRowWidth = this.imageWidthList.reduce((pre: number, curr: number) => {
        return pre + curr
      }, 0);
      if (Math.abs(this.positionX) > (imageRowWidth + space) / 2) {
        this.positionX = 0;
      }
    }, this.timeOut);
  }

  aboutToAppear(): void {
    this.autoPlay();
    this.totalImageList.pushArrayData([...this.imgList, ...this.imgList])
  }

  aboutToDisappear(): void {
    clearInterval(this.timer)
  }

  build() {
    Row() {
      Row({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
        LazyForEach(this.totalImageList, (item: ResourceStr, index: number) => {
          Image(item)
            .width(this.imageWidth).height(CommonConstants.COLUMN_HEIGHT)
            .onAreaChange((oldValue, newValue) => {
              this.imageWidthList[index] = Number.parseFloat(newValue.width.toString());
            })
            .onClick(() => {

            })
        })
      }
      .position({ x: this.positionX })
      .width('auto')
    }
    .width(CommonConstants.COLUMN_WIDTH).height(100)
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart(() => {
          clearInterval(this.timer); // 暂停
          this.deviationPositionX = this.positionX;
        })
        .onActionUpdate((event: GestureEvent) => {
          if (event) {
            this.positionX = this.deviationPositionX + event.offsetX;
          }
        })
        .onActionEnd(() => {
          this.autoPlay(); // 开始
        })
    )
  }
}
