import { AppGradientColors } from '../../common/constants/AppConstants'

@Component
export struct GradientBackground {
  build() {
    Column()
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [[AppGradientColors.LIGHT_TOP, 0.0], [AppGradientColors.LIGHT_BOTTOM, 1.0]]
      })
  }
}
