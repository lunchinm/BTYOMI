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

import { ServiceConstants } from '../constants/ServiceConstants';
import { Nav, NavInfo, NavItem, ShopItem, ShopInfo, shop, CommonConstants } from '@ohos/common';

@Component
export struct MyCharge {
  shopList: ShopInfo[] = shop.getShopList();
  navSList: NavInfo[] = Nav.getSecondNavList();
  @StorageProp('avoidArea') topHeight: number = 39;
  swiperList: Resource[] = [$r('app.media.back1'), $r('app.media.back2')];
  // swiper高度
  @State swiperHeight: number = ServiceConstants.SWIPER_HEIGHT;
  @Consume('pageInfos') pageInfos: NavPathStack;

  @Builder
  navBuilder() {
    Column({ space: ServiceConstants.PUBLIC_SPACE }) {
      List() {
        ForEach(this.navSList, (item: NavInfo) => {
          ListItem() {
            NavItem({ itemData: item });
          };
        }, (item: NavInfo) => item.id);
      }
      .borderRadius(CommonConstants.BORDER_RADIUS)
      .clip(true);
    }
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.COLUMN_WIDTH)
    .backgroundColor(Color.White)
    .padding({
      left: CommonConstants.MAIN_PADDING,
      right: CommonConstants.MAIN_PADDING
    })
    .borderRadius(CommonConstants.BORDER_RADIUS);
  }

  build() {
    NavDestination() {
      Column({ space: CommonConstants.PUBLIC_SPACE * 2 }) {
        Row() {
          Image($r('app.media.back')).width(ServiceConstants.PIC_WIDTH).height(ServiceConstants.PIC_HEIGHT)
            .onClick(() => {
              this.pageInfos.pop();
            });
          Text('我的充电').fontWeight(ServiceConstants.FONT_WEIGHT).margin({ left: '20vp' });
        }
        .width(CommonConstants.COLUMN_WIDTH);

        Swiper() {
          ForEach(this.swiperList, (item: Resource) => {
            Image(item).width(CommonConstants.COLUMN_WIDTH).height(CommonConstants.COLUMN_HEIGHT);
          });
        }
        .indicator( // 设置圆点导航点样式
          new DotIndicator()
            .color(Color.Grey)
            .selectedColor(Color.White))
        .width(CommonConstants.COLUMN_WIDTH)
        .height(200)
        .borderRadius(CommonConstants.BORDER_RADIUS);

        Column({ space: ServiceConstants.PUBLIC_SPACE * 2 }) {
          Flex({ justifyContent: FlexAlign.SpaceAround }) {
            ForEach(this.shopList, (item: ShopInfo) => {
              ShopItem({ itemData: item });
            });
          }
          .width(CommonConstants.COLUMN_WIDTH);

          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Row({ space: CommonConstants.PUBLIC_SPACE }) {
              Image($r('app.media.ic_product_normal'))
                .width(ServiceConstants.PIC_WIDTH)
                .height(ServiceConstants.PIC_HEIGHT);
              Text('充电订单')
                .fontWeight(400)
                .fontSize(14);
            }
            .rowStyle();

            Row({ space: CommonConstants.PUBLIC_SPACE }) {
              Image($r('app.media.ic_product_normal'))
                .width(ServiceConstants.PIC_WIDTH)
                .height(ServiceConstants.PIC_HEIGHT);
              Text('占位订单')
                .fontWeight(400)
                .fontSize(14);
            }
            .rowStyle();
          }
          .height('60vp');

          this.navBuilder();
        };
      }
      .padding({
        top: CommonConstants.MAIN_PADDING + this.topHeight,
        left: CommonConstants.MAIN_PADDING,
        right: CommonConstants.MAIN_PADDING,
        bottom: CommonConstants.MAIN_PADDING
      })
      .height(CommonConstants.COLUMN_HEIGHT)
      .backgroundColor('#EFEFEF');
    }
    .hideTitleBar(true);
  }
}

@Extend(Row)
function rowStyle() {
  .backgroundColor(Color.White)
  .width('49%')
  .height(CommonConstants.COLUMN_HEIGHT)
  .borderRadius(CommonConstants.BORDER_RADIUS)
  .padding({ left: CommonConstants.PUBLIC_SPACE });
}
