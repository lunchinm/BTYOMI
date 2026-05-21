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

export class ActivityInfo {
  headerIcon: ResourceStr
  image: ResourceStr
  title: string
  description: string
  date: string
  time: string
  seeNum: number

  constructor(headerIcon: ResourceStr, image: ResourceStr, title: string, description: string, date: string,
    time: string, seeNum: number) {
    this.headerIcon = headerIcon;
    this.image = image;
    this.title = title;
    this.description = description;
    this.date = date;
    this.time = time;
    this.seeNum = seeNum;
  }
}

class ActivityModel {
  getMainList(): ActivityInfo[] {
    return [
      new ActivityInfo($r('app.media.back1'), $r('app.media.back4'), '到店打卡，解锁快乐密“华”',
        '福利加“华”，“转”出无线惊喜', '05-24', '10:11', 8896),
      new ActivityInfo($r('app.media.back3'), $r('app.media.back2'), '六一活动特辑 | 小华DIY创意征集', '儿童节快乐！',
        '3天前', '10:11', 642),
      new ActivityInfo($r('app.media.back2'), $r('app.media.back7'), '轿车小华 | 提车日记来袭', '晒提车日记 领积分好礼',
        '3天前', '10:11', 2209),
      new ActivityInfo($r('app.media.back6'), $r('app.media.back3'), '如一热爱 共我轿车',
        '“小华1号车主”是信任不渝的同行者，是与品牌共进的老朋友', '5小时前', '10:11', 2209),
      new ActivityInfo($r('app.media.back4'), $r('app.media.back6'), '今日玩“色”', '周周话题', '1小时前', '10:11', 305),
      new ActivityInfo($r('app.media.back8'), $r('app.media.back8'), '为轿车小华应援',
        '“小华1号车主”是信任不渝的同行者，是与品牌共进的老朋友', '5小时前', '10:11', 2209),
      new ActivityInfo($r('app.media.back9'), $r('app.media.back10'), '轿车小华 声声答题大闯关', '周周话题', '1小时前',
        '10:11', 305),
    ];
  }
}

export const activity = new ActivityModel();

export class RecomActivityInfo {
  headerImg: ResourceStr
  title: string
  name: string
  date: string
  seeNum: number
  image: ResourceStr

  constructor(headerImg: ResourceStr, title: string, name: string, date: string, seeNum: number, image: ResourceStr) {
    this.headerImg = headerImg;
    this.title = title;
    this.name = name;
    this.date = date;
    this.seeNum = seeNum;
    this.image = image;
  }
}

class RecomActivityModel {
  getMainList(): RecomActivityInfo[] {
    return [
      new RecomActivityInfo($r('app.media.back1'), '到店打卡，解锁快乐驾驶体验', '轿车官方', '05/24', 8896,
        $r('app.media.back11')),
      new RecomActivityInfo($r('app.media.avatar1'), '元宵节日特惠，现在订车有优惠', '市场咨询', '3天前', 642,
        $r('app.media.back13')),
      new RecomActivityInfo($r('app.media.back7'), '买车必看指南', '轿车官方', '3天前', 2209, $r('app.media.back14')),
      new RecomActivityInfo($r('app.media.back6'), '如一热爱 共我轿车', '汽车百科', '5小时前', 2209,
        $r('app.media.back12')),
      new RecomActivityInfo($r('app.media.back2'), '今日玩“色”', '轿车官方', '22小时前', 305, $r('app.media.back11')),
      new RecomActivityInfo($r('app.media.back3'), '为轿车小华应援', '汽车百科', '5小时前', 2209,
        $r('app.media.back13')),
      new RecomActivityInfo($r('app.media.back4'), '轿车小华 声声答题大闯关', '轿车官方', '22小时前', 305,
        $r('app.media.back14')),
    ];
  }
}

export const recomActivity = new RecomActivityModel();