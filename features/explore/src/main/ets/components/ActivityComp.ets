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

import { CommonConstants, TabConstants, ActivityInfo, activity, LazyDataSource } from '@ohos/common';
import { ActivityItemComp } from './ActivityItemComp';

@Component
export struct ActivityComp {
  @StorageProp('avoidArea') topHeight: number = 0;
  activityList: LazyDataSource<ActivityInfo> = new LazyDataSource();

  aboutToAppear(): void {
    this.activityList.pushArrayData(activity.getMainList());
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Column() {
      }
      .backgroundImage($r('app.media.background'))
      .backgroundImageSize(ImageSize.Cover)
      .width(CommonConstants.COLUMN_WIDTH)
      .height(TabConstants.TAB_COL_HEIGHT + this.topHeight);

      List() {
        LazyForEach(this.activityList, (item: ActivityInfo, index: number) => {
          ListItem() {
            Column() {
              ActivityItemComp({ itemData: item });
              if (index !== this.activityList.totalCount() - 1) {
                Row() {
                  Divider().backgroundColor('#ccc').width(1).height(CommonConstants.PUBLIC_SPACE);
                }.width(CommonConstants.COLUMN_WIDTH).justifyContent(FlexAlign.Start).padding({ left: 64 / 2 });
              }
            };
          };
        });
      }
      .padding(CommonConstants.PUBLIC_SPACE)
      .layoutWeight(1);
    }
    .width(CommonConstants.COLUMN_WIDTH);
  }
}
