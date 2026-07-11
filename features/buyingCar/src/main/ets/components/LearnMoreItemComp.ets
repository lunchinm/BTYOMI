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

import { CommonConstants, LearnMoreModelInfo } from '@ohos/common';

@Component
export struct LearnMoreItemComp {
  @Prop itemData: LearnMoreModelInfo;

  build() {
    Flex() {
      Image(this.itemData.image)
        .height(CommonConstants.COLUMN_HEIGHT).width(100)
      Column() {
        Text(this.itemData.title)
          .textStyle(Color.Black, CommonConstants.M_FONT_SIZE, 2)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(this.itemData.description)
          .textStyle(Color.Gray, CommonConstants.S_FONT_SIZE)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .height(CommonConstants.COLUMN_HEIGHT)
      .flexGrow(1)
      .padding({
        left: CommonConstants.PUBLIC_SPACE,
        right: CommonConstants.PUBLIC_SPACE,
        top: CommonConstants.PUBLIC_SPACE / 2,
        bottom: CommonConstants.PUBLIC_SPACE / 2
      })
    }
    .width(300)
    .height(80)
  }
}

@Extend(Text)
function textStyle(fColor: Color, fSize: number, maxLines?: number) {
  .fontColor(fColor)
  .fontSize(fSize)
  .maxLines(maxLines || 1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}
