import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'

/**
 * 基金公司卡片
 */
@Preview
@Component
export struct CompanyCard {
  @Prop companyName: string = ''
  @Prop fundCount: number = 0
  onCardClick: () => void = (): void => {}

  build() {
    Row({ space: AppSpacing.MD }) {
      // 头像
      Stack() {
        Circle()
          .width(44)
          .height(44)
          .fill(AppColors.PRIMARY_LIGHT)

        Text(this.companyName.length > 0 ? this.companyName.substring(0, 1) : '?')
          .fontSize(AppFontSize.BODY_LARGE)
          .fontColor(AppColors.PRIMARY)
          .fontWeight(FontWeight.Bold)
      }
      .width(44)
      .height(44)

      Column({ space: 4 }) {
        Text(this.companyName)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('管理 ' + this.fundCount + ' 只基金')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('>')
        .fontSize(AppFontSize.BODY)
        .fontColor(AppColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.WHITE)
    .borderRadius(AppRadius.CARD)
    .alignItems(VerticalAlign.Center)
    .onClick(() => { this.onCardClick() })
  }
}

