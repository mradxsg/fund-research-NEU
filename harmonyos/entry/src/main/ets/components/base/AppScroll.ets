import { AppSpacing } from '../../common/constants/AppConstants'

@Preview
@Component
export struct AppScroll {
  @Prop scrollDir: ScrollDirection = ScrollDirection.Vertical
  @Prop scrollBarState: BarState = BarState.Off
  @Prop scrollPad: string | number = 0
  @BuilderParam content: () => void = this.emptyBuilder

  @Builder
  emptyBuilder() {}

  build() {
    Scroll() {
      Column() {
        this.content()
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollable(this.scrollDir)
    .scrollBar(this.scrollBarState)
    .padding(this.scrollPad)
  }
}
