import { AppColors, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'

/**
 * 标签-值信息行（用于详情页展示键值对）
 */
@Preview
@Component
export struct InfoRow {
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop valueColor: ResourceColor = AppColors.TEXT_PRIMARY
  @Prop showArrow: boolean = false
  @Prop isLink: boolean = false
  @Prop allowWrap: boolean = false
  onRowClick: () => void = (): void => {}

  build() {
    Row({ space: AppSpacing.SM }) {
      Text(this.label)
        .fontSize(AppFontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
        .layoutWeight(1)

      Row({ space: 4 }) {
        Text(this.value)
          .fontSize(AppFontSize.BODY)
          .fontColor(this.valueColor)
          .fontWeight(this.isLink ? FontWeight.Medium : FontWeight.Normal)
          .textAlign(TextAlign.End)
          .maxLines(this.allowWrap ? 999 : 1)
          .textOverflow({ overflow: this.allowWrap ? TextOverflow.Clip : TextOverflow.Ellipsis })

        if (this.showArrow || this.isLink) {
          Text('>')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
      }
      .constraintSize({ maxWidth: this.allowWrap ? '75%' : '60%' })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      if (this.showArrow || this.isLink) {
        this.onRowClick()
      }
    })
  }
}
