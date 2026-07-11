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

import { CommonConstants, Logger, permissionsUtil, shop, ShopInfo, ShopItem } from '@ohos/common';
import { map, mapCommon, MapComponent } from '@kit.MapKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { Permissions } from '@kit.AbilityKit';

// ============================================
// 【预览组件说明】
// 使用说明：如果ServicePage页面中添加了@Consume装饰器
// 1. 如果原页面已有 @Entry 装饰器，保留它，删除此预览组件
// 2. 如果原页面没有 @Entry 装饰器，添加 @Entry 成为预览组件
// 3. 如果原页面有 @Consume('pageInfos')，必须使用此预览组件方式
//
// 复制以下代码到对应的 .ets 文件开头部分即可
// ============================================
@Entry
struct ServicePagePreview {
  // 【必须】提供 @Consume 所需的上下文数据
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  build() {
    Column() {
      ServicePage();
    }
    .width('100%')
    .height('100%');
  }
}

@Component
export struct ServicePage {
  @StorageProp('avoidArea') topHeight: number = 0;
  private mapOption?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  // 地图初始化经纬度，可自定义。
  private latLng: mapCommon.LatLng = {
    latitude: 31.97413747571286,
    longitude: 118.77314161376894
  };
  private zoom: number = 14;
  @Consume('pageInfos') pageInfos: NavPathStack;
  mapShopList: ShopInfo[] = shop.getMapShopList();
  private permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
  uiContext: UIContext = this.getUIContext();

  aboutToAppear(): void {
    permissionsUtil.checkPermissions(this.permissions, this.getUIContext());
    // 地图初始化参数，设置地图中心点坐标及层级
    this.mapOption = {
      position: {
        target: this.latLng,
        zoom: this.zoom
      },
      // 是否支持滑动手势，默认值为true
      scrollGesturesEnabled: false,
      // 是否展示缩放控件，默认值为true
      zoomControlsEnabled: false,
      // 是否展示定位按钮，默认值为false
      myLocationControlsEnabled: false,
      // 是否展示指南针控件，默认值为true
      compassControlsEnabled: false,
      // 是否展示比例尺，默认值为false
      scaleControlsEnabled: true
    };
    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图
        this.mapController = mapController;
        // 启用我的位置图层
        this.mapController?.setMyLocationEnabled(true);
        // 隐藏我的位置按钮
        this.mapController?.setMyLocationControlsEnabled(false);
        this.mapController.on('mapLoad', () => {
        });
        this.mapController.on('mapClick', () => {
          this.pageInfos.pushPath({ name: 'OptimalStation' });
        });

        // 初始化我的位置
        this.getMyLocation();
      }
    };
  }

  // 获取当前位置并视图移动过去
  getMyLocation() {
    geoLocationManager.getCurrentLocation().then(async (result) => {
      let position: geoLocationManager.Location = {
        'latitude': result.latitude,
        'longitude': result.longitude,
        'altitude': 0,
        'accuracy': 0,
        'speed': 0,
        'timeStamp': 0,
        'direction': 0,
        'timeSinceBoot': 0,
        altitudeAccuracy: 0,
        speedAccuracy: 0,
        directionAccuracy: 0,
        uncertaintyOfTimeSinceBoot: 0,
        sourceType: geoLocationManager.LocationSourceType.GNSS
      };
      this.mapController?.setMyLocation(position);
      // 创建CameraUpdate对象
      let gcj02Posion: mapCommon.LatLng = await this.convertCoordinate(result.latitude, result.longitude);
      let latLng: mapCommon.LatLng = {
        latitude: gcj02Posion.latitude,
        longitude: gcj02Posion.longitude
      };
      let cameraUpdate = map.newLatLng(latLng, this.zoom);
      // 以非动画方式移动地图相机
      this.mapController?.moveCamera(cameraUpdate);
      // 以动画方式移动地图相机
    });
  }

  async convertCoordinate(latitude: number, longitude: number): Promise<mapCommon.LatLng> {
    let wgs84Position: mapCommon.LatLng = {
      latitude: latitude,
      longitude: longitude
    };
    let gcj02Posion: mapCommon.LatLng =
      await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);

    return gcj02Posion;
  }

  async showScanResult(result: scanBarcode.ScanResult) {
    if (result) {
      // 使用toast显示出扫码结果
      try {
        this.uiContext.getPromptAction().showToast({
          message: JSON.stringify(result),
          duration: 5000
        });
      } catch (error) {
        Logger.error('showToast error: %{public}s ', JSON.stringify(error));
      }
    }
  }

  build() {
    Scroll() {
      Column({ space: CommonConstants.PUBLIC_SPACE }) {
        Row() {
          Text('服务')
            .fontSize(CommonConstants.MAX_FONT_SIZE)
            .fontWeight(FontWeight.Bold)
            .margin({
              top: CommonConstants.MAIN_MARGIN * 3 / 2,
              left: CommonConstants.M_MAIN_MARGIN * 2
            });
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .height('35%')
        .alignItems(VerticalAlign.Top);

        GridRow({
          columns: 3,
          gutter: 12
        }) {
          GridCol() {
            Row({ space: CommonConstants.S_PUBLIC_SPACE }) {
              Image($r('app.media.grid1'))
                .width(CommonConstants.PIC_WIDTH)
                .height(CommonConstants.PIC_HEIGHT);
              Text('电表申请').fontSize(CommonConstants.S_FONT_SIZE);
            }
            .rowStyle();
          };

          GridCol() {
            Row({ space: CommonConstants.S_PUBLIC_SPACE }) {
              Image($r('app.media.grid2'))
                .width(CommonConstants.PIC_WIDTH)
                .height(CommonConstants.PIC_HEIGHT);
              Text('备件查询').fontSize(CommonConstants.S_FONT_SIZE);
            }
            .rowStyle();
          };

          GridCol() {
            Row({ space: CommonConstants.S_PUBLIC_SPACE }) {
              Image($r('app.media.grid3'))
                .width(CommonConstants.PIC_WIDTH)
                .height(CommonConstants.PIC_HEIGHT);
              Text('金融计算器').fontSize(CommonConstants.S_FONT_SIZE);
            }
            .rowStyle();
          };
        }
        .margin({
          left: CommonConstants.MAIN_MARGIN * 2,
          right: CommonConstants.MAIN_MARGIN * 2
        });

        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.SpaceEvenly,
          alignItems: ItemAlign.Auto
        }) {
          Row() {
            Text('充电服务').fontSize(CommonConstants.M_FONT_SIZE)
              .fontWeight(CommonConstants.REGULAR_TEXT_WEIGHT);
          }.margin({ bottom: CommonConstants.MAIN_PADDING });

          // 添加地图组件
          Stack() {
            // 调用MapComponent组件初始化地图
            MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
              .width(CommonConstants.COLUMN_WIDTH)
              .height(CommonConstants.COLUMN_WIDTH);
          }.height('250vp').margin({ bottom: CommonConstants.MAIN_PADDING });

          Row() {
            ForEach(this.mapShopList, (item: ShopInfo, index: number) => {
              Row() {
                ShopItem({ itemData: item });
              }.onClick(() => {
                if (item.title === '扫码充电') {
                  // 定义扫码参数options
                  let options: scanBarcode.ScanOptions = {
                    scanTypes: [scanCore.ScanType.ALL], // 设置扫码类型，默认扫码ALL（全部码类型）
                    enableMultiMode: true, // 是否开启多码识别，默认false。
                    enableAlbum: true // 是否开启相册，默认true,  此参数只控制默认界面扫码能力中的相册扫码且只支持单码识别。
                  };
                  try {
                    scanBarcode.startScanForResult(this.getUIContext().getHostContext(), options)
                      .then((result: scanBarcode.ScanResult) => {
                        // 收到扫码结果后返回
                        Logger.info(`Promise scan result:${JSON.stringify(result)}`);
                        // 处理扫码结果
                        this.showScanResult(result);
                      })
                      .catch((error: BusinessError) => {
                        Logger.error(`Promise error: ${JSON.stringify(error)}`);
                      });
                  } catch (error) {
                    Logger.error(`failReason: ${JSON.stringify(error)}`);
                  }
                }
                if (item.title === '最优站点') {
                  this.pageInfos.pushPath({ name: 'OptimalStation' });
                } else if (item.title === '我的充电') {
                  this.pageInfos.pushPath({ name: 'MyCharge' });
                }
              });

              if (index !== this.mapShopList.length - 1) {
                Line().lineStyle();
              }
            });
          }
          .width(CommonConstants.COLUMN_WIDTH)
          .justifyContent(FlexAlign.SpaceEvenly);
        }
        .layoutWeight(1);

      }
      .height(CommonConstants.COLUMN_HEIGHT);
    }
    .height(CommonConstants.COLUMN_HEIGHT)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Fade)
    .backgroundImage($r('app.media.service_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .padding({
      top: this.topHeight,
      bottom: CommonConstants.MAIN_PADDING,
    });
  }
}

@Extend(Row)
function rowStyle() {
  .width(CommonConstants.COLUMN_WIDTH)
  .height(48)
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Center)
  .borderRadius(8)
  .backgroundColor(Color.White);
}

@Extend(Line)
function lineStyle() {
  .height(24)
  .width(0.5)
  .backgroundColor($r('app.color.main_color'));
}
