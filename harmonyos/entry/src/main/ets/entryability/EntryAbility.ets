import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { window } from '@kit.ArkUI'
import { StorageManager } from '../services/storage/StorageManager'
import { HttpClient } from '../services/HttpClient'
import { FundApi } from '../services/api/FundApi';

// 全局变量，供其他页面读取从 widget/快捷方式传入的基金代码
let launchFundCode: string | null = null
export function getLaunchFundCode(): string | null {
  const code = launchFundCode
  launchFundCode = null
  return code
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', 'Ability onCreate')
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', 'Ability onDestroy')
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    await StorageManager.getInstance().init(this.context)
    await HttpClient.initBaseUrl()

    // 读取从桌面卡片/快捷方式传入的基金代码
    const fundCode = this.launchWant?.parameters?.fundCode as string
    if (fundCode != null && fundCode !== '') {
      launchFundCode = fundCode
      console.info('EntryAbility: 从元服务启动，基金代码=' + fundCode)
      // 预查询基金ID并存到全局状态
    }
    hilog.info(0x0000, 'testTag', 'Ability onWindowStageCreate, baseUrl=' + HttpClient.getBaseUrl())

    windowStage.loadContent('pages/SplashPage', (err: BusinessError) => {
      if (err.code != null && err.code !== 0) {
        hilog.error(0x0000, 'testTag', 'Failed to load content')
        return
      }
      windowStage.getMainWindow().then((win: window.Window) => {
        win.setWindowLayoutFullScreen(true)
      }).catch(() => {
        hilog.error(0x0000, 'testTag', 'Set fullscreen failed')
      })
    })
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'testTag', 'Ability onWindowStageDestroy')
  }

  onForeground(): void {
    hilog.info(0x0000, 'testTag', 'Ability onForeground')
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', 'Ability onBackground')
  }
}
