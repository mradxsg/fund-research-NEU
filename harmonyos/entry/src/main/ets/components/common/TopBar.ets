import { AppColors, AppFontSize, AppSpacing, AppRadius, AppHeight, AppLayout } from '../../common/constants/AppConstants'

const STATUS_BAR_HEIGHT: number = 44
/** 顶栏总高度 = 状态栏 + 标题行 */
const TOPBAR_TOTAL: number = STATUS_BAR_HEIGHT + AppHeight.TOPBAR

/**
 * 独立可复用顶栏组件
 * 固定高度 TOPBAR_TOTAL，悬浮在内容上方，毛玻璃效果与主界面一致
 */
@Preview
@Component
export struct TopBar {
  @Prop pageTitle: string = ''
  @Prop showBack: boolean = true
  onBack: () => void = (): void => {}

  @BuilderParam rightActions: () => void = this.emptyBuilder

  @Builder
  emptyBuilder() {}

  build() {
    Stack() {
      // 毛玻璃背景 — 与主界面 title 一致
      Column()
        .width('100%')
        .height(TOPBAR_TOTAL)
        .backgroundColor(AppColors.TOPBAR_BG)
        .blur(AppLayout.TOPBAR_BLUR)

      // 内容层
      Column() {
        Row().height(STATUS_BAR_HEIGHT).width('100%')

        Row({ space: AppSpacing.SM }) {
          if (this.showBack) {
            Button('←')
              .fontSize(AppFontSize.BODY_LARGE)
              .fontColor(AppColors.PRIMARY)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Color.Transparent)
              .width(44)
              .height(44)
              .onClick(() => { this.onBack() })
          }

          Text(this.pageTitle)
            .fontSize(AppFontSize.TITLE)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT_PRIMARY)
            .layoutWeight(1)

          Row({ space: AppSpacing.SM }) {
            this.rightActions()
          }
          .alignItems(VerticalAlign.Center)
        }
        .height(AppHeight.TOPBAR)
        .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
        .width('100%')
      }
      .width('100%')

      // 底部半透明分割线
      Row()
        .width('100%')
        .height(1)
        .backgroundColor('rgba(0,0,0,0.06)')
        .position({ bottom: 0 })
    }
    .width('100%')
    .height(TOPBAR_TOTAL)
  }
}
