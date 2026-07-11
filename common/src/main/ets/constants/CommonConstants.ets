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

export class CommonConstants{
  /**
   * Breakpoint sm.
   */
  static readonly BREAK_POINT_SM: string = 'sm';

  /**
   * Breakpoint md.
   */
  static readonly BREAK_POINT_MD: string = 'md';

  /**
   * Breakpoint lg.
   */
  static readonly BREAK_POINT_LG: string = 'lg';

  /**
   * The break point value.
   */
  static readonly BREAK_POINTS_VALUE: Array<string> = ['320vp', '600vp', '840vp'];

  /**
   * The number of columns for SM device.
   */
  static readonly COLUMN_SM: number = 4;

  /**
   * The number of columns for MD device.
   */
  static readonly COLUMN_MD: number = 8;

  /**
   * The number of columns for LG device.
   */
  static readonly COLUMN_LG: number = 12;

  static readonly MAX_FONT_SIZE:number = 24;

  static readonly L_FONT_SIZE:number = 16;

  static readonly M_FONT_SIZE:number = 14;

  static readonly S_FONT_SIZE:number = 12;

  static readonly S_PUBLIC_SPACE: number = 8;

  static readonly PUBLIC_SPACE: number = 12;

  static readonly M_PUBLIC_SPACE: number = 14;

  static readonly L_PUBLIC_SPACE: number = 16;

  /**
   * 内边距
   */

  static readonly L_MAIN_PADDING : number = 16;

  static readonly MAIN_PADDING : number = 12;

  static readonly S_MAIN_PADDING : number = 10;

  /**
   * 外边距
   */

  static readonly M_MAIN_MARGIN : number = 10;

  static readonly MAIN_MARGIN : number = 8;

  /**
   * 圆角
   */
  static readonly BORDER_RADIUS: string = '10vp';


  /**
   * Time default value.
   */
  static readonly TIME_DEFAULT_VALUE: number = 0;

  /**
   * Delay seconds.
   */
  static readonly DELAY_SECONDS: number = 0;

  static readonly DELAY_SECONDS_FIVE: number = 5;

  /**
   * Incremental value.
   */
  static readonly INCREMENT_VALUE: number = 1;

  /**
   * Interval delay.
   */
  static readonly INTERVAL_DELAY: number = 1000;

  /**
   * Interval id default value.
   */
  static readonly INTERVAL_ID_DEFAULT: number = 0;

  /**
   * Splash page stack layout weight.
   */
  static readonly STACK_LAYOUT_WEIGHT: number = 1;

  /**
   * Border width of skip text.
   */
  static readonly SKIP_TEXT_BORDER_WIDTH: number = 1;

  /**
   * Column width of splash screen page.
   */
  static readonly COLUMN_WIDTH: string = '100%';

  /**
   * Column height of splash screen page.
   */
  static readonly COLUMN_HEIGHT: string = '100%';

  static readonly NORMAL_TEXT_WEIGHT: number = 500;

  static readonly REGULAR_TEXT_WEIGHT: number = 600;

  static readonly MEDIUM_TEXT_WEIGHT: number = 700;

  static readonly BOLD_TEXT_WEIGHT: number = 800;

  static readonly PREFERENCES_FILE_NAME: string = 'btStore';

  static readonly PREFERENCES_KEY_PRIVACY: string = 'isPrivacy';

  static readonly LAUNCHER_PAGE_TAG: string = 'LauncherPage';

  static readonly LAUNCHER_DELAY_TIME: number = 0;

  static readonly ADVERTISING_INTERVAL_TIME: number = 1000;

  static readonly INPUT_PHONE_LENGTH: number = 11;

  static readonly INPUT_PASSWORD_LENGTH: number = 8;

  static readonly SPLASH_IMAGES: number = 3;

  static readonly MAIN_COLOR: string = '#f54b44';

  static readonly SELE_COLOR: string = 'rgb(10, 89, 247)';

  static readonly DEF_COLOR: string = 'rgb(51, 51, 51)';

  static readonly PRIVACY_POLICY_PAGE_URL: string = 'pages/PrivacyPolicyPage';

  static readonly SPLASH_SCREEN_PAGE: string = 'pages/SplashScreenPage';

  static readonly LOGIN_PAGE_URL: string = 'pages/LoginPage';

  static readonly PIC_WIDTH: number = 24;

  static readonly PIC_HEIGHT: number = 24;

  static readonly L_PIC_WIDTH: number = 36;

  static readonly L_PIC_HEIGHT: number = 36;
}
