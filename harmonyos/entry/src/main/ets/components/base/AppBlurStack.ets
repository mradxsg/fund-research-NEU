import { AppColors, AppLayout } from '../../common/constants/AppConstants'

@Preview
@Preview
@Component
export struct AppBlurStack {
  @Prop bsWidth: string | number = '100%'
  @Prop bsHeight: string | number = '100%'
  @Prop bsBlur: number = AppLayout.BOTTOMBAR_BLUR
  @Prop bsBgColor: ResourceColor = AppColors.BLUR_BG
  @Prop bsRadius: number = 0
  @BuilderParam content: () => void = this.emptyBuilder

  @Builder
  emptyBuilder(): void {}

  build() {
    Stack() {
      this.content()
    }
    .width(this.bsWidth)
    .height(this.bsHeight)
    .backgroundColor(this.bsBgColor)
    .borderRadius(this.bsRadius)
    .blur(this.bsBlur)
  }
}
