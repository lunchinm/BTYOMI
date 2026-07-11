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

export class LearnMoreModelInfo {
  image: ResourceStr
  title: string
  description: string

  constructor(image: ResourceStr, title: string, description: string) {
    this.image = image;
    this.title = title;
    this.description = description;
  }
}

export class VehicleModelActivitiesInfo {
  image: ResourceStr
  title: string

  constructor(image: ResourceStr, title: string) {
    this.image = image;
    this.title = title;
  }
}

class IconModelModel {
  getMainList(): VehicleModelActivitiesInfo[] {
    return [
      new VehicleModelActivitiesInfo($r('app.media.icon4'), '销量排行'),
      new VehicleModelActivitiesInfo($r('app.media.icon3'), '热度排行'),
      new VehicleModelActivitiesInfo($r('app.media.icon5'), '新车上市'),
      new VehicleModelActivitiesInfo($r('app.media.icon1'), '保值榜'),
      new VehicleModelActivitiesInfo($r('app.media.icon2'), '查裸车价')
    ];
  }
}

export const iconModel = new IconModelModel();


export interface DetailIconData {
  image: ResourceStr
  title: string
}

export class DetailIconModel {
  private readonly detailIconList: DetailIconData[] = [
    {
      image: $r('app.media.ic_detail1'),
      title: '3D'
    },
    {
      image: $r('app.media.ic_detail2'),
      title: '图片'
    },
    {
      image: $r('app.media.ic_detail3'),
      title: '内饰'
    },
    {
      image: $r('app.media.ic_detail4'),
      title: '第一视角'
    },
    {
      image: $r('app.media.ic_detail5'),
      title: '选装'
    }
  ];
  private static instance: DetailIconModel;

  public static getDetailIconModel(): DetailIconModel {
    if (!DetailIconModel.instance) {
      DetailIconModel.instance = new DetailIconModel();
    }
    return DetailIconModel.instance
  }

  getDetailIcon(): DetailIconData[] {
    return this.detailIconList
  }
}