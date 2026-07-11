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

import { window } from '@kit.ArkUI';
import { SplashScreenPage } from './SplashScreenPage';
import { PrivacyPolicyPage } from './PrivacyPolicyPage';
import { LoginPage } from './LoginPage';
import { TabPage } from './TabPage';
import { CommodityDetailPage } from '@ohos/shoppingMall';
import { SettingsPage } from '@ohos/mine';
import { OptimalStation } from '@ohos/service';
import { MyCharge } from '@ohos/service';
import { BuyingCarDetailPage, AICarSelectPage } from '@ohos/buyingCar';

@Entry
@Component
struct NavigationPage {
  uiContext: UIContext = this.getUIContext();
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  // 路由
  @Builder
  PagesMap(name: string) {
    if (name === 'SplashScreenPage') { // 图片倒计时页面
      SplashScreenPage();
    } else if (name === 'PrivacyPolicyPage') { // 隐私政策
      PrivacyPolicyPage();
    } else if (name === 'LoginPage') { // 登录页
      LoginPage();
    } else if (name === 'TabPage') { // tab页
      TabPage();
    } else if (name === 'CommodityDetailPage') { // 商品详情
      CommodityDetailPage();
    } else if (name === 'BuyingCarDetailPage') { // 选车详情
      BuyingCarDetailPage();
    } else if (name === 'AICarSelectPage') { // AI选车
      AICarSelectPage();
    } else if (name === 'SettingsPage') { //  我的设置
      SettingsPage();
    } else if (name === 'OptimalStation') { // 最优站点
      OptimalStation();
    } else if (name === 'MyCharge') { // 我的充电
      MyCharge();
    }
  }

  aboutToAppear(): void {
    if (this.pageInfos === undefined) {
      this.pageInfos = new NavPathStack();
    }
    this.pageInfos.replacePath({ name: 'PrivacyPolicyPage' }, false);
    // 获取状态栏、导航条的高度
    window.getLastWindow(this.uiContext.getHostContext()).then((windowStage: window.Window) => {
      let area = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      let topHeight = this.uiContext.px2vp(area.topRect.height);
      let bottomArea = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let bottom = this.uiContext.px2vp(bottomArea.bottomRect.height);
      if (topHeight > 0) {
        // 全局存储
        AppStorage.setOrCreate('avoidArea', topHeight);
        AppStorage.setOrCreate('bottom', bottom);
      }
    });
  }

  build() {
    Navigation(this.pageInfos) {
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap);
  }
}
