import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'

@Preview
@Component
export struct FundCard {
  @Prop fundCode: string = ''
  @Prop fundName: string = ''
  @Prop fundType: string = ''
  @Prop riskLevel: string = ''
  @Prop latestNav: number = 0
  @Prop dailyReturn: number = 0
  @Prop showMarketData: boolean = true
  onCardClick: () => void = (): void => {}

  build() {
    Row({ space: AppSpacing.MD }) {
      Column({ space: 4 }) {
        Row({ space: AppSpacing.SM }) {
          Text(this.fundCode)
            .fontSize(AppFontSize.SMALL)
            .fontColor(AppColors.PRIMARY)
            .fontWeight(FontWeight.Medium)

          if (this.fundType !== '') {
            Text(this.fundType)
              .fontSize(AppFontSize.TINY)
              .fontColor(AppColors.PRIMARY)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(AppColors.PRIMARY_LIGHT)
              .borderRadius(4)
          }
          if (this.riskLevel !== '') {
            Text(this.riskLevel)
              .fontSize(AppFontSize.TINY)
              .fontColor('#FF9500')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#FFF5E8')
              .borderRadius(4)
          }
        }
        .alignItems(VerticalAlign.Center)

        Text(this.fundName)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 2 }) {
        Text(this.showMarketData && this.latestNav > 0 ? this.latestNav.toFixed(4) : '--')
          .fontSize(AppFontSize.BODY_LARGE)
          .fontColor(this.showMarketData ? (this.dailyReturn >= 0 ? '#FF3B30' : '#1AA84A') : AppColors.TEXT_TERTIARY)
          .fontWeight(FontWeight.Medium)

        Text(this.showMarketData ? (this.dailyReturn >= 0 ? '+' : '') + this.dailyReturn.toFixed(2) + '%' : '暂无净值')
          .fontSize(AppFontSize.SMALL)
          .fontColor(this.showMarketData ? (this.dailyReturn >= 0 ? '#FF3B30' : '#1AA84A') : AppColors.TEXT_TERTIARY)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.WHITE)
    .borderRadius(AppRadius.CARD)
    .alignItems(VerticalAlign.Center)
    .onClick(() => { this.onCardClick() })
  }
}
