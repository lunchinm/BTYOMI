# 汽车类行业实践

## 介绍

本设计为汽车类HarmonyOS应用的架构设计实践，应用设备形态只有手机端，提供汽车类应用常见的汽车类资讯，购车，商城以及充电服务等应用功能。

* Stage开发模型+声明式UI开发方式。
* 按照应用设备形态，规划一个手机设备Entry类型HAP包。
* 本实践性能优先，应用程序包大小可控，且无单独加载模块场景，业务模块包类型采用HAR包。

## 效果预览

![](screenshots/preview.gif)

## 约束与限制

软件要求

* DevEco Studio版本：DevEco Studio 6.0.0 Release及以上。
* HarmonyOS SDK版本：HarmonyOS 6.0.0 Release SDK及以上。

硬件要求

* 设备类型：华为手机。
* HarmonyOS系统：HarmonyOS 6.0.0 Release及以上。

环境搭建

* 安装DevEco Studio，详情请参考[工具概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-tools-overview)。

## 使用说明

* 框架代码中登录验证，只是UI能力，手机号输入满11位，任意密码可登录，开发者自行补齐相关鉴权认证

* 申请ohos.permission.LOCATION和ohos.permission.APPROXIMATELY_LOCATION权限，您需要在module.json5配置文件中声明所需要的权限。

```
"requestPermissions": [
      {
        "name": "ohos.permission.LOCATION",
        "reason": "$string:EntryAbility_desc",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when": "always"
        }
      },
      {
        "name": "ohos.permission.APPROXIMATELY_LOCATION",
        "reason": "$string:EntryAbility_desc",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when": "always"
        }
      }
    ]
```

## 实现思路

### 扫码充电功能设计：

汽车类行业的基础功能，应用充电服务，提供最优站点列表以及路径规划。

使用[Scan Kit（统一扫码服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scan-kit-guide)实现扫码能力。
本示例采用默认的扫码能力，调用[默认界面扫码](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scan-scanbarcode)接口能力，具备相机预授权，集成简单，适用于通用扫码场景。

```
// features\service\src\main\ets\pages\ServicePage.ets 
Row() {
  ForEach(this.mapShopList, (item: shopInfo, index: number) => {
    Row() {
      ShopItem({ itemData: item })
    }.onClick(() => {
      if (item.title === '扫码充电') {
        // 定义扫码参数options
        let options: scanBarcode.ScanOptions = {
          scanTypes: [scanCore.ScanType.ALL], // 设置扫码类型，默认扫码ALL（全部码类型）
          enableMultiMode: true, // 是否开启多码识别，默认false。
          enableAlbum: true // 是否开启相册，默认true,  此参数只控制默认界面扫码能力中的相册扫码且只支持单码识别。
        };
        try {
          scanBarcode.startScanForResult(getContext(this), options).then((result: scanBarcode.ScanResult) => {
            // 收到扫码结果后返回
            Logger.info('Promise scan result: %{public}s', JSON.stringify(result));
            // 处理扫码结果
            this.showScanResult(result);
          }).catch((error: BusinessError) => {
            Logger.error('Promise error: %{public}s', JSON.stringify(error));
          });
        } catch (error) {
          Logger.error('failReason: %{public}s', JSON.stringify(error));
        }
      }
      if (item.title === '最优站点') {
        this.pageInfos.pushPath({ name: 'OptimalStation' });
      } else if (item.title === '我的充电') {
        this.pageInfos.pushPath({ name: 'MyCharge' });
      }
    })

    if (index !== this.mapShopList.length - 1) {
      Line().LineStyle();
    }
  })
}
.width(CommonConstants.COLUMN_WIDTH)
.justifyContent(FlexAlign.SpaceEvenly)
```

### 最优站点功能设计：

提供方最优站点列表以及路径规划

使用鸿蒙原生[Map Kit(地图服务)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-kit-guide)能力， 首先在AppGallery Connect配置使用相关API，参考指导配置[开发准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。

使用MapComponent地图组件在页面中放置地图。MapComponentController是地图组件的主要功能入口类，用来操作地图，与地图有关的所有方法从此处接入。

```
// features\service\src\main\ets\pages\OptimalStation.ets
@Entry
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
  }
  @State addressString: string = '';
  @Consume('pageInfos') pageInfos: NavPathStack;

  build() {
    NavDestination(){
      Stack({ alignContent: Alignment.Bottom }) {
        MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback }).width('100%').height('100%');
        // ...
        Row() {
          // 半模态框
          SheetTransition({
            StationList: Station.getStationList(),
            addressName: this.addressName
          })
        }.margin({ bottom: 220 })
      }
    }
    .hideTitleBar(true)
    .onReady(()=>{
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
          this.mapController.on("mapLoad", () => {
          });
          // 监听“我的位置”按钮点击事件
          this.mapController.on("myLocationButtonClick", () => {
            this.getMyLocation();
          });
          // 初始化我的位置
          this.getMyLocation();
        }
      };
    })
  }
}
```

## 工程目录

```
├── common/src/main/ets  // 公共模块 
│   ├── compontents
│   │   ├── NavItem.ets        // nav组件
│   │   ├── PageHeaderComp.ets // 二级页面头部组件
│   │   └── ShopItem.ets       // shop组件
│   ├── constants
│   │   ├── CommonConstants.ets  // 公共样式
│   │   ├── NavConstants.ets     // nav样式
│   │   └── TabConstants.ets     // tab样式
│   ├── model
│   │   ├── BuyingCarModel.ets  // 购车数据模型
│   │   ├── CommodityModel.ets  // 商城数据模型
│   │   ├── ExploreModel.ets    // 探索数据模型
│   │   ├── LazyDataSource.ets  // 懒加载数据
│   │   ├── NavModel.ets        // nav数据模型
│   │   └── ShopModel.ets       // shop数据模型
│   ├── utils
│   │   ├── LoggerUtil.ets       // 日志工具类
│   │   ├── PermissionsUtil.ets  // 权限管理工具类
│   │   └── PreferencesUtil.ets  // 数据存储工具类
├── entry/src/main/ets  // 主页面
│   ├── constants
│   │   └── TabConstants.ets       // tab样式
│   ├── pages
│   │   ├── LoginPage.ets          // 登录页
│   │   ├── NavigationPage.ets     // Navigation根页面
│   │   ├── PrivacyPolicyPage.ets  // 隐私政策页面
│   │   ├── SplashScreenPage.ets   // 闪屏页
│   │   └── TabPage.ets            // tab页
│   ├── entryability
│   │   └── EntryAbility.ets       // 程序入口
├── features
│   ├── buyingcar/src/main/ets  // 购车
│   │   ├── compontents 
│   │   │   ├── LearnMoreItemComp.ets       // 了解更多item组件
│   │   │   ├── MarqueeImageComp.ets        // 走马灯图片
│   │   │   └── VehicleModelActivities.ets  // 车型item组件
│   │   └── pages 
│   │       ├── BuyingCarDetailPage.ets     // 购车详情页
│   │       └── BuyingCarPage.ets           // 购车tab页
│   ├── explore/src/main/ets  // 探索
│   │   ├── compontents 
│   │   │   ├── ActivityComp.ets            // 活动swiper页
│   │   │   ├── ActivityItemComp.ets        // 活动item组件
│   │   │   └── RecommendationComp.ets      // 推荐swiper页
│   │   ├── constants 
│   │   │   └── RecommendationConstants.ets // 推荐页样式
│   │   └── pages 
│   │       └── ExplorePage.ets             // 探索tab页
│   ├── mine/src/main/ets  // 我的
│   │   ├── compontents 
│   │   │   └── MajorList.ets        // 单个组件
│   │   ├── constants 
│   │   │   ├── HeaderConstants.ets  // 头部样式
│   │   │   └── MajorConstants.ets   // major样式
│   │   ├── model
│   │   │   └── MajorModel.ets       // major模型
│   │   └── pages 
│   │       ├── MinePage.ets         // 我的tab页
│   │       └── SettingsPage.ets     // 设置页面
│   ├── service/src/main/ets  // 服务
│   │   ├── compontents 
│   │   │   └── SheetTransition.ets  // sheet模态框
│   │   ├── constants 
│   │   │   └── ServiceConstants.ets // 服务样式
│   │   ├── model
│   │   │   └── StationModel.ets     // station模型
│   │   └── pages 
│   │       ├── MyCharge.ets         // 我的充电页
│   │       ├── OptimalStation.ets   // 最优站点页
│   │       └── ServicePage.ets      // 服务tab页
│   └── shoppingMall/src/main/ets  // 商城
│       ├── compontents 
│       │   └── CommodityItemComp.ets      // 商城列表item组件
│       ├── constants 
│       │   └── ShoppingMallConstants.ets  // 商城样式
│       └── pages 
│           ├── CommodityDetailPage.ets    // 商城详情
│           └── ShoppingMallPage.ets       // 商城tab页
└──entry/src/main/resources  // 资源文件目录
```

## 参考文档

[分层模块化实践](https://developer.huawei.com/consumer/cn/doc/architecture-guides/practice-common-app-layered-v1-0000001916033058)

[Scan Kit（统一扫码服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scan-kit-guide)

[Map Kit（地图服务）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-kit-guide)