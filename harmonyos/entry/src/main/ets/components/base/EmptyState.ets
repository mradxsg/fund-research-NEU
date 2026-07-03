import { AppColors, AppRadius, AppSpacing, AppFontSize } from '../../common/constants/AppConstants'
import { AppColumn } from './AppColumn'
import { AppText } from './AppText'
import { AppButton } from './AppButton'

/**
 * 空态占位组件
 */
@Preview
@Component
export struct EmptyState {
  @Prop emptyIcon: string = ''
  @Prop emptyTitle: string = '暂无数据'
  @Prop emptyDesc: string = ''
  @Prop actionLabel: string = ''
  @Prop actionDisabled: boolean = false
  onAction: () => void = (): void => {}

  build() {
    Column({ space: AppSpacing.LG }) {
      // Icon placeholder
      if (this.emptyIcon !== '') {
        Image(this.emptyIcon)
          .width(72)
          .height(72)
          .objectFit(ImageFit.Contain)
          .opacity(0.4)
      } else {
        // 默认空态图标：红色圆底 + 白色感叹号
        Stack() {
          Circle()
            .width(72)
            .height(72)
            .fill('#FFE5E5')

          Text('!')
            .fontSize(36)
            .fontColor(AppColors.ERROR)
            .fontWeight(FontWeight.Bold)
        }
        .width(72)
        .height(72)
      }

      Text(this.emptyTitle)
        .fontSize(AppFontSize.BODY_LARGE)
        .fontColor(AppColors.TEXT_TERTIARY)
        .fontWeight(FontWeight.Medium)

      if (this.emptyDesc !== '') {
        Text(this.emptyDesc)
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      if (this.actionLabel !== '') {
        AppButton({
          btnLabel: this.actionLabel,
          btnWidth: 140,
          btnHeight: 36,
          btnFontSize: AppFontSize.BODY,
          btnRadius: AppRadius.MEDIUM,
          btnDisabled: this.actionDisabled,
          onClickAction: (): void => { this.onAction() }
        })
      }
    }
    .width('100%')
    .padding(AppSpacing.XXL)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
