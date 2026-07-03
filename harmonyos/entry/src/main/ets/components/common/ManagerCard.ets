import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'

/**
 * 基金经理卡片
 */
@Preview
@Component
export struct ManagerCard {
  @Prop managerName: string = ''
  @Prop experienceYears: number = 0
  @Prop fundCount: number = 0
  @Prop showArrow: boolean = true
  onCardClick: () => void = (): void => {}

  build() {
    Row({ space: AppSpacing.MD }) {
      Stack() {
        Circle()
          .width(44)
          .height(44)
          .fill('#E8F2FF')

        Text(this.managerName.length > 0 ? this.managerName.substring(0, 1) : '?')
          .fontSize(AppFontSize.BODY_LARGE)
          .fontColor(AppColors.PRIMARY)
          .fontWeight(FontWeight.Bold)
      }
      .width(44)
      .height(44)

      Column({ space: 4 }) {
        Text(this.managerName)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('从业 ' + this.experienceYears + ' 年 · 管理 ' + this.fundCount + ' 只基金')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.showArrow) {
        Text('>')
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_TERTIARY)
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

