import { AppColors, AppFontSize, AppSpacing, AppRadius } from '../../common/constants/AppConstants'

@Preview
@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索'
  @Prop initValue: string = ''
  @State searchValue: string = ''
  @State isFocused: boolean = false
  onChange: (val: string) => void = (_val: string): void => {}
  onSearch: (val: string) => void = (_val: string): void => {}

  aboutToAppear(): void {
    this.searchValue = this.initValue
  }

  build() {
    Row({ space: AppSpacing.SM }) {
      TextInput({ placeholder: this.placeholder, text: this.searchValue })
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(Color.Transparent)
        .fontSize(AppFontSize.BODY)
        .fontColor(AppColors.TEXT_PRIMARY)
        .placeholderColor(AppColors.TEXT_TERTIARY)
        .onChange((val: string): void => {
          this.searchValue = val
          this.onChange(val)
        })
        .onSubmit((_val: EnterKeyType): void => {
          this.onSearch(this.searchValue)
        })
        .onFocus(() => { this.isFocused = true })
        .onBlur(() => { this.isFocused = false })

      Row({ space: 0 }) {
        if (this.searchValue.length > 0) {
          Button('×')
            .fontSize(18)
            .fontColor(AppColors.TEXT_TERTIARY)
            .backgroundColor(Color.Transparent)
            .width(36)
            .padding({ left: 0, right: 0 })
            .height(32)
            .borderRadius(AppRadius.SMALL)
            .onClick(() => {
              this.searchValue = ''
              this.onChange('')
              this.onSearch('')
            })
        }

        Button('搜索')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.PRIMARY)
          .backgroundColor(Color.Transparent)
          .width(64)
          .height(32)
          .borderRadius(AppRadius.SMALL)
          .onClick(() => {
            this.onSearch(this.searchValue)
          })
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(40)
    .padding({ left: 8, right: 4 })
    .backgroundColor(this.isFocused ? AppColors.WHITE : '#F0F0F0')
    .borderRadius(AppRadius.MEDIUM)
    .border({ width: this.isFocused ? 1 : 0, color: this.isFocused ? AppColors.PRIMARY : Color.Transparent })
    .alignItems(VerticalAlign.Center)
  }
}
