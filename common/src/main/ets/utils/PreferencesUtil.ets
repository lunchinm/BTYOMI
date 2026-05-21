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

// 用户首选项为应用提供Key-Value键值型的数据处理能力，支持应用持久化轻量级数据，并对其修改和查询。
//一个应用内部可以创建多个首选项实例，每个实例都会对应沙箱中的持久化文件
//key是string类型，最大长度限制为80字节
//value为数字型、字符型、布尔型以及这3种类型的数组类型。最大长度为8192个字节

import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';

class PreferencesUtil {
  pref: preferences.Preferences | null = null;

  //创建Preferences实例
  loadPreferences(context: common.UIAbilityContext, name: string) {
    try {
      this.pref = preferences.getPreferencesSync(context, { name });
    } catch (e) {
      // ...
    }
  }

  //写入数据
  async putPreferencesValue(key: string, value: preferences.ValueType) {

    if (!this.pref) {
      return;
    }
    try {
      //写入数据
      this.pref.putSync(key, value);
      //写入文件
      this.pref.flush();
    } catch (e) {
      // ...
    }
  }

  //获取数据
  getPreferencesValue(key: string, defValue: preferences.ValueType) {

    if (!this.pref) {
      return false;
    }
    //写入数据
    let value = this.pref.getSync(key, defValue) as boolean;

    return value;
  }

  //判断是否包含key
  hasPreferenceskey(name: string, key: string): boolean | undefined {
    if (!this.pref) {
      return undefined;
    }
    let isExist: boolean = this.pref.hasSync(key);
    return isExist;
  }

  //删除指定key
  async deletePreferenceskey(key: string) {
    if (!this.pref) {
      return;
    }
    //删除
    this.pref.deleteSync(key);
    //刷盘
    await this.pref.flush();
  }
}

export const preferencesUtil = new PreferencesUtil();