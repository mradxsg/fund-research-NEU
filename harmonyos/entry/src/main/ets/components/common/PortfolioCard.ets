import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'

/**
 * 自选组合卡片
 */
@Preview
@Component
export struct PortfolioCard {
  @Prop portfolioName: string = ''
  @Prop fundCount: number = 0
  @Prop createdAt: string = ''
  onCardClick: () => void = (): void => {}
  onCardDelete: () => void = (): void => {}
  onCardRename: () => void = (): void => {}

  build() {
    Row({ space: AppSpacing.MD }) {
      Column({ space: 4 }) {
        Text(this.portfolioName)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row({ space: AppSpacing.SM }) {
          Text('基金 ' + this.fundCount + ' 只')
            .fontSize(AppFontSize.SMALL)
            .fontColor(AppColors.TEXT_TERTIARY)

          if (this.createdAt !== '') {
            Text('创建于 ' + this.createdAt.substring(0, 10))
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Row({ space: AppSpacing.SM }) {
        Text('重命名')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.PRIMARY)
          .onClick(() => { this.onCardRename() })

        Text('删除')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.ERROR)
          .onClick(() => { this.onCardDelete() })
      }
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.WHITE)
    .borderRadius(AppRadius.CARD)
    .alignItems(VerticalAlign.Center)
    .onClick(() => { this.onCardClick() })
  }
}

