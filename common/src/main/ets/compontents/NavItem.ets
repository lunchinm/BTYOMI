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

import { NavInfo } from '../model/NavModel';
import { NavConstants } from '../constants/NavConstants';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct NavItem {
  @Prop itemData: NavInfo;
  @State curFile: string = '';

  @Builder customBuilder() {}
  // 使用父组件@Builder装饰的方法初始化子组件@BuilderParam
  @BuilderParam customBuilderParam: () => void = this.customBuilder;

  build() {
    Row({ space:10 }){
      Row({ space:17 }){
        if(this.itemData.icon) {
          Image(this.itemData.icon)
            .width(NavConstants.F_PIC_WIDTH)
            .height(NavConstants.F_PIC_HEIGHT)
        }
        Text(this.itemData.title)
          .fontWeight(500)
          .fontSize(14)
      }
      Blank()
      this.customBuilderParam()
      Image(this.itemData.action)
        .width(NavConstants.S_PIC_WIDTH)
        .height(NavConstants.S_PIC_HEIGHT)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({top:NavConstants.PADDING,bottom:NavConstants.PADDING})
    .width(CommonConstants.COLUMN_WIDTH)
    .onClick(()=>{
      this.itemData.clickAction()
    })
  }
}
