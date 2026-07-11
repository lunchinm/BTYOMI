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

import { CommonConstants } from '@ohos/common';
import { majorInfo } from '../model/MajorModel';
import { MajorConstants } from '../constants/MajorConstants';

@Component
export struct MajorList {
  @Prop majorList: majorInfo[];

  build() {
    List() {
      ForEach(this.majorList, (item: majorInfo) => {
        ListItem() {
          Column({ space: CommonConstants.PUBLIC_SPACE / 4 }) {
            Text(item.num.toString()).fontWeight(MajorConstants.FONT_WEIGHT)
            Text(item.title).fontSize(CommonConstants.S_FONT_SIZE)
          }
          .width(109)
        }
      })
    }
    .scrollBar(BarState.Off)
    .enableScrollInteraction(false)
    .listDirection(Axis.Horizontal)
    .divider({
      strokeWidth: 1,
      color: 'rgba(0, 0, 0, 0.1)',
      startMargin:CommonConstants.S_PUBLIC_SPACE,
      endMargin:CommonConstants.S_PUBLIC_SPACE,
    })
    .width(CommonConstants.COLUMN_WIDTH)
  }
}
