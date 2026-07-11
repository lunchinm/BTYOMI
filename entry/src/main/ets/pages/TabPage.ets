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

import { Permissions } from '@kit.AbilityKit';
import { CommonConstants, permissionsUtil } from '@ohos/common';
import { TabConstants } from '../constants/TabConstants';
import { ExplorePage } from '@ohos/explore';
import { ShoppingMallPage } from '@ohos/shoppingMall';
import { BuyingCarPage } from '@ohos/buyingCar';
import { ServicePage } from '@ohos/service';
import { MinePage } from '@ohos/mine';

@Component
export struct TabPage {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_SM;
  @State currentTabIndex: number = 0;
  @StorageProp('bottom') bottom: number = 0;
  private permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];

  aboutToAppear(): void {
    permissionsUtil.checkPermissions(this.permissions, this.getUIContext());
  }

  @Builder
  BuildTabs(icon: ResourceStr, title: ResourceStr, index: number) {
    Column({ space: CommonConstants.PUBLIC_SPACE / 2 }) {
      Image(this.currentTabIndex === 0 && this.currentTabIndex === index ? $r('app.media.bottomtab_item_special') :
        icon)
        .width(this.currentTabIndex === 0 && this.currentTabIndex === index ? TabConstants.TAB_ICON_WIDTH * 3 / 2 :
          TabConstants.TAB_ICON_WIDTH)
        .height(this.currentTabIndex === 0 && this.currentTabIndex === index ? TabConstants.TAB_ICON_WIDTH * 3 / 2 :
          TabConstants.TAB_ICON_HEIGHT)
        .fillColor(this.currentTabIndex === index ? TabConstants.SELE_COLOR : TabConstants.DEF_COLOR);
      Text(this.currentTabIndex === 0 && this.currentTabIndex === index ? '' : title)
        .fontSize(CommonConstants.S_FONT_SIZE)
        .fontWeight(FontWeight.Regular)
        .fontColor(this.currentTabIndex !== index ? TabConstants.DEF_COLOR : TabConstants.SELE_COLOR);
    };
  }

  build() {
    NavDestination() {
      GridRow({
        breakpoints: { value: CommonConstants.BREAK_POINTS_VALUE, reference: BreakpointsReference.WindowSize },
        columns: { sm: CommonConstants.COLUMN_SM, md: CommonConstants.COLUMN_MD, lg: CommonConstants.COLUMN_LG },
        direction: GridRowDirection.Row
      }) {
        GridCol({
          span: { sm: CommonConstants.COLUMN_SM, md: CommonConstants.COLUMN_MD, lg: CommonConstants.COLUMN_LG }
        }) {
          Column() {
            Tabs({
              barPosition: this.breakPoint === CommonConstants.BREAK_POINT_LG ? BarPosition.Start : BarPosition.End,
              index: this.currentTabIndex
            }) {
              TabContent() {
                if (this.currentTabIndex === 0) {
                  ExplorePage();
                }
              }
              .tabBar(this.BuildTabs($r('app.media.bottomtab_item'), '首页', 0));

              TabContent() {
                if (this.currentTabIndex === 1) {
                  ShoppingMallPage();
                }
              }
              .tabBar(this.BuildTabs($r('app.media.cart'), '商城', 1));

              TabContent() {
                if (this.currentTabIndex === 2) {
                  BuyingCarPage();
                }
              }
              .tabBar(this.BuildTabs($r('app.media.direction_car'), '选车', 2));

              TabContent() {
                if (this.currentTabIndex === 3) {
                  ServicePage();
                }
              }
              .tabBar(this.BuildTabs($r('app.media.service'), '服务', 3));

              TabContent() {
                if (this.currentTabIndex === 4) {
                  MinePage();
                }
              }
              .tabBar(this.BuildTabs($r('app.media.person'), '我的', 4));
            }
            .vertical(this.breakPoint === CommonConstants.BREAK_POINT_LG)
            .barWidth(this.breakPoint === CommonConstants.BREAK_POINT_LG ? TabConstants.TAB_BAR_L_WIDTH :
              TabConstants.TAB_BAR_HEIGHT)
            .barHeight(this.breakPoint === CommonConstants.BREAK_POINT_LG ? TabConstants.TAB_BAR_L_HEIGHT :
              TabConstants.TAB_BAR_M_HEIGHT)
            .scrollable(false)
            .onChange((index: number) => {
              this.currentTabIndex = index;
            })
            .padding({ bottom: this.bottom });
          };
        };
      }
      .onBreakpointChange((breakpoints: string) => {
        this.breakPoint = breakpoints;
      });
    }
    .hideTitleBar(true);
  }
}
