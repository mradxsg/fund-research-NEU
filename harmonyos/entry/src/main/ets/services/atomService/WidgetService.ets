import { formProvider, formBindingData } from '@kit.FormKit'
import { FundApi } from '../api/FundApi'

/**
 * 万能卡片数据服务
 *
 * 负责获取基金净值数据并更新桌面卡片显示内容。
 */
export class WidgetService {
  /**
   * 更新指定卡片的数据
   *
   * @param formId 桌面卡片ID
   * @param fundCode 基金代码
   */
  static async updateWidgetData(formId: string, fundCode: string): Promise<void> {
    try {
      const data = await FundApi.getByCode(fundCode)
      if (data == null) {
        console.error('WidgetService: 基金数据为空')
        return
      }
      const navValue: string = data.unitNav != null ? String(data.unitNav) : '暂无'
      const navChange: string = data.dailyReturn != null ? String(data.dailyReturn) : ''
      const navDate: string = data.latestNavDate ?? ''

      const formData: Record<string, Object> = {
        'fundName': data.name ?? '基金净值',
        'navValue': navValue,
        'navChange': navChange,
        'navDate': navDate
      }

      const bindingData: formBindingData.FormBindingData =
        formBindingData.createFormBindingData(formData)
      await formProvider.updateForm(formId, bindingData)
    } catch (err) {
      console.error('WidgetService 更新失败: ' + JSON.stringify(err))
    }
  }
}
