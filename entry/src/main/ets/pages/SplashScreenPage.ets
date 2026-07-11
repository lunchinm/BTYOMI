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

/**
 * SplashScreenPage is the entry of the application and shows how to develop a front page.
 * Stay in SplashScreenPage for seconds to jump to the MainPage.
 * Developers can replace background images with advertising videos.
 */
@Component
export struct SplashScreenPage {
  @StorageProp('avoidArea') top: number = 0;
  @State pageShowTime: number = CommonConstants.TIME_DEFAULT_VALUE;
  @State intervalID: number = CommonConstants.INTERVAL_ID_DEFAULT;
  @Consume('pageInfos') pageInfos: NavPathStack;
  private imgRdm: string = 'app.media.ic_launcher_background_' + CommonConstants.SPLASH_IMAGES;

  /**
   * 第一次启动或未同意隐私政策，1秒logo跳转到隐私政策查看页，点击返回/拒绝按钮退出app，点击同意进入5s随机闪屏页。
   * 非第一次启动且同意隐私政策，直接显示5秒随机闪屏页。点击跳过，进入登录页。
   */


  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          Image($r(`${this.imgRdm}`))
            .width(CommonConstants.COLUMN_WIDTH)
            .height(CommonConstants.COLUMN_HEIGHT);
          this.SkipButton();
        }
        .layoutWeight(CommonConstants.STACK_LAYOUT_WEIGHT)
        .width(CommonConstants.COLUMN_WIDTH)
        .alignContent(Alignment.TopEnd);
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.COLUMN_WIDTH)
      .height(CommonConstants.COLUMN_HEIGHT);
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.intervalID = setInterval(() => {
        this.pageShowTime += CommonConstants.INCREMENT_VALUE;
        if (this.pageShowTime >= CommonConstants.DELAY_SECONDS_FIVE) {
          this.pageInfos.replacePath({ name: 'LoginPage' });
        }
      }, CommonConstants.INTERVAL_DELAY);
    })
    .onHidden(() => {
      clearInterval(this.intervalID);
    });
  }

  @Builder
  SkipButton() {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.End
    }) {
      Text($r('app.string.skip', (CommonConstants.DELAY_SECONDS_FIVE - this.pageShowTime)))
        .backgroundColor($r('app.color.rect_area_background'))
        .borderRadius(CommonConstants.BORDER_RADIUS)
        .fontColor(Color.White)
        .width($r('app.float.skip_text_width'))
        .height($r('app.float.skip_text_height'))
        .fontSize($r('app.float.skip_text_size'))
        .margin({
          right: $r('app.float.skip_text_margin_right'),
          top: $r('app.float.skip_text_margin_top')
        })
        .textAlign(TextAlign.Center)
        .border({ width: CommonConstants.SKIP_TEXT_BORDER_WIDTH })
        .borderColor($r('app.color.rect_stroke'))
        .onClick(() => {
          this.pageInfos.replacePath({ name: 'LoginPage' }, false);
        });
    }.position({ y: this.top });
  }
}
