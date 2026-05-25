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

import { CommonConstants, CommodityData } from '@ohos/common';

@Component
export struct CommodityItemComp {
  @Prop commodityData: CommodityData;

  build() {
    Column({ space: CommonConstants.MAIN_MARGIN }) {
      Image(this.commodityData.picture)
        .width(CommonConstants.COLUMN_WIDTH).height(120 * (1 + Math.random() * 0.8))
      Text(this.commodityData.description)
        .fontSize(CommonConstants.S_FONT_SIZE)
        .fontWeight(FontWeight.Bold)
        .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(`￥${this.commodityData.price}`)
        .fontSize(CommonConstants.S_FONT_SIZE)
        .fontWeight(FontWeight.Bold)
        .fontColor('rgb(242, 80, 66)')
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.COLUMN_WIDTH)
    .padding({
      bottom: CommonConstants.S_MAIN_PADDING
    })
  }
}
