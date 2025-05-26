/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

/**
 * Common constants for all features.
 */
export default class CommonConstants {
  /**
   * The main ability tag.
   */
  static readonly TAG_ABILITY: string = 'EntryAbility';

  static readonly TAG_COMMON_UTILS: string = 'CommonUtils';

  static readonly TAG_LIST_ITEM: string = 'ListItem';

  static readonly TOAST_DURATION: number = 3000;
  static readonly HOME_TAB_INDEX: number = 0;

  static readonly COLLECTION_TAB_INDEX: number = 1;

  static readonly MINE_TAB_INDEX: number = 2;

  static readonly SWIPER_CACHE_COUNT: number = 3;

  /**
   * Break point sm of the tag.
   */
  static readonly SM: string = 'sm';

  /**
   * Break point md of the tag.
   */
  static readonly MD: string = 'md';

  /**
   * Break point lg of the tag.
   */
  static readonly LG: string = 'lg';

  /**
   * Width condition sm filter.
   */
  static readonly WIDTH_CONDITION_SM: string = '(320vp<=width<520vp)';

  /**
   * Width condition md filter.
   */
  static readonly WIDTH_CONDITION_MD: string = '(520vp<=width<840vp)';

  /**
   * Width condition lg filter.
   */
  static readonly WIDTH_CONDITION_LG: string = '(840vp<=width)';

  /**
   * Login page button id.
   */
  static readonly LOGIN_BUTTON_ID: string = 'loginButtonId';

  /**
   * Tablet device type.
   */
  static readonly TABLET_DEVICE_TYPE: string = 'tablet';
}
