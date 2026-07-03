import { AppColors, AppRadius, AppSpacing, AppFontSize } from '../../common/constants/AppConstants'
import { AppButton } from './AppButton'

/**
 * 错误状态组件（含重试按钮）
 */
@Preview
@Component
export struct ErrorState {
  @Prop errTitle: string = '加载失败'
  @Prop errDesc: string = '请检查网络后重试'
  @Prop retryLabel: string = '重试'
  onRetry: () => void = (): void => {}

  build() {
    Column({ space: AppSpacing.LG }) {
      // 错误图标：红色圆底 + 白色感叹号（用Stack叠起来）
      Stack() {
        Circle()
          .width(64)
          .height(64)
          .fill('#FFE5E5')

        Text('!')
          .fontSize(32)
          .fontColor(AppColors.ERROR)
          .fontWeight(FontWeight.Bold)
      }
      .width(64)
      .height(64)

      Text(this.errTitle)
        .fontSize(AppFontSize.BODY_LARGE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)

      Text(this.errDesc)
        .fontSize(AppFontSize.SMALL)
        .fontColor(AppColors.TEXT_TERTIARY)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('80%')

      AppButton({
        btnLabel: this.retryLabel,
        btnWidth: 120,
        btnHeight: 38,
        btnFontSize: AppFontSize.BODY,
        btnRadius: AppRadius.MEDIUM,
        onClickAction: (): void => { this.onRetry() }
      })
    }
    .width('100%')
    .padding(AppSpacing.XXL)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
