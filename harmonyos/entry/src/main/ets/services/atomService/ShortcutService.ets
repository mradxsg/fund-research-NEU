import { Want } from '@kit.AbilityKit'
import { shortcuts } from '@kit.ArkUI'

export class ShortcutService {
  /**
   * 创建桌面快捷方式
   * @param fundCode 基金代码
   * @param fundName 基金名称
   */
  static async createShortcut(fundCode: string, fundName: string): Promise<void> {
    try {
      const want: Want = {
        bundleName: 'ai.silhouette.myapplication',
        abilityName: 'EntryAbility',
        parameters: {
          'moduleName': 'entry',
          'page': 'pages/Index',
          'fundCode': fundCode
        }
      }

      // 使用快捷键API创建
      await shortcuts.createShortcut({
        id: 'fund_' + fundCode,
        label: fundName,
        icon: undefined,
        want: want
      })
      console.info('ShortcutService: 快捷方式创建成功 ' + fundName + '(' + fundCode + ')')
    } catch (err) {
      console.error('ShortcutService: 创建快捷方式失败 ' + JSON.stringify(err))
    }
  }
}
