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

import { CommonConstants, VehicleModelActivitiesInfo } from '@ohos/common';

@Component
export struct VehicleModelActivitiesComp {
  @Prop itemData: VehicleModelActivitiesInfo;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(this.itemData.image).width(CommonConstants.COLUMN_WIDTH).height(CommonConstants.COLUMN_HEIGHT)
      Flex() {
        Text(this.itemData.title)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(CommonConstants.S_FONT_SIZE)
          .fontColor(Color.White)
          .flexGrow(1)
        Text('＞').width(16).height(16).fontColor(Color.White)
      }
      .width(CommonConstants.COLUMN_WIDTH)
      .backgroundColor(Color.Black)
      .padding(CommonConstants.PUBLIC_SPACE / 2)
    }
    .width(120)
    .height(160)
  }
}
