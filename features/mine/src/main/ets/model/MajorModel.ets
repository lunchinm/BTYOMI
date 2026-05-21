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

export class majorInfo {
  id: string = new Date().getTime().toString() // 这种生成方式不好
  num: number
  title: string
  type: string

  constructor(num: number, title: string, type: string) {
    this.num = num;
    this.title = title;
    this.type = type;
  }
}

export class majorModel {
  getMajorList(): majorInfo[] {
    return [
      new majorInfo(32, '关注', 'AccountSecurity'),
      new majorInfo(16, '点赞', 'NotificationSettings'),
      new majorInfo(7, '收藏', 'Contacts')
    ]
  }
}

export const Major = new majorModel();
