/**
 * ResponsiveWrapper — 响应式内容容器
 *
 * 在平板宽度（≥600dp）下，将内容约束在最大 720dp 宽度并居中；
 * 在手机宽度下则满宽显示（原有行为不变）。
 *
 * 用法：将原本的内容区域包在 ResponsiveWrapper 内即可。
 */
import { AppResponsive } from '../../common/constants/AppConstants'

@Component
export struct ResponsiveWrapper {
  @BuilderParam content: () => void = this.emptyBuilder

  @Builder
  emptyBuilder() {}

  build() {
    Column() {
      Column() {
        this.content()
      }
      .width('100%')
      .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
