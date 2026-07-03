import { AppFontSize, AppColors } from '../../common/constants/AppConstants'

@Preview
@Component
export struct AppText {
  @Prop textValue: string = ''
  @Prop textSize: number = AppFontSize.BODY
  @Prop textWeight: number = FontWeight.Normal
  @Prop textColor: ResourceColor = AppColors.TEXT_PRIMARY
  @Prop txtAlign: TextAlign = TextAlign.Start
  @Prop lineMax: number = 0

  build() {
    Text(this.textValue)
      .fontSize(this.textSize)
      .fontWeight(this.textWeight)
      .fontColor(this.textColor)
      .textAlign(this.txtAlign)
      .maxLines(this.lineMax > 0 ? this.lineMax : 999)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}
