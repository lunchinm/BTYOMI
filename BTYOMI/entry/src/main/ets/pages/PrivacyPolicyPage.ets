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

import { CommonConstants, preferencesUtil } from '@ohos/common';
import { common } from '@kit.AbilityKit';

@Component
export struct PrivacyPolicyPage {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_SM;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private timerId: number = 0;
  scroller: Scroller = new Scroller;
  @StorageProp('avoidArea') topHeight: number = 0;
  @StorageProp('bottom') bottom: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;

  @Builder
  OverlayNode() {
    Column() {
      Image($r('app.media.back'))
        .onClick(() => {
          // TODO 退出应用
          this.context?.terminateSelf();
        });
    }
    .width(20).height(20).alignItems(HorizontalAlign.Center)
    .margin({ left: CommonConstants.PUBLIC_SPACE });
  }

  saveIsPrivacy() {
    preferencesUtil.putPreferencesValue(CommonConstants.PREFERENCES_KEY_PRIVACY, true);
  }

  jumpToAdvertisingPage() {
    this.timerId = setTimeout(() => {
      this.pageInfos.replacePath({ name: 'SplashScreenPage' }, false);
    }, CommonConstants.LAUNCHER_DELAY_TIME);
  }

  build() {
    NavDestination() {
      GridRow({
        breakpoints: { value: CommonConstants.BREAK_POINTS_VALUE, reference: BreakpointsReference.WindowSize },
        columns: { sm: CommonConstants.COLUMN_SM, md: CommonConstants.COLUMN_MD, lg: CommonConstants.COLUMN_LG },
        direction: GridRowDirection.Row
      }) {

        GridCol({
          span: { sm: CommonConstants.COLUMN_SM, md: CommonConstants.COLUMN_MD, lg: CommonConstants.COLUMN_MD }
        }) {
          Flex({ direction: FlexDirection.Column }) {
            Row() {
              Text('隐私政策').fontWeight(700);
            }
            .justifyContent(FlexAlign.Center)
            .height('60vp')
            .width(CommonConstants.COLUMN_WIDTH)
            .overlay(this.OverlayNode(), { align: Alignment.Start });

            Scroll(this.scroller) {
              Column() {
                Text('隐私内容');
              };
            }
            .layoutWeight(1)
            .width(CommonConstants.COLUMN_WIDTH);

            Flex({ justifyContent: FlexAlign.SpaceEvenly }) {
              Button('拒绝并退出')
                .width('40%')
                .borderWidth(0.8)
                .backgroundColor(Color.Transparent)
                .fontColor($r('app.color.init_page_color'))
                .borderColor($r('app.color.init_page_color'))
                .onClick(() => {
                  // TODO 退出应用
                  this.context?.terminateSelf();
                });
              Button('同意').width('40%')
                .backgroundColor(Color.Transparent)
                .linearGradient({
                  direction: GradientDirection.Bottom, // 渐变方向
                  // repeating: true, // 渐变颜色是否重复
                  colors: [['#00F5FF', 0.0], [$r('app.color.init_page_color'), 0.3]] // 数组末尾元素占比小于1时满足重复着色效果
                })
                .onClick(() => {
                  // TODO 进入闪屏页面
                  this.saveIsPrivacy();
                  this.jumpToAdvertisingPage();
                });
            }
            .width(CommonConstants.COLUMN_WIDTH)
            .padding({ top: '10vp', bottom: '10vp' })
            .backgroundColor(Color.White);
          }
          .height(CommonConstants.COLUMN_HEIGHT)
          .padding({ top: this.topHeight, bottom: this.bottom });
        };

        GridCol({ span: { sm: 0, md: 0, lg: 2 } }) {
        };
      }
      .onBreakpointChange((breakpoints: string) => {
        this.breakPoint = breakpoints;
      });
    }
    .hideTitleBar(true)
    .onShown(() => {
      const res = preferencesUtil.getPreferencesValue(CommonConstants.PREFERENCES_KEY_PRIVACY, false);
      if (res) {
        this.jumpToAdvertisingPage();
      }
    })
    .onHidden(() => {
      clearInterval(this.timerId);
    });
  }
}
