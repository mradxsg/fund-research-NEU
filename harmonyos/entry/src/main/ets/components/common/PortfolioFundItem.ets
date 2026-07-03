import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'

/**
 * 组合内的基金条目（含基金类型）
 */
@Preview
@Component
export struct PortfolioFundItem {
  @Prop fundCode: string = ''
  @Prop fundName: string = ''
  @Prop fundType: string = ''
  @Prop latestNav: number = 0
  @Prop showRemove: boolean = false
  onItemClick: () => void = (): void => {}
  onRemove: () => void = (): void => {}

  build() {
    Row({ space: AppSpacing.MD }) {
      Column({ space: 2 }) {
        Row({ space: AppSpacing.SM }) {
          Text(this.fundCode)
            .fontSize(AppFontSize.SMALL)
            .fontColor(AppColors.TEXT_TERTIARY)

          if (this.fundType !== '') {
            Text(this.fundType)
              .fontSize(AppFontSize.TINY)
              .fontColor(AppColors.PRIMARY)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(AppColors.PRIMARY_LIGHT)
              .borderRadius(4)
          }

          Text(this.fundName)
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(this.latestNav > 0 ? this.latestNav.toFixed(4) : '--')
        .fontSize(AppFontSize.BODY)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .margin({ right: AppSpacing.SM })

      if (this.showRemove) {
        Text('删除')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.ERROR)
          .padding({ left: AppSpacing.SM, right: AppSpacing.SM })
          .onClick(() => { this.onRemove() })
      }
    }
    .width('100%')
    .padding({ top: AppSpacing.MD, bottom: AppSpacing.MD, left: AppSpacing.LG, right: AppSpacing.LG })
    .alignItems(VerticalAlign.Center)
    .onClick(() => { this.onItemClick() })
  }
}
