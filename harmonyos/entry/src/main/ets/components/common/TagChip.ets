import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'

@Preview
@Component
export struct TagChip {
  @Prop label: string = ''
  @Prop selected: boolean = false
  @Prop mode: string = 'fill'
  onChipClick: () => void = (): void => {}

  build() {
    Button(this.label)
      .fontSize(AppFontSize.SMALL)
      .fontColor(this.selected ? AppColors.WHITE : AppColors.TEXT_SECONDARY)
      .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Normal)
      .padding({ top: 4, bottom: 4, left: AppSpacing.MD, right: AppSpacing.MD })
      .backgroundColor(this.selected ? AppColors.PRIMARY : AppColors.PRIMARY_LIGHT)
      .borderRadius(AppRadius.MEDIUM)
      .height(28)
      .onClick(() => { this.onChipClick() })
  }
}