import { AppButtonHeight, AppRadius, AppFontSize, AppColors } from '../../common/constants/AppConstants'

@Preview
@Component
export struct AppButton {
  @Prop btnLabel: string = '按钮'
  @Prop btnHeight: number = AppButtonHeight.MEDIUM
  @Prop btnWidth: string | number = '100%'
  @Prop btnColor: ResourceColor = AppColors.PRIMARY
  @Prop btnTextColor: ResourceColor = AppColors.WHITE
  @Prop btnFontSize: number = AppFontSize.BODY
  @Prop btnRadius: number = AppRadius.BUTTON
  @Prop btnDisabled: boolean = false
  onClickAction: () => void = (): void => {}

  build() {
    Button(this.btnLabel, { type: ButtonType.Normal, stateEffect: true })
      .width(this.btnWidth)
      .height(this.btnHeight)
      .backgroundColor(this.btnDisabled ? '#CCCCCC' : this.btnColor)
      .fontSize(this.btnFontSize)
      .fontColor(this.btnTextColor)
      .borderRadius(this.btnRadius)
      .enabled(!this.btnDisabled)
      .onClick(() => { this.onClickAction() })
  }
}
