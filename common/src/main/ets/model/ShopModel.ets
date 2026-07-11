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

export class ShopInfo {
  icon: ResourceStr
  title: string

  constructor(icon: ResourceStr, title: string) {
    this.icon = icon;
    this.title = title;
  }
}

export class ShopModel {
  getMineShopList(): ShopInfo[] {
    return [
      new ShopInfo($r('app.media.ic_product_card'), '我的卡券'),
      new ShopInfo($r('app.media.ic_empty'), '我的订单'),
      new ShopInfo($r('app.media.shopping_cart'), '购物车'),
      new ShopInfo($r('app.media.pin_drop'), '我的地址')
    ]
  }

  getShopList(): ShopInfo[] {
    return [
      new ShopInfo($r('app.media.ic_product_normal'), '充电地图'),
      new ShopInfo($r('app.media.ic_empty'), '即插即充'),
      new ShopInfo($r('app.media.mi_ic_home'), '我的家充桩'),
      new ShopInfo($r('app.media.ic_empty'), '充电指南')
    ]
  }

  getMapShopList(): ShopInfo[] {
    return [
      new ShopInfo($r('app.media.ic_product_normal'), '扫码充电'),
      new ShopInfo($r('app.media.mi_ic_home'), '最优站点'),
      new ShopInfo($r('app.media.ic_empty'), '我的充电')
    ]
  }
}

export const shop = new ShopModel();