import { AppSpacing } from '../../common/constants/AppConstants'

@Preview
@Component
export struct AppRow {
  @Prop rowWidth: string | number = '100%'
  @Prop rowHeight: string | number = '100%'
  @Prop rowPadding: string | number = 0
  @Prop rowSpace: string | number = AppSpacing.SM
  @Prop rowAlign: VerticalAlign = VerticalAlign.Center
  @Prop rowJustify: FlexAlign = FlexAlign.Start
  @BuilderParam content: () => void = this.emptyBuilder

  @Builder
  emptyBuilder() {}

  build() {
    Row({ space: this.rowSpace }) {
      this.content()
    }
    .width(this.rowWidth)
    .height(this.rowHeight)
    .padding(this.rowPadding)
    .alignItems(this.rowAlign)
    .justifyContent(this.rowJustify)
  }
}
