import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'

/**
 * Toast 轻提示类型
 */
export enum ToastType {
  SUCCESS = 'success',
  ERROR = 'error',
  WARNING = 'warning',
  INFO = 'info'
}

/**
 * 轻提示组件（嵌入页面底部/顶部，自动消失）
 */
@Preview
@Component
export struct Toast {
  @Prop toastMessage: string = ''
  @Prop toastType: ToastType = ToastType.INFO
  @Prop toastVisible: boolean = false

  build() {
    if (this.toastVisible && this.toastMessage !== '') {
      Row({ space: AppSpacing.SM }) {
        // 类型指示点
        Circle()
          .width(8)
          .height(8)
          .fill(this.getTypeColor())

        Text(this.toastMessage)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.WHITE)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('80%')
      .padding({ top: AppSpacing.MD, bottom: AppSpacing.MD, left: AppSpacing.LG, right: AppSpacing.LG })
      .backgroundColor(this.getTypeBgColor())
      .borderRadius(AppRadius.MEDIUM)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .position({ bottom: 120 })
      .zIndex(999)
      .transition(
        TransitionEffect.opacity(0.3)
          .animation({ duration: 300, curve: Curve.FastOutSlowIn })
      )
    }
  }

  getTypeColor(): ResourceColor {
    if (this.toastType === ToastType.SUCCESS) return AppColors.SUCCESS
    if (this.toastType === ToastType.ERROR) return AppColors.ERROR
    if (this.toastType === ToastType.WARNING) return AppColors.WARNING
    return AppColors.PRIMARY
  }

  getTypeBgColor(): ResourceColor {
    if (this.toastType === ToastType.SUCCESS) return 'rgba(52,199,89,0.9)'
    if (this.toastType === ToastType.ERROR) return 'rgba(255,59,48,0.9)'
    if (this.toastType === ToastType.WARNING) return 'rgba(255,149,0,0.9)'
    return 'rgba(0,122,255,0.9)'
  }
}
