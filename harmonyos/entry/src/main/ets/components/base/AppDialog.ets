import { AppColors, AppRadius, AppFontSize, AppSpacing, AppButtonHeight, AppAnimation } from '../../common/constants/AppConstants'
import { AppButton } from './AppButton'

/**
 * 底部弹出式确认弹窗组件
 */
@Component
export struct AppDialog {
  @Link @Watch('onShowDialogChange') showDialog: boolean
  @Prop dialogTitle: string = '提示'
  @Prop dialogContent: string = ''
  @Prop confirmText: string = '确定'
  @Prop cancelText: string = '取消'
  @Prop showCancel: boolean = true
  @Prop singleBtn: boolean = false
  private onConfirm: () => void = (): void => {}
  private onCancel: () => void = (): void => {}

  @State private isAnimShow: boolean = false

  onShowDialogChange(): void {
    if (this.showDialog) {
      setTimeout((): void => {
        this.isAnimShow = true
      }, 20)
    }
  }

  close(action: () => void): void {
    this.isAnimShow = false
    setTimeout((): void => {
      action()
      this.showDialog = false
    }, AppAnimation.SLOW)
  }

  build() {
    if (this.showDialog) {
      Column() {
        // 上半部分空白区（点击关闭弹窗）
        Column()
          .layoutWeight(1)
          .width('100%')
          .onClick((): void => {
            this.close(this.onCancel)
          })

        // 弹窗卡片（水平居中，靠底部）
        Column() {
          // 玻璃模糊背景
          Column()
            .position({ x: 0, y: 0 })
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(255,255,255,0.6)')
            .blur(24)

          // 内容层
          Column({ space: AppSpacing.SM }) {
            Text(this.dialogTitle)
              .fontSize(AppFontSize.HEADING)
              .fontColor(AppColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .width('100%')

            if (this.dialogContent !== '') {
              Text(this.dialogContent)
                .fontSize(AppFontSize.BODY)
                .fontColor(AppColors.TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
                .lineHeight(22)
                .width('100%')
            }

            Row({ space: AppSpacing.LG }) {
              if (this.showCancel && !this.singleBtn) {
                AppButton({
                  btnLabel: this.cancelText,
                  btnWidth: '45%',
                  btnHeight: AppButtonHeight.MEDIUM,
                  btnColor: 'rgba(0,0,0,0.06)',
                  btnTextColor: AppColors.TEXT_PRIMARY,
                  btnFontSize: AppFontSize.BODY,
                  btnRadius: AppRadius.MEDIUM,
                  onClickAction: (): void => {
                    this.close(this.onCancel)
                  }
                })
              }

              AppButton({
                btnLabel: this.singleBtn ? this.confirmText : this.confirmText,
                btnWidth: this.singleBtn ? '80%' : '45%',
                btnHeight: AppButtonHeight.MEDIUM,
                btnFontSize: AppFontSize.BODY,
                btnRadius: AppRadius.MEDIUM,
                onClickAction: (): void => {
                  this.close(this.onConfirm)
                }
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .padding({ left: AppSpacing.MD, right: AppSpacing.MD, top: AppSpacing.XL, bottom: AppSpacing.SM })
          .width('100%')
        }
        .width(320)
        .constraintSize({ maxWidth: '85%' })
        .borderRadius(AppRadius.XLARGE)
        .border({ width: 1.5, color: 'rgba(200,200,200,0.8)' })
        .clip(true)
        .margin({ bottom: 120 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .opacity(this.isAnimShow ? 1 : 0)
      .translate({ y: this.isAnimShow ? 0 : 200 })
      .animation({ duration: AppAnimation.SLOW, curve: Curve.FastOutSlowIn })
    }
  }
}
