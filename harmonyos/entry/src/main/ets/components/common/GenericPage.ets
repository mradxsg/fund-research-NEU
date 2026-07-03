import { TopBar } from './TopBar'
import { AppColors, AppResponsive } from '../../common/constants/AppConstants'

const STATUS_BAR_HEIGHT: number = 44
/** 顶栏总高度 = 状态栏 + 标题行 */
const TOPBAR_TOTAL: number = STATUS_BAR_HEIGHT + 48

/**
 * 通用页面壳 —— Stack 布局，TopBar 悬浮在上方，内容穿透
 * 平板模式下内容居中且最大宽度 720dp
 */
@Preview
@Component
export struct GenericPage {
  @Prop pageTitle: string = ''
  @Prop showBack: boolean = true
  @Prop showTopBar: boolean = true
  onBack: () => void = (): void => {}

  @BuilderParam content: () => void = this.emptyBuilder

  @Builder
  emptyBuilder() {}

  build() {
    Stack() {
      // === 内容层（全屏，从状态栏下方开始） ===
      Column() {
        Scroll() {
          // 平板模式下内容居中，最大宽度 720dp
          Column() {
            Column() {
              // 占位：高度等于悬浮 topBar，防止内容被遮挡
              Column()
                .height(TOPBAR_TOTAL)
                .width('100%')

              // 实际内容
              this.content()
            }
            .width('100%')
            .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')

      // === 悬浮 TopBar ===
      if (this.showTopBar) {
        TopBar({
          pageTitle: this.pageTitle,
          showBack: this.showBack,
          onBack: (): void => { this.onBack() }
        })
        .position({ top: 0 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
