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

import { CommonConstants, ActivityInfo } from '@ohos/common';

@Component
export struct ActivityItemComp {
  @Prop itemData: ActivityInfo;

  build() {
    Flex({ alignItems: ItemAlign.Center }) {
      Column() {
        Divider().layoutWeight(1).backgroundColor('#ccc').width(1);
        Column({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
          Text(this.itemData.date)
            .fontSize(CommonConstants.M_FONT_SIZE)
            .fontWeight(FontWeight.Bold);
          Text(this.itemData.time)
            .fontSize(CommonConstants.M_FONT_SIZE)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ccc');
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .height(63)
        .backgroundImage($r('app.media.background'))
        .backgroundImageSize(ImageSize.Cover)
        .justifyContent(FlexAlign.Center);

        Divider().layoutWeight(1).backgroundColor('#ccc').width(1);
      }
      .width(65)
      .height(CommonConstants.COLUMN_WIDTH)
      .margin({ right: CommonConstants.PUBLIC_SPACE / 3 });

      Flex({ direction: FlexDirection.Column }) {
        Flex() {
          Image(this.itemData.image)
            .width(100).height(CommonConstants.COLUMN_WIDTH)
            .margin({ right: CommonConstants.PUBLIC_SPACE });
          Column({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
            Text('车友活动')
              .fontSize(CommonConstants.S_FONT_SIZE)
              .width(CommonConstants.COLUMN_WIDTH)
              .textAlign(TextAlign.End);
            Text(this.itemData.title)
              .maxLines(2)
              .fontSize(CommonConstants.M_FONT_SIZE)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontWeight(FontWeight.Bold);
            Blank();
            Text(this.itemData.description)
              .maxLines(1)
              .fontSize(CommonConstants.S_FONT_SIZE)
              .fontColor('#ccc')
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          .alignItems(HorizontalAlign.Start)
          .height(CommonConstants.COLUMN_WIDTH)
          .layoutWeight(1);
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .margin({ bottom: CommonConstants.PUBLIC_SPACE });

        Row() {
          Image(this.itemData.headerIcon)
            .width(16).height(16)
            .borderRadius(8)
            .margin({ right: CommonConstants.PUBLIC_SPACE / 2 });
          Text('轿车官方')
            .fontSize(CommonConstants.S_FONT_SIZE)
            .fontWeight(FontWeight.Bold);
          Blank();
          Text(`2252浏览量`)
            .fontSize(CommonConstants.S_FONT_SIZE)
            .fontColor('#999');
        }
        .width(CommonConstants.COLUMN_WIDTH);
      }
      .padding(CommonConstants.PUBLIC_SPACE)
      .backgroundColor('#fff6f1f1')
      .layoutWeight(1);
    }
    .width(CommonConstants.COLUMN_WIDTH)
    .height(130);
  }
}
