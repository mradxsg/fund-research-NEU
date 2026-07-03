import { AppRadius, AppFontSize, AppColors, AppSpacing } from '../../common/constants/AppConstants'

@Preview
@Component
export struct AppTextInput {
  @Prop phText: string = ''
  @Prop initValue: string = ''
  @Prop inpHeight: number = 40
  @Prop inpBgColor: ResourceColor = '#F5F6FA'
  @Prop inpRadius: number = AppRadius.INPUT
  @Prop inpPadding: string | number = AppSpacing.MD
  @Prop isPassword: boolean = false
  @State innerValue: string = ''
  onChange: (val: string) => void = (val: string): void => {}

  aboutToAppear(): void {
    this.innerValue = this.initValue
  }

  build() {
    TextInput({ placeholder: this.phText, text: this.innerValue })
      .width('100%')
      .height(this.inpHeight)
      .backgroundColor(this.inpBgColor)
      .borderRadius(this.inpRadius)
      .padding(this.inpPadding)
      .fontSize(AppFontSize.BODY)
      .fontColor(AppColors.TEXT_PRIMARY)
      .placeholderColor(AppColors.TEXT_TERTIARY)
      .type(this.isPassword ? InputType.Password : InputType.Normal)
      .onChange((val: string): void => {
        this.innerValue = val
        this.onChange(val)
      })
  }
}
