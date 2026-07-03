@Preview
@Component
export struct AppImage {
  @Prop imgSrc: string = ''
  @Prop imgWidth: string | number = 24
  @Prop imgHeight: string | number = 24
  @Prop imgFit: ImageFit = ImageFit.Contain
  @Prop imgRadius: string | number = 0

  build() {
    Image(this.imgSrc)
      .width(this.imgWidth)
      .height(this.imgHeight)
      .objectFit(this.imgFit)
      .borderRadius(this.imgRadius)
  }
}
