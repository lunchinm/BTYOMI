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

export class BrandInfo {
  image: ResourceStr;
  name: string;
  tag: string[];
  price: number;

  constructor(image: ResourceStr, name: string, tag: string[],
    price: number) {
    this.image = image;
    this.name = name;
    this.tag = tag;
    this.price = price;
  }
}

class BrandModel {
  getBrandList(): BrandInfo[] {
    const stnList = [
      new BrandInfo($r('app.media.brand1'), '品牌1', ['星星充电'], 1.15),
      new BrandInfo($r('app.media.brand2'), '品牌2', ['星星充电'], 1.15),
      new BrandInfo($r('app.media.brand1'), '品牌3', ['星星充电'], 1.15),
      new BrandInfo($r('app.media.brand2'), '品牌4', ['星星充电'], 1.15),
      new BrandInfo($r('app.media.brand1'), '品牌5', ['星星充电'], 1.15),
    ];
    return stnList;
  }
}

export const brand = new BrandModel();

export class ListItemInfo {
  alphabet: string;
  brandInfo: BrandInfo[];

  constructor(alphabet: string, brand: BrandInfo[]) {
    this.alphabet = alphabet;
    this.brandInfo = brand;
  }
}

class ListItemModel {
  getListItem(): ListItemInfo[] {
    const itemList = [
      new ListItemInfo('A', brand.getBrandList()),
      new ListItemInfo('B', brand.getBrandList()),
      new ListItemInfo('C', brand.getBrandList()),
      new ListItemInfo('D', brand.getBrandList()),
      new ListItemInfo('E', brand.getBrandList()),
      new ListItemInfo('F', brand.getBrandList())
    ];
    return itemList;
  }
}

export const brandListItem = new ListItemModel();

export class CarInfo {
  image: ResourceStr;
  name: string;
  tag: string[];
  price: number;

  constructor(image: ResourceStr, name: string, tag: string[], price: number) {
    this.image = image;
    this.name = name;
    this.tag = tag;
    this.price = price;
  }
}

class CarModel {
  getCarList(): CarInfo[] {
    const stnList = [
      new CarInfo($r('app.media.brand_car1'), 'M5 智驾版',
        ['2024款-增程器1.5L 涡轮增压 发动机152马力 电动机272马力', '2024款 1.5T 240km 后驱PLUS版 5座'], 24.98),
      new CarInfo($r('app.media.brand_car1'), 'M5 标准版2023款', ['星星充电'], 24.98),
      new CarInfo($r('app.media.brand_car3'), 'M5 纯电智驾版', ['星星充电'], 24.98),
      new CarInfo($r('app.media.brand_car1'), 'M5 智驾版', ['星星充电'], 24.98),
      new CarInfo($r('app.media.brand_car1'), 'M5 标准版2023款', ['星星充电'], 24.98),
      new CarInfo($r('app.media.brand_car3'), 'M5 纯电智驾版', ['星星充电'], 24.98),
    ];
    return stnList;
  }
}

export const car = new CarModel();

export class ParamInfo {
  image: ResourceStr;
  name: string;

  constructor(image: ResourceStr, name: string) {
    this.image = image;
    this.name = name;
  }
}

class ParamIconModelModel {
  getMainList(): ParamInfo[] {
    return [
      new ParamInfo($r('app.media.ic_param1'), '裸车价'),
      new ParamInfo($r('app.media.ic_param2'), '点评'),
      new ParamInfo($r('app.media.ic_param3'), '视频说明书'),
      new ParamInfo($r('app.media.ic_param4'), '实测'),
      new ParamInfo($r('app.media.ic_param5'), '经销商'),
      new ParamInfo($r('app.media.ic_param6'), '养车成本')
    ];
  }
}

export const paramIconModel = new ParamIconModelModel();

class CarParamIconModel {
  getMainList(): ParamInfo[] {
    return [
      new ParamInfo($r('app.media.ic_car_param1'), '加入对比'),
      new ParamInfo($r('app.media.ic_car_param2'), '购车计算'),
      new ParamInfo($r('app.media.ic_car_param3'), '免费咨询'),
    ];
  }
}

export const carParamIcon = new CarParamIconModel();

export const alphabets = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
  'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];