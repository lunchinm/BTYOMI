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

@Component
export struct LoginPage {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_SM;
  @State phone: string = '';
  @State password: string = '';
  @State isAnimatedPhoNum: boolean = false;
  @State isAnimatedPwd: boolean = false;
  @State isPwdIptShow: boolean = false;
  @State isPwdLgn: boolean = false;
  @State isCodeLgn: boolean = false;
  @State isAgree: boolean = false;
  @StorageProp('bottom') bottom: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;
  uiContext: UIContext = this.getUIContext();

  @Builder
  OverlayNode() {
    Column() {
      if (this.isAnimatedPhoNum) {
        Column() {
          Text(this.isCodeLgn ? $r('app.string.sent_to') : $r('app.string.phone_number'))
            .fontSize(CommonConstants.S_FONT_SIZE).fontColor(Color.White);
        }
        .clip(true)
        .offset({ y: -20 })
        .geometryTransition('textInput');
      } else {
        Text(this.isCodeLgn ? $r('app.string.sent_to') : $r('app.string.phone_number'))
          .fontSize(CommonConstants.L_FONT_SIZE)
          .fontColor(Color.White)
          .clip(true)
          .geometryTransition('textInput');
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width('80vp')
    .height('50vp')
    .offset({ y: -10 });
  }

  @Builder
  OverlayNodePwd() {
    Column() {
      if (this.isAnimatedPwd) {
        Column() {
          Text(this.isCodeLgn ? $r('app.string.ver_code') : $r('app.string.login_password'))
            .fontSize(CommonConstants.S_FONT_SIZE).fontColor(Color.White);
        }
        .clip(true)
        .offset({ y: -20 })
        .geometryTransition('textInput');
      } else {
        Text(this.isCodeLgn ? $r('app.string.ver_code') : $r('app.string.login_password'))
          .fontSize(CommonConstants.L_FONT_SIZE)
          .fontColor(Color.White)
          .clip(true)
          .geometryTransition('textInput');
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.End)
    .width('80vp');
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
            Column() {
              Stack() {
                if (this.isPwdIptShow) {
                  Text('修改')
                    .fontSize(CommonConstants.M_FONT_SIZE)
                    .fontColor($r('app.color.main_color'))
                    .offset({ x: -40 })
                    .onClick(() => {
                      // this.phone = ''
                      this.isPwdIptShow = !this.isPwdIptShow;
                    });
                }
                TextInput({ text: this.phone })
                  .maxLength(CommonConstants.INPUT_PHONE_LENGTH)
                  .textInputStyle()
                  .overlay(this.OverlayNode())
                  .enabled(!this.isPwdIptShow)
                  .borderRadius('0vp')
                  .padding({ left: 0 })
                  .onFocus(() => {
                    if (this.phone === '') {
                      this.uiContext.animateTo({ duration: 100 }, () => {
                        this.isAnimatedPhoNum = !this.isAnimatedPhoNum;
                      });
                    }
                  })
                  .onBlur(() => {
                    if (this.phone === '') {
                      this.uiContext.animateTo({ duration: 100 }, () => {
                        this.isAnimatedPhoNum = !this.isAnimatedPhoNum;
                      });
                    }
                  })
                  .onChange((value: string) => {
                    this.phone = value;
                  });
              }
              .alignContent(Alignment.Center)
              .borderWidth({ bottom: 1 })
              .width(CommonConstants.COLUMN_WIDTH);

              if (this.isPwdIptShow) {
                Stack() {
                  TextInput({ text: this.password })
                    .type(InputType.Password)
                    .showPasswordIcon(false)
                    .maxLength(CommonConstants.INPUT_PASSWORD_LENGTH)
                    .textInputStyle()
                    .overlay(this.OverlayNodePwd())
                    .padding({ left: 0 })
                    .borderRadius('0vp')
                    .onFocus(() => {
                      if (this.password === '') {
                        this.uiContext.animateTo({ duration: 100 }, () => {
                          this.isAnimatedPwd = !this.isAnimatedPwd;
                        });
                      }
                    })
                    .onBlur(() => {
                      if (this.password === '') {
                        this.uiContext.animateTo({ duration: 100 }, () => {
                          this.isAnimatedPwd = !this.isAnimatedPwd;
                        });
                      }
                    })
                    .onChange((value: string) => {
                      this.password = value;
                    });

                  if (this.isCodeLgn) {
                    Row() {
                      Line().height(14).backgroundColor($r('app.color.main_color'));
                      Text('获取验证码')
                        .fontSize(CommonConstants.M_FONT_SIZE)
                        .fontColor($r('app.color.main_color'))
                        .margin({ left: '20vp', right: '10vp' })
                        .onClick(() => {
                          this.uiContext.getPromptAction().showToast({
                            message: '手机号格式错误',
                            duration: CommonConstants.ADVERTISING_INTERVAL_TIME,
                          });
                          return;
                        });
                    }
                    .zIndex(1)
                    .justifyContent(FlexAlign.Center);
                  }
                }
                .alignContent(Alignment.End)
                .margin({ top: '20vp' })
                .borderWidth({ bottom: 1 })
                .width(CommonConstants.COLUMN_WIDTH);

                if (this.isCodeLgn) {
                  Text('密码登录')
                    .fontSize(CommonConstants.M_FONT_SIZE)
                    .fontColor($r('app.color.main_color'))
                    .margin({ top: '20vp' })
                    .onClick(() => {
                      this.isPwdLgn = true;
                      this.isCodeLgn = false;
                    });
                } else {
                  Text('验证码登录')
                    .fontSize(CommonConstants.M_FONT_SIZE)
                    .fontColor($r('app.color.main_color'))
                    .margin({ top: '20vp' })
                    .onClick(() => {
                      this.isCodeLgn = true;
                      this.isPwdLgn = false;
                    });
                }
              }
              if (!this.isPwdIptShow) {
                Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                  Checkbox({ name: 'isAgree' })
                    .select($$this.isAgree)
                    .width('14vp')
                    .height('14vp')
                    .margin({ left: 0 })
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .selectedColor($r('app.color.main_color'));
                  Text('我已阅读并同意').smTextStyle();
                  Text('《用户协议》').smTextStyle().fontColor($r('app.color.main_color'));
                  Text('与').smTextStyle();
                  Text('《隐私条款》').smTextStyle().fontColor($r('app.color.main_color'));
                }.margin({ top: '20vp' });
              }
            }
            .height(CommonConstants.COLUMN_HEIGHT)
            .padding({ top: '200vp', left: '20vp', right: '20vp' });

            Flex({ justifyContent: FlexAlign.SpaceEvenly }) {
              if (!this.isPwdIptShow) {
                Button('密码登录', { type: ButtonType.Normal })
                  .width('40%')
                  .fontSize(CommonConstants.M_FONT_SIZE)
                  .borderWidth(2)
                  .backgroundColor(Color.Transparent)
                  .fontColor($r('app.color.main_color'))
                  .borderColor($r('app.color.main_color'))
                  .enabled(isLoginClickable(this.phone))
                  .onClick(() => {
                    if (this.isAgree) {
                      // 如果勾选协议，锁定手机号，显示密码框，替换下方按钮为登录
                      this.isPwdIptShow = !this.isPwdIptShow;
                      this.isPwdLgn = true;
                    } else {
                      // 否则提示先勾选协议
                      this.uiContext.getPromptAction().showToast({
                        message: '请勾选同意《用户协议》和《隐私政策》',
                        duration: CommonConstants.ADVERTISING_INTERVAL_TIME,
                      });
                      return;
                    }
                  });
                Button('验证码登录', { type: ButtonType.Normal })
                  .width('40%')
                  .fontSize(CommonConstants.M_FONT_SIZE)
                  .backgroundColor($r('app.color.main_color'))
                  .enabled(isLoginClickable(this.phone))
                  .onClick(() => {
                    if (this.isAgree) {
                      // 如果勾选协议，锁定手机号，显示密码框，替换下方按钮为登录。
                      this.isPwdIptShow = !this.isPwdIptShow;
                      this.isCodeLgn = true;
                    } else {
                      // 否则提示先勾选协议
                      this.uiContext.getPromptAction().showToast({
                        message: '请勾选同意《用户协议》和《隐私政策》',
                        duration: CommonConstants.ADVERTISING_INTERVAL_TIME,
                      });
                      return;
                    }
                  });
              } else {
                Button('登录', { type: ButtonType.Normal })
                  .width('calc(100% - 40vp)')
                  .fontSize(CommonConstants.M_FONT_SIZE)
                  .backgroundColor($r('app.color.main_color'))
                  .enabled(this.isCodeLgn ? (this.password.length > 5 ?? false)
                    : this.password !== '')
                  .onClick(() => {
                    this.pageInfos.replacePath({ name: 'TabPage' }, false);
                  });
              }
            }
            .padding({ bottom: '20vp' });
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .height(CommonConstants.COLUMN_HEIGHT);
        };

        GridCol({ span: { sm: 0, md: 0, lg: 2 } }) {
        };
      }
      .backgroundImage($r('app.media.ic_launcher_background_2'))
      .backgroundImageSize(ImageSize.Cover)
      .padding({ bottom: this.bottom })
      .onBreakpointChange((breakpoints: string) => {
        this.breakPoint = breakpoints;
      });
    }
    .hideTitleBar(true);
  }
}

@Extend(TextInput)
function textInputStyle() {
  .width(CommonConstants.COLUMN_WIDTH)
  .height('40vp')
  .fontSize(CommonConstants.M_FONT_SIZE)
  .backgroundColor(Color.Transparent);
}

@Extend(Text)
function smTextStyle() {
  .fontSize(CommonConstants.S_FONT_SIZE);
}

function isLoginClickable(phoneNum: string): boolean {
  return phoneNum.length > 10;
}