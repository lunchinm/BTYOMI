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

import { map, mapCommon, MapComponent, sceneMap, site } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { station } from '../model/StationModel';
import { ServiceConstants } from '../constants/ServiceConstants';
import { SheetTransition } from '../components/SheetTransition';
import { CommonConstants } from '@ohos/common';

@Component
export struct OptimalStation {
  @StorageProp('avoidArea') topHeight: number = 0;
  private mapOption?: mapCommon.MapOptions;
  @State addressName: string = '';
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  // 地图初始化经纬度，可自定义。
  private latLng: mapCommon.LatLng = {
    latitude: 31.97413747571286,
    longitude: 118.77314161376894
  };
  @State addressString: string = '';
  @Consume('pageInfos') pageInfos: NavPathStack;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback }).width('100%').height('100%');
        Row() {
          Image($r('app.media.back'))
            .width(ServiceConstants.F_PIC_WIDTH).height(ServiceConstants.F_PIC_HEIGHT)
            .margin({ right: '10vp' })
            .onClick(() => {
              this.pageInfos.pop();
            });
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Row() {
              Image($r('app.media.ic_empty'))
                .width(ServiceConstants.F_PIC_WIDTH).height(ServiceConstants.F_PIC_HEIGHT);
              Text('【活动】周末充电返积分，立即参与').fontSize(CommonConstants.S_FONT_SIZE);
            };

            Image($r('app.media.mi_ic_right_arrow'))
              .width(ServiceConstants.S_PIC_WIDTH).height(ServiceConstants.S_PIC_HEIGHT);
          }
          .backgroundColor(Color.White)
          .width('calc(100% - 40vp)')
          .height('40vp')
          .padding({ left: '10vp', right: '10vp' })
          .borderRadius(10);
        }
        .width(CommonConstants.COLUMN_WIDTH)
        .padding({ left: '20vp', right: '20vp' })
        .position({ y: 40 })
        .borderRadius(CommonConstants.BORDER_RADIUS);

        Row() {
          // 半模态框
          SheetTransition({
            stationList: station.getStationList(),
            addressName: this.addressName
          });
        }.margin({ bottom: 220 });
      };
    }
    .hideTitleBar(true)
    .onReady(() => {
      // 地图初始化参数，设置地图中心点坐标及层级
      this.mapOption = {
        position: {
          target: this.latLng,
          zoom: 14
        },
        zoomControlsEnabled: false,
        myLocationControlsEnabled: true
      };

      // 地图初始化的回调
      this.callback = async (err, mapController) => {
        if (!err) {
          // 获取地图的控制器类，用来操作地图
          this.mapController = mapController;
          // 启用我的位置图层
          this.mapController?.setMyLocationEnabled(true);
          this.mapController.on('mapLoad', () => {
          });

          // 设置监听标记点击事件
          this.mapController.on('markerClick', (marker) => {
            this.queryLocation(marker.getTitle());
          });

          // 监听“我的位置”按钮点击事件
          this.mapController.on('myLocationButtonClick', () => {
            this.getMyLocation();
          });

          // 初始化我的位置
          this.getMyLocation();
          // this.chooseLocation(this.latLng);

        }
      };
    });
  }

  // 输入框点击事件拉起地图选点控件
  async textInputClick() {
    let params: site.SearchByTextParams = {
      query: this.addressString,
      radius: 10000,
    };
    try {
      const result = await site.searchByText(params);
      if (result && result.sites && result.sites[0]?.location) {
        this.chooseLocation(result.sites[0]?.location);
      }
    } catch (err) {
      // ...
    }
  }

  // 文本搜索能力
  async searchByText() {
    let params: site.SearchByTextParams = {
      query: this.addressString,
      radius: 10000,
    };

    try {
      const result = await site.searchByText(params);
      if (result && result.sites && result.sites[0].location) {
        this.queryLocation(result.sites[0]?.siteId);
        this.mapCameraPosition(result.sites[0].location, result.sites[0].siteId);
      }
    } catch (err) {
      // ...
    }
  }

  // 移动到坐标点并标记
  mapCameraPosition(location: mapCommon.LatLng, siteId?: string) {
    let zoom = 20;
    let cameraUpdate = map.newLatLng(location, zoom);
    // 以动画方式移动地图相机
    this.mapController?.animateCamera(cameraUpdate, 1000);
    this.addMapMaker(location, siteId);
  }

  // 地图上增加标记点
  addMapMaker(location: mapCommon.LatLng, siteId?: string) {
    this.mapController?.clear();
    let markerOptions: mapCommon.MarkerOptions = {
      position: location,
      rotation: 0,
      visible: true,
      zIndex: 0,
      alpha: 1,
      anchorU: 0.5,
      anchorV: 1,
      clickable: true,
      draggable: true,
      flat: false,
      title: siteId,
    };
    // 创建Marker
    this.mapController?.addMarker(markerOptions);
  }

  // 查询地点详情
  queryLocation(id: string) {
    let queryLocationOptions: sceneMap.LocationQueryOptions = {
      siteId: id
    };
    try {
      sceneMap.queryLocation(this.getUIContext().getHostContext() as common.UIAbilityContext, queryLocationOptions)
        .then(() => {
        })
        .catch(() => {
          // ...
        });
    } catch (e) {
      // ...
    }
  }

  // 地图选点
  chooseLocation(location: mapCommon.LatLng) {
    let locationChoosingOptions: sceneMap.LocationChoosingOptions = {
      location: location,
      searchEnabled: true,
      showNearbyPoi: true
    };
    try {
      sceneMap.chooseLocation(this.getUIContext().getHostContext() as common.UIAbilityContext, locationChoosingOptions)
        .then((data) => {
          if (data && data.siteId) {
            this.queryLocation(data.siteId);
            this.mapCameraPosition(data.location, data.siteId);
            this.addressString = data.address;
          }
        })
        .catch(() => {
          // ...
        });
    } catch (e) {
      // ...
    }
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
        sourceType: geoLocationManager.LocationSourceType.GNSS
      };

      this.mapController?.setMyLocation(position);
      // 创建CameraUpdate对象
      let gcj02Posion: mapCommon.LatLng = await this.convertCoordinate(result.latitude, result.longitude);
      let latLng: mapCommon.LatLng = {
        latitude: gcj02Posion.latitude,
        longitude: gcj02Posion.longitude
      };
      let zoom = 15;
      let cameraUpdate = map.newLatLng(latLng, zoom);
      // 以动画方式移动地图相机
      this.mapController?.animateCamera(cameraUpdate, 1000);

      // 获取当前位置的地址，填入附近推荐前面。
      let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
        'latitude': result.latitude,
        'longitude': result.longitude,
        'maxItems': 1
      };
      try {
        geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest, (err, data) => {
          if (err) {
            // ...
          } else {
            if (data && data[0] && data[0].administrativeArea && data[0].placeName) {
              this.addressName = data[0]?.placeName.split(data[0]?.administrativeArea)[1];
            }
          }
        });
      } catch (err) {
        // ...
      }
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
}