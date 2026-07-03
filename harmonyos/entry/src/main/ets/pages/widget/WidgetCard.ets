/**
 * 鸿蒙元服务 — 基金净值万能卡片布局
 *
 * 在桌面上显示指定基金的最新单位净值、涨跌幅和净值日期。
 * 数据由 WidgetService 从后端 API 定时拉取更新。
 */
@Entry
@Component
struct WidgetCard {
  @LocalStorageLink('fundCode') fundCode: string = '----'
  @LocalStorageLink('fundName') fundName: string = '基金名称'
  @LocalStorageLink('navValue') navValue: string = '0.0000'
  @LocalStorageLink('navChange') navChange: string = '0.00%'
  @LocalStorageLink('navDate') navDate: string = '----'

  build() {
    Column({ space: 4 }) {
      // 基金代码与名称
      Row({ space: 4 }) {
        Text(this.fundCode)
          .fontSize(10)
          .fontColor('#666666')
          .fontWeight(FontWeight.Regular)

        Text(this.fundName)
          .fontSize(10)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .layoutWeight(1)
      }
      .width('100%')
      .constraintSize({ maxWidth: '100%' })

      // 分隔线
      Divider()
        .height(1)
        .color('#E8E8E8')
        .width('100%')

      // 净值（大号数字）
      Text(this.navValue)
        .fontSize(28)
        .fontColor('#1A1A1A')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      // 涨跌幅
      Row({ space: 4 }) {
        Text(this.navChange)
          .fontSize(14)
          .fontColor(this.navChange.startsWith('+') ? '#E74C3C' :
            (this.navChange.startsWith('-') ? '#27AE60' : '#666666'))
          .fontWeight(FontWeight.Medium)

        Text(this.navDate)
          .fontSize(10)
          .fontColor('#999999')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}
