import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'
import { InfoRow } from '../base/InfoRow'

/**
 * 基金基本信息面板
 */
@Preview
@Component
export struct FundBasicInfo {
  @Prop fundCode: string = ''
  @Prop fundName: string = ''
  @Prop fundType: string = ''
  @Prop fundScale: number = 0
  @Prop establishDate: string = ''
  @Prop riskLevel: string = ''
  @Prop benchmark: string = ''

  build() {
    Column({ space: 0 }) {
      Text(this.fundName)
        .fontSize(AppFontSize.TITLE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text(this.fundCode + ' · ' + this.fundType)
        .fontSize(AppFontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
        .width('100%')
        .padding({ top: 4, bottom: AppSpacing.MD })

      InfoRow({ label: '基金类型', value: this.fundType })
      this.line()
      InfoRow({ label: '基金规模', value: this.fundScale > 0 ? this.fundScale.toFixed(2) + '亿' : '--' })
      this.line()
      InfoRow({ label: '成立日期', value: this.establishDate })
      this.line()
      InfoRow({ label: '风险等级', value: this.riskLevel })
      this.line()
      InfoRow({ label: '业绩基准', value: this.benchmark, allowWrap: true })
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.WHITE)
    .borderRadius(AppRadius.CARD)
  }

  @Builder
  line() {
    Row().width('100%').height(0.5).backgroundColor(AppColors.DIVIDER)
  }
}

