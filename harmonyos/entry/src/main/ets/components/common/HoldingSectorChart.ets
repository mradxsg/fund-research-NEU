import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'
import { FundSector } from '../../common/types'

/**
 * 行业持仓占比（进度条列表）
 */
@Preview
@Component
export struct HoldingSectorChart {
  @Prop sectors: FundSector[] = []

  build() {
    Column({ space: AppSpacing.MD }) {
      Text('行业持仓')
        .fontSize(AppFontSize.BODY_LARGE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      if (this.sectors.length === 0) {
        Text('暂无持仓数据')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .height(40)
      } else {
        ForEach(this.sectors, (s: FundSector) => {
          Column({ space: 4 }) {
            Row() {
              Text(s.sectorName)
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.TEXT_SECONDARY)

              Text(s.ratio.toFixed(1) + '%')
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Row()
                .height(6)
                .width(s.ratio + '%')
                .backgroundColor(AppColors.PRIMARY)
                .borderRadius(3)
            }
            .width('100%')
            .height(6)
            .backgroundColor(AppColors.PRIMARY_LIGHT)
            .borderRadius(3)
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
