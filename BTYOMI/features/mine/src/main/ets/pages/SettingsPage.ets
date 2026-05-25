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

import { PageHeaderComp, CommonConstants } from '@ohos/common/Index';

interface item {
  title: string;
  type: string;
}

@Component
export struct SettingsPage {
  listData: item[] = [
    { title: '修改登录密码', type: 'password' },
    { title: '通知设置', type: 'notification' },
    { title: '检查版本', type: 'version' },
    { title: '隐私政策', type: 'privacy' },
    { title: '清空本地缓存', type: 'clearStorage' },
    { title: '切换版本', type: 'check' },
    { title: '注销账号', type: 'logOff' },
    { title: '安全退出', type: 'exit' }
  ];
  @StorageProp('avoidArea') topHeight: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;

  @Builder
  settingListItem(itemData: item) {
    Column() {
      Row() {
        Text(`${itemData.title}`)
          .fontSize(13)
          .fontWeight(450);
        Blank();
        if (itemData.type === 'version') {
          Text('v4.1.3').fontSize(12).fontColor('#ffa7a4a4').margin({ right: 5 });
        }
        if (itemData.type === 'clearStorage') {
          Text('106.7M').fontSize(12).fontColor('#ffa7a4a4').margin({ right: 5 });
        }
        Image($r('app.media.mi_ic_right_arrow'))
          .width(12)
          .height(12);
      }
      .padding(CommonConstants.MAIN_PADDING)
      .width(CommonConstants.COLUMN_WIDTH)
      .backgroundColor('#fff');

      Divider();
    }
    .width(CommonConstants.COLUMN_WIDTH)
    .padding({ left: CommonConstants.MAIN_PADDING, right: CommonConstants.MAIN_PADDING });
  }

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: '设置',
          backAction: () => {
            this.pageInfos.pop();
          }
        });
        List() {
          ForEach(this.listData, (itemData: item) => {
            ListItem() {
              this.settingListItem(itemData);
            };
          });
        };
      }
      .width(CommonConstants.COLUMN_WIDTH)
      .height(CommonConstants.COLUMN_HEIGHT)
      .backgroundColor('#ffefeeee')
      .padding({ top: this.topHeight });
    }
    .hideTitleBar(true);
  }
}
