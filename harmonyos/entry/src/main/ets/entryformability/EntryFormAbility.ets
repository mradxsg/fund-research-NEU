import { FormExtensionAbility, formBindingData } from '@kit.FormKit'
import { Want } from '@kit.AbilityKit'
import { WidgetService } from '../services/atomService/WidgetService'

/**
 * 鸿蒙元服务 — 万能卡片生命周期管理
 *
 * 管理桌面卡片的创建与定时更新。
 * 默认展示 '000001' 基金净值数据，定时刷新。
 */
export default class EntryFormAbility extends FormExtensionAbility {
  /**
   * 卡片创建时回调
   * 初始化卡片数据
   */
  onAddForm(want: Want): formBindingData.FormBindingData {
    const fundCode: string = (want.parameters?.['fundCode'] as string) ?? '000001'

    return formBindingData.createFormBindingData({
      'fundCode': fundCode,
      'fundName': '基金净值',
      'navValue': '加载中...',
      'navChange': '',
      'navDate': ''
    })
  }

  /**
   * 卡片更新回调（定时刷新触发）
   */
  onUpdateForm(formId: string): void {
    WidgetService.updateWidgetData(formId, '000001')
  }
}
