import { AppColors, AppRadius, AppSpacing, AppFontSize } from '../../common/constants/AppConstants'

/**
 * 加载中指示器
 * mode: 'spinner' 旋转菊花 | 'skeleton' 骨架屏
 */
@Preview
@Component
export struct LoadingIndicator {
  @Prop mode: string = 'spinner'
  @Prop loadText: string = '加载中...'
  @Prop skeletonCount: number = 3

  build() {
    if (this.mode === 'skeleton') {
      Column({ space: AppSpacing.MD }) {
        ForEach([0, 1, 2], (_i: number) => {
          if (_i < this.skeletonCount) {
            Column({ space: AppSpacing.SM }) {
              Row({ space: AppSpacing.SM }) {
                Circle()
                  .width(40)
                  .height(40)
                  .fill('#E8E8E8')

                Column({ space: 6 }) {
                  Row()
                    .width('60%')
                    .height(14)
                    .borderRadius(4)
                    .backgroundColor('#E8E8E8')

                  Row()
                    .width('40%')
                    .height(10)
                    .borderRadius(4)
                    .backgroundColor('#F0F0F0')
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(AppSpacing.LG)
              .backgroundColor(AppColors.WHITE)
              .borderRadius(AppRadius.CARD)
            }
            .width('100%')
          }
        })
      }
      .width('100%')
      .padding(AppSpacing.LG)
    } else {
      Column({ space: AppSpacing.MD }) {
        LoadingProgress()
          .width(32)
          .height(32)
          .color(AppColors.PRIMARY)

        Text(this.loadText)
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
}
