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

import hilog from '@ohos.hilog';

class LoggerUtil {
  private domain: number;
  private prefix: string;
  private format: string = '%{public}s';

  /**
   * constructor.
   *
   * @param Prefix identifies the log tag.
   * @param domain Domain Indicates the service domain, which is a hexadecimal integer ranging from 0x0 to 0xFFFFF.
   */
  constructor(domain: number = 0xFF00, prefix: string = 'MyApp') {
    this.prefix = prefix;
    this.domain = domain;
  }

  debug(...args: string[]): void {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

  info(format: string = this.format, ...args: string[]): void {
    hilog.info(this.domain, this.prefix, format, args);
  }

  warn(...args: string[]): void {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  error(format: string = this.format, ...args: string[]): void {
    hilog.error(this.domain, this.prefix, format, args);
  }
}

export const Logger = new LoggerUtil(0xFF00, 'MyApp');