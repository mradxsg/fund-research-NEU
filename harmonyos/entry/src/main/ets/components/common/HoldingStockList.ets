import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'
import { FundStock } from '../../common/types'

/**
 * 前十大重仓股列表
 */
@Preview
@Component
export struct HoldingStockList {
  @Prop stocks: FundStock[] = []

  build() {
    Column({ space: AppSpacing.MD }) {
      Text('前十大重仓股')
        .fontSize(AppFontSize.BODY_LARGE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      if (this.stocks.length === 0) {
        Text('暂无持仓数据')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .height(40)
      } else {
        ForEach(this.stocks, (s: FundStock, i: number) => {
          Row() {
            Text('' + (i + 1))
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
              .width(20)

            Text(s.stockName)
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_PRIMARY)
              .layoutWeight(1)

            Text(s.ratio.toFixed(2) + '%')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })

          if (i < this.stocks.length - 1) {
            Row().width('100%').height(0.5).backgroundColor(AppColors.DIVIDER)
          }
        })
      }
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.WHITE)
    .borderRadius(AppRadius.CARD)
  }
}
