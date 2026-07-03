@Preview
@Component
export struct AppStack {
  @Prop stackWidth: string | number = '100%'
  @Prop stackHeight: string | number = '100%'
  @Prop stackAlign: Alignment = Alignment.Center
  @BuilderParam content: () => void = this.emptyBuilder

  @Builder
  emptyBuilder() {}

  build() {
    Stack() {
      this.content()
    }
    .width(this.stackWidth)
    .height(this.stackHeight)
    .alignContent(this.stackAlign)
  }
}
