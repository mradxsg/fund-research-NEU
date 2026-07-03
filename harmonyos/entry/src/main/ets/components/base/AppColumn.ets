import { AppSpacing } from '../../common/constants/AppConstants'

@Preview
@Component
export struct AppColumn {
  @Prop colWidth: string | number = '100%'
  @Prop colHeight: string | number = '100%'
  @Prop colPadding: string | number = 0
  @Prop colSpace: string | number = AppSpacing.SM
  @Prop colAlign: HorizontalAlign = HorizontalAlign.Center
  @Prop colJustify: FlexAlign = FlexAlign.Start
  @BuilderParam content: () => void = this.emptyBuilder

  @Builder
  emptyBuilder() {}

  build() {
    Column({ space: this.colSpace }) {
      this.content()
    }
    .width(this.colWidth)
    .height(this.colHeight)
    .padding(this.colPadding)
    .alignItems(this.colAlign)
    .justifyContent(this.colJustify)
  }
}
