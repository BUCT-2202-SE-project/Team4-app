import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import hilog from '@ohos.hilog';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';

// 定义错误类型
interface LoadError {
  code: number;
  message?: string;
}

// 定义数据类型 - 避免使用索引签名
interface ContentData {
  // 定义具体的属性，而不是使用索引签名
  result: string;
  status: string;
  // 可以根据需要添加更多确定的属性
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'museumApp', '%{public}s', 'Ability onCreate');
  }

  onDestroy() {
    hilog.info(0x0000, 'museumApp', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(0x0000, 'museumApp', '%{public}s', 'Ability onWindowStageCreate');

    // 更改为加载LoginPage作为初始页面
    windowStage.loadContent('pages/LoginPage', (err, data) => {
      if (err) {
        hilog.error(0x0000, 'museumApp', 'Failed to load content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'museumApp', 'Succeeded in loading content.');
    });
  }

  onWindowStageDestroy() {
    hilog.info(0x0000, 'museumApp', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(0x0000, 'museumApp', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    hilog.info(0x0000, 'museumApp', '%{public}s', 'Ability onBackground');
  }
}