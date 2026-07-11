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

import { NavItem, CommonConstants, shop, ShopItem, ShopInfo, Nav, NavInfo } from '@ohos/common';
import { MajorList } from '../components/MajorList';
import { HeaderConstants } from '../constants/HeaderConstants';
import { Major, majorInfo } from '../model/MajorModel';

// ============================================
// 【预览组件说明】
// 使用说明：如果MinePage页面中添加了@Consume装饰器
// 1. 如果原页面已有 @Entry 装饰器，保留它，删除此预览组件
// 2. 如果原页面没有 @Entry 装饰器，添加 @Entry 成为预览组件
// 3. 如果原页面有 @Consume('pageInfos')，必须使用此预览组件方式
//
// 复制以下代码到对应的 .ets 文件开头部分即可
// ============================================
@Entry
struct MinePagePreview {
  // 【必须】提供 @Consume 所需的上下文数据
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  build() {
    Column() {
      MinePage();
    }
    .width('100%')
    .height('100%');
  }
}

@Component
export struct MinePage {
  navSList: NavInfo[] = Nav.getNavList();
  majorList: majorInfo[] = Major.getMajorList();
  shopList: ShopInfo[] = shop.getMineShopList();
  @StorageProp('avoidArea') topHeight: number = 0;
  @Consume('pageInfos') pageInfos: NavPathStack;

  @Builder
  header() {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Text('我的')
        .fontSize(CommonConstants.MAX_FONT_SIZE)
        .fontWeight(FontWeight.Bold);
      Row() {
        Image($r('app.media.mine_settings'))
          .width(20)
          .height(20)
          .fillColor(Color.Black)
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'SettingsPage' });
          });
      }
      .width(40)
      .height(40)
      .borderRadius(50)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
      .justifyContent(FlexAlign.Center);
    }
    .padding({
      top: CommonConstants.MAIN_PADDING,
      right: CommonConstants.L_MAIN_PADDING,
      left: CommonConstants.L_MAIN_PADDING,
      bottom: CommonConstants.MAIN_PADDING,
    })
    .width(CommonConstants.COLUMN_WIDTH);
  }

  @Builder
  navBuilder() {
    Column({ space: CommonConstants.PUBLIC_SPACE }) {
      List() {
        ForEach(this.navSList, (item: NavInfo) => {
          ListItem() {
            NavItem({ itemData: item });
          };
        }, (item: NavInfo) => item.id);
      }
      .divider({
        strokeWidth: 1,
        color: 'rgba(0, 0, 0, 0.05)',
        startMargin: CommonConstants.PUBLIC_SPACE * 3
      })
      .borderRadius(CommonConstants.BORDER_RADIUS)
      .clip(true);
    }
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.COLUMN_WIDTH);
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      this.header();
      List({ space: CommonConstants.PUBLIC_SPACE }) {
        ListItem() {
          Column() {
            Row({ space: CommonConstants.MAIN_MARGIN * 2 }) {
              Image($r('app.media.avatar'))
                .width(HeaderConstants.PIC_HEIGHT)
                .height(HeaderConstants.PIC_WIDTH);
              Text(`车主`)
                .fontWeight(FontWeight.Bold)
                .fontSize(18);
            }
            .width(CommonConstants.COLUMN_WIDTH)
            .height(64)
            .padding(CommonConstants.MAIN_PADDING);

            MajorList({ majorList: this.majorList })
              .margin({
                bottom: CommonConstants.MAIN_MARGIN * 2
              });
          }
          .borderRadius(16)
          .backgroundColor('#FFF')
          .margin({
            top: CommonConstants.MAIN_MARGIN,
            bottom: CommonConstants.PUBLIC_SPACE
          });
        };

        ListItem() {
          Column({ space: CommonConstants.MAIN_MARGIN }) {
            Text('轿车购物')
              .fontSize(18)
              .fontWeight(CommonConstants.BOLD_TEXT_WEIGHT);
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.shopList, (item: ShopInfo) => {
                ShopItem({ itemData: item });
              });
            }
            .borderRadius(16)
            .backgroundColor('#fff')
            .width(CommonConstants.COLUMN_WIDTH)
            .height(76)
            .padding({
              left: CommonConstants.MAIN_PADDING,
              right: CommonConstants.MAIN_PADDING,
              top: CommonConstants.L_MAIN_PADDING,
              bottom: CommonConstants.L_MAIN_PADDING,
            });
          }.alignItems(HorizontalAlign.Start);
        };

        ListItem() {
          this.navBuilder();
        }
        .padding({
          left: CommonConstants.M_PUBLIC_SPACE,
          right: CommonConstants.M_PUBLIC_SPACE,
        })
        .backgroundColor('#fff')
        .borderRadius(16);
      }
      .height(CommonConstants.COLUMN_HEIGHT)
      .scrollBar(BarState.Off)
      .padding({
        left: CommonConstants.L_MAIN_PADDING,
        right: CommonConstants.L_MAIN_PADDING
      });
    }
    .padding({ top: this.topHeight })
    .width(CommonConstants.COLUMN_WIDTH)
    .height(CommonConstants.COLUMN_HEIGHT)
    .backgroundColor('#E5EEEE');
  }
}
