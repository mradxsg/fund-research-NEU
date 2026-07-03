import { AppColors, AppFontSize, AppSpacing, AppLayout, AppRadius, AppHeight, AppResponsive } from '../../common/constants/AppConstants'
import { GradientBackground } from '../base/GradientBackground'

// 状态栏高度（全屏模式下需要预留）
const STATUS_BAR_HEIGHT: number = 44

@Preview
@Component
export struct SubPageShell {
  @Prop pageTitle: string = ''
  @Prop showBack: boolean = true
  onBack: () => void = (): void => {}
  @BuilderParam content: () => void = this.emptyBuilder

  @Builder
  emptyBuilder() {}

  build() {
    Stack() {
      // 动态渐变背景
      GradientBackground()

      // Content fills the area below top bar — 平板下居中最大宽度
      Column() {
        Row().height(STATUS_BAR_HEIGHT).width('100%')

        Column() {
          this.content()
        }
        .width('100%')
        .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ left: 16, right: 16, bottom: 16 })

      // Top bar — 平板下内容居中
      Column() {
        Row()
          .height(AppHeight.TOPBAR)
          .width('100%')
          .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
          .backgroundColor(AppColors.BLUR_BG)
          .alignItems(VerticalAlign.Center)
        {
          Column() {
            Row({ space: AppSpacing.SM }) {
              if (this.showBack) {
                Text('←')
                  .fontSize(AppFontSize.BODY_LARGE)
                  .fontColor(AppColors.PRIMARY)
                  .onClick(() => { this.onBack() })
              }
              Text(this.pageTitle)
                .fontSize(AppFontSize.BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(AppColors.TEXT_PRIMARY)
            }
            .width('100%')
            .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .position({ top: STATUS_BAR_HEIGHT, left: 0 })
    }
    .width('100%')
    .height('100%')
  }
}
