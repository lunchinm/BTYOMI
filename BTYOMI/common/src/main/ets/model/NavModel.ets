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

export class NavInfo {
  id: string = new Date().getTime().toString() // 这种生成方式不好
  icon: ResourceStr
  title: string
  action: ResourceStr
  clickAction: Function = () => {
  }

  constructor(icon: ResourceStr, title: string, action: ResourceStr, clickAction?: Function) {
    this.icon = icon;
    this.title = title;
    this.action = action;
    if (clickAction) {
      this.clickAction = clickAction;
    }
  }
}

class NavModel {
  getNavList(): NavInfo[] {
    return [
      new NavInfo($r('app.media.ic_calendar_and_pencil'), '意见反馈', $r('app.media.mi_ic_right_arrow')),
      new NavInfo($r('app.media.ic_attention'), '关于', $r('app.media.mi_ic_right_arrow'))
    ]
  }

  getSecondNavList(): NavInfo[] {
    return [
      new NavInfo($r('app.media.mi_ic_home'), '支付设置', $r('app.media.mi_ic_right_arrow')),
      new NavInfo($r('app.media.mi_ic_home'), '通知设置', $r('app.media.mi_ic_right_arrow')),
      new NavInfo($r('app.media.mi_ic_home'), '意见反馈', $r('app.media.mi_ic_right_arrow'))
    ]
  }
}

export const nav = new NavModel();
