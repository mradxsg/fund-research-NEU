import { AppColors, AppRadius, AppFontSize } from '../../common/constants/AppConstants'

/**
 * 时间段切换（1月/3月/6月/1年）
 */
@Preview
@Component
export struct SegmentSwitch {
  @Prop segments: string[] = ['1月', '3月', '6月', '1年']
  @Prop selectedIndex: number = 0
  onSelect: (index: number) => void = (_index: number): void => {}

  build() {
    Row({ space: 0 }) {
      ForEach(this.segments, (seg: string, i: number) => {
        Stack() {
          Text(seg)
            .fontSize(AppFontSize.BODY)
            .fontWeight(i === this.selectedIndex ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(i === this.selectedIndex ? AppColors.WHITE : AppColors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(i === this.selectedIndex ? AppColors.PRIMARY : AppColors.PRIMARY_LIGHT)
        .borderRadius({
          topLeft: i === 0 ? AppRadius.MEDIUM : 0,
          bottomLeft: i === 0 ? AppRadius.MEDIUM : 0,
          topRight: i === this.segments.length - 1 ? AppRadius.MEDIUM : 0,
          bottomRight: i === this.segments.length - 1 ? AppRadius.MEDIUM : 0
        })
        .onClick(() => {
          if (i !== this.selectedIndex) {
            this.onSelect(i)
          }
        })
      })
    }
    .width('100%')
    .height(48)
    .constraintSize({ maxWidth: 300 })
    .borderRadius(AppRadius.MEDIUM)
    .clip(true)
  }
}
