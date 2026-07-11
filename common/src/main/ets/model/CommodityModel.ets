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


export interface CommodityData {
  description: string
  price: number
  picture: ResourceStr
  inventory: number
  id: string
}

export class CommodityModel {
  private readonly commodityList: CommodityData[] = [
    {
      description: '【含基础安装】倍思星云系列交流冲顶庄(4G版本)',
      price: 1599.00,
      picture: $r('app.media.back13'),
      inventory: 20,
      id: 'a'
    },
    {
      description: '【含30米安装】倍思星云系列交流冲顶庄(4G版本)',
      price: 1799.00,
      picture: $r('app.media.back11'),
      inventory: 100,
      id: 'b'
    },
    {
      description: '【0米送装一体】直达守护者7kw刷卡版',
      price: 1399.00,
      picture: $r('app.media.back14'),
      inventory: 120,
      id: 'c'
    },
    {
      description: '【10米送装一体】直达守护者7kw刷卡版',
      price: 1499.00,
      picture: $r('app.media.back12'),
      inventory: 120,
      id: 'd'
    },
    {
      description: '【20米送装一体】直达守护者7kw刷卡版',
      price: 1899.00,
      picture: $r('app.media.back11'),
      inventory: 50,
      id: 'e'
    },
    {
      description: '【30米送装一体】直达守护者7kw刷卡版',
      price: 2199.00,
      picture: $r('app.media.back13'),
      inventory: 50,
      id: 'f'
    },
    {
      description: '直达充电庄立柱',
      price: 299.00,
      picture: $r('app.media.back14'),
      inventory: 50,
      id: 'g'
    },
    {
      description: '彩虹小华盲盒',
      price: 276.00,
      picture: $r('app.media.back14'),
      inventory: 49,
      id: 'h'
    },
    {
      description: '冰丝polo衫',
      price: 86.00,
      picture: $r('app.media.back11'),
      inventory: 346,
      id: 'i'
    },
    {
      description: 'LIBRATONE AIR Color 真无线入耳式耳机',
      price: 707.00,
      picture: $r('app.media.back12'),
      inventory: 50,
      id: 'j'
    },
    {
      description: 'LIBRATONE AIR+ (第3代) 真无线入耳式降噪耳机',
      price: 1227.00,
      picture: $r('app.media.back13'),
      inventory: 50,
      id: 'k'
    },
    {
      description: 'LIBRATONE TRACK+ (第2代) 颈挂式无线降噪耳机',
      price: 857.00,
      picture: $r('app.media.ic_launcher_background_1'),
      inventory: 50,
      id: 'l'
    },
    {
      description: 'LIBRATONE TRACK第2代入耳式无线耳机',
      price: 558.00,
      picture: $r('app.media.ic_launcher_background_2'),
      inventory: 50,
      id: 'm'
    },
    {
      description: '无线洗车机',
      price: 284.00,
      picture: $r('app.media.ic_launcher_background_3'),
      inventory: 187,
      id: 'n'
    },
    {
      description: '户外折叠椅',
      price: 236.00,
      picture: $r('app.media.back2'),
      inventory: 143,
      id: 'o'
    }
  ];
  private readonly swiperList: CommodityData[] = [
    {
      description: '剃须刀',
      price: 569.00,
      picture: $r('app.media.back12'),
      inventory: 10,
      id: 'p'
    },
    {
      description: '挂颈式耳机',
      price: 1799.00,
      picture: $r('app.media.back12'),
      inventory: 16,
      id: 'q'
    }
  ]
  private static instance: CommodityModel;

  public static getCommodityModel(): CommodityModel {
    if (!CommodityModel.instance) {
      CommodityModel.instance = new CommodityModel();
    }
    return CommodityModel.instance;
  }

  getAllList(): CommodityData[] {
    return this.commodityList;
  }

  getSwiperList(): CommodityData[] {
    return this.swiperList;
  }

  getCommodityDetail(id: string): CommodityData {
    return [...this.commodityList, ...this.swiperList].filter((item: CommodityData) => item.id === id)[0];
  }
}
