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

export class StationInfo {
  name: string;
  distance: number;
  tag: string[];
  direct: string;
  alternating: string;
  price: number;

  constructor(name: string, distance: number, tag: string[], direct: string, alternating: string, price: number) {
    this.name = name;
    this.distance = distance;
    this.tag = tag;
    this.direct = direct;
    this.alternating = alternating;
    this.price = price;
  }
}

class StationModel {
  getStationList(): StationInfo[] {
    const stnList = [
      new StationInfo('软件谷万博科技园地库一层充电站', 0.23, ['星星充电', '高压', '即插即充'], '18/20', '-/-', 1.15),
      new StationInfo('阅城国际商业街充电站', 1.08, ['小桔', '高压', '即插即充'], '7/10', '-/-', 1.41),
      new StationInfo('特来电南京花神庙充电站', 1.10, ['特来电', '高压', '停车优惠'], '5/10', '-/-', 1.14),
      new StationInfo('特来电南京南站石华街充电站', 1.29, ['特来电', '高压', '优质'], '19/20', '-/-', 0.99),
      new StationInfo('BP快速充电站（南京邦宁科技园）', 0.89, ['小桔', '高压', '车友充过'], '6/10', '-/-', 1.13),
      new StationInfo('雨花客厅购物中心地下停车场负二层', 1.59, ['新电途', '高压', '停车优惠'], '9/24', '-/-', 1.20),
    ]
    return stnList;
  }
}

export const station = new StationModel();