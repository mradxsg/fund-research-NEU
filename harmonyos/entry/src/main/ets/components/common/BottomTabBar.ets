import { AppColors, AppFontSize, AppRadius, AppLayout, AppAnimation, AppResponsive } from '../../common/constants/AppConstants'

const TAB_LABELS: string[] = ['基金', '公司', '经理', '自选', '我的']
const TAB_ICONS = [
  $r('app.media.tab_fund'),
  $r('app.media.tab_company'),
  $r('app.media.tab_manager'),
  $r('app.media.tab_fav'),
  $r('app.media.tab_profile')
]

const ICON_SIZE: number = 24
const ICON_SIZE_TABLET: number = 26
const EDGE_GAP: number = 16
const EDGE_GAP_TABLET: number = 24
const ITEM_GAP: number = 10
const TEXT_ICON_GAP: number = 6

@Preview
@Component
export struct BottomTabBar {
  @Watch('onPageIndexChange') @Prop currentPageIndex: number = 0
  @Prop containerWidth: number = 360
  @Prop isTablet: boolean = false
  @State private activeIndex: number = 0
  onPageChange: (index: number) => void = (_index: number): void => {}

  aboutToAppear(): void {
    this.activeIndex = this.currentPageIndex
  }

  onPageIndexChange(): void {
    if (this.activeIndex !== this.currentPageIndex) {
      this.activeIndex = this.currentPageIndex
    }
  }

  build() {
    Stack() {
      Stack()
        .width('100%')
        .height('100%')
        .backgroundColor(AppColors.BLUR_BG)
        .borderRadius(AppRadius.BOTTOMBAR)
        .blur(AppLayout.BOTTOMBAR_BLUR)

      Row({ space: this.isTablet ? ITEM_GAP + 4 : ITEM_GAP }) {
        ForEach([0, 1, 2, 3, 4], (i: number) => {
          Column() {
            Row({ space: TEXT_ICON_GAP }) {
              Image(TAB_ICONS[i])
                .width(this.isTablet ? ICON_SIZE_TABLET : ICON_SIZE)
                .height(this.isTablet ? ICON_SIZE_TABLET : ICON_SIZE)
                .fillColor(i === this.activeIndex ? AppColors.TAB_ACTIVE : AppColors.TAB_INACTIVE)
                .scale({ x: i === this.activeIndex ? 1.4 : 1, y: i === this.activeIndex ? 1.4 : 1 })

              if (i === this.activeIndex) {
                Text(TAB_LABELS[i])
                  .fontSize(this.isTablet ? AppFontSize.HEADING : AppFontSize.BODY_LARGE)
                  .fontColor(AppColors.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)
                  .transition(TransitionEffect.scale({ x: 0, y: 0 }).animation({ duration: AppAnimation.NORMAL, curve: Curve.FastOutSlowIn }))
              }
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            if (i !== this.activeIndex) {
              animateTo({ duration: AppAnimation.NORMAL, curve: Curve.FastOutSlowIn }, () => {
                this.activeIndex = i
              })
              this.onPageChange(i)
            }
          })
        }, (i: number) => i.toString())
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.isTablet ? EDGE_GAP_TABLET : EDGE_GAP, right: this.isTablet ? EDGE_GAP_TABLET : EDGE_GAP })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(this.isTablet ? AppLayout.BOTTOMBAR_HEIGHT + 4 : AppLayout.BOTTOMBAR_HEIGHT)
    .borderRadius(AppRadius.BOTTOMBAR)
  }
}
