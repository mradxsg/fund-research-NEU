import { AppColors, AppRadius, AppFontSize, AppSpacing, AppLayout } from '../../common/constants/AppConstants'
import { SegmentSwitch } from './SegmentSwitch'
import { NavPoint } from '../../common/types'

@Preview
@Component
export struct NavChart {
  @Prop navData: NavPoint[] = []
  @Prop selectedPeriod: number = 0
  onPeriodChange: (index: number) => void = (_i: number): void => {}

  getLastIndex(): number {
    return this.navData.length - 1
  }

  /** 获取净值涨跌颜色（与主页 FundCard 保持一致） */
  getNavChangeColor(curr: number, prev: number): ResourceColor {
    if (curr >= prev) {
      return '#1AA84A' // 涨→绿色
    } else {
      return '#FF3B30' // 跌→红色
    }
  }

  getUnitNavColor(): ResourceColor {
    if (this.navData.length < 2) {
      return AppColors.TEXT_PRIMARY
    }
    return this.getNavChangeColor(
      this.navData[this.getLastIndex()].unitNav,
      this.navData[this.getLastIndex() - 1].unitNav
    )
  }

  getAccumNavColor(): ResourceColor {
    if (this.navData.length < 2) {
      return AppColors.TEXT_PRIMARY
    }
    return this.getNavChangeColor(
      this.navData[this.getLastIndex()].accumNav,
      this.navData[this.getLastIndex() - 1].accumNav
    )
  }

  build() {
    Column({ space: AppSpacing.MD }) {
      Text('净值走势')
        .fontSize(AppFontSize.BODY_LARGE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      SegmentSwitch({
        segments: ['近1月', '近3月', '近6月', '近1年'],
        selectedIndex: this.selectedPeriod,
        onSelect: (i: number): void => { this.onPeriodChange(i) }
      })

      if (this.navData.length > 0) {
        Row({ space: AppSpacing.LG }) {
          Column({ space: 4 }) {
            Text('单位净值')
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
            Text(this.navData[this.getLastIndex()].unitNav.toFixed(4))
              .fontSize(AppFontSize.HEADING)
              .fontColor(this.getUnitNavColor())
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(HorizontalAlign.Start)

          Column({ space: 4 }) {
            Text('累计净值')
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
            Text(this.navData[this.getLastIndex()].accumNav.toFixed(4))
              .fontSize(AppFontSize.HEADING)
              .fontColor(this.getAccumNavColor())
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        NavLineChart({ navData: this.navData })
      } else {
        Text('暂无净值数据')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .height(60)
      }
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.WHITE)
    .borderRadius(AppRadius.CARD)
  }
}

interface Point {
  x: number
  y: number
}

@Component
struct NavLineChart {
  @Prop @Watch('onNavDataChange') navData: NavPoint[] = []
  @State internalData: NavPoint[] = []
  private chartHeight: number = 160
  private chartPadding: number = 20
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D()
  private isCanvasReady: boolean = false
  private maxSamplePoints: number = 30
  private animStep: number = 0
  private animTotalSteps: number = 45
  private animTimerId: number = -1

  aboutToAppear(): void {
    this.internalData = this.sampleData(this.navData)
  }

  onNavDataChange(): void {
    this.internalData = this.sampleData(this.navData)
    if (this.isCanvasReady) {
      this.startAnimateDraw()
    }
  }

  sampleData(data: NavPoint[]): NavPoint[] {
    if (data == null || data.length === 0) {
      return []
    }
    if (data.length <= this.maxSamplePoints) {
      return data
    }
    let result: NavPoint[] = []
    let step = (data.length - 1) / (this.maxSamplePoints - 1)
    for (let i = 0; i < this.maxSamplePoints; i++) {
      let idx = Math.round(i * step)
      result.push(data[idx])
    }
    return result
  }

  getMinNav(): number {
    let data = this.internalData
    if (data.length === 0) return 0
    let min = data[0].unitNav
    for (const p of data) {
      if (p.unitNav < min) min = p.unitNav
    }
    return Math.floor(min * 100) / 100
  }

  getMaxNav(): number {
    let data = this.internalData
    if (data.length === 0) return 1
    let max = data[0].unitNav
    for (const p of data) {
      if (p.unitNav > max) max = p.unitNav
    }
    return Math.ceil(max * 100) / 100
  }

  getRange(): number {
    let range = this.getMaxNav() - this.getMinNav()
    return range === 0 ? 1 : range
  }

  getPointAtIndex(i: number): Point {
    let data = this.internalData
    let ctx = this.context
    let w = ctx.width
    let h = this.chartHeight
    let drawH = h - 16
    let minNav = this.getMinNav()
    let range = this.getRange()
    let stepX = data.length > 1 ? (w - this.chartPadding * 2) / (data.length - 1) : 0
    let x = this.chartPadding + stepX * i
    let ratio = (data[i].unitNav - minNav) / range
    let y = 8 + drawH * (1 - ratio)
    return { x, y }
  }

  drawSmoothLineTo(endIdx: number): void {
    let data = this.internalData
    let ctx = this.context
    let n = Math.min(endIdx + 1, data.length)
    if (n < 2) return

    ctx.strokeStyle = '#007AFF'
    ctx.lineWidth = 2
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.beginPath()

    let p0 = this.getPointAtIndex(0)
    ctx.moveTo(p0.x, p0.y)

    for (let i = 1; i < n; i++) {
      let pPrev = this.getPointAtIndex(i - 1)
      let pCur = this.getPointAtIndex(i)
      let pNext = (i + 1 < data.length) ? this.getPointAtIndex(i + 1) : null

      let cp1x: number, cp1y: number, cp2x: number, cp2y: number

      if (i === 1) {
        cp1x = pPrev.x + (pCur.x - pPrev.x) * 0.25
        cp1y = pPrev.y + (pCur.y - pPrev.y) * 0.25
        cp2x = pCur.x - (pNext ? (pNext.x - pPrev.x) * 0.15 : (pCur.x - pPrev.x) * 0.25)
        cp2y = pCur.y - (pNext ? (pNext.y - pPrev.y) * 0.15 : (pCur.y - pPrev.y) * 0.25)
      } else if (i === n - 1) {
        let pPrev2 = this.getPointAtIndex(i - 2)
        cp1x = pPrev.x + (pCur.x - pPrev2.x) * 0.15
        cp1y = pPrev.y + (pCur.y - pPrev2.y) * 0.15
        cp2x = pCur.x - (pCur.x - pPrev.x) * 0.25
        cp2y = pCur.y - (pCur.y - pPrev.y) * 0.25
      } else {
        let pNext2 = this.getPointAtIndex(i + 2 < data.length ? i + 2 : i + 1)
        cp1x = pPrev.x + (pCur.x - (i - 2 >= 0 ? this.getPointAtIndex(i - 2).x : pPrev.x)) * 0.15
        cp1y = pPrev.y + (pCur.y - (i - 2 >= 0 ? this.getPointAtIndex(i - 2).y : pPrev.y)) * 0.15
        cp2x = pCur.x - (pNext2.x - pPrev.x) * 0.15
        cp2y = pCur.y - (pNext2.y - pPrev.y) * 0.15
      }

      ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, pCur.x, pCur.y)
    }
    ctx.stroke()
  }

  drawSmoothFillTo(endIdx: number): void {
    let data = this.internalData
    let ctx = this.context
    let n = Math.min(endIdx + 1, data.length)
    if (n < 2) return

    let bottomY = this.chartHeight
    ctx.beginPath()

    let p0 = this.getPointAtIndex(0)
    ctx.moveTo(p0.x, bottomY)
    ctx.lineTo(p0.x, p0.y)

    for (let i = 1; i < n; i++) {
      let pPrev = this.getPointAtIndex(i - 1)
      let pCur = this.getPointAtIndex(i)
      let pNext = (i + 1 < data.length) ? this.getPointAtIndex(i + 1) : null

      let cp1x: number, cp1y: number, cp2x: number, cp2y: number

      if (i === 1) {
        cp1x = pPrev.x + (pCur.x - pPrev.x) * 0.25
        cp1y = pPrev.y + (pCur.y - pPrev.y) * 0.25
        cp2x = pCur.x - (pNext ? (pNext.x - pPrev.x) * 0.15 : (pCur.x - pPrev.x) * 0.25)
        cp2y = pCur.y - (pNext ? (pNext.y - pPrev.y) * 0.15 : (pCur.y - pPrev.y) * 0.25)
      } else if (i === n - 1) {
        let pPrev2 = this.getPointAtIndex(i - 2)
        cp1x = pPrev.x + (pCur.x - pPrev2.x) * 0.15
        cp1y = pPrev.y + (pCur.y - pPrev2.y) * 0.15
        cp2x = pCur.x - (pCur.x - pPrev.x) * 0.25
        cp2y = pCur.y - (pCur.y - pPrev.y) * 0.25
      } else {
        let pNext2 = this.getPointAtIndex(i + 2 < data.length ? i + 2 : i + 1)
        cp1x = pPrev.x + (pCur.x - (i - 2 >= 0 ? this.getPointAtIndex(i - 2).x : pPrev.x)) * 0.15
        cp1y = pPrev.y + (pCur.y - (i - 2 >= 0 ? this.getPointAtIndex(i - 2).y : pPrev.y)) * 0.15
        cp2x = pCur.x - (pNext2.x - pPrev.x) * 0.15
        cp2y = pCur.y - (pNext2.y - pPrev.y) * 0.15
      }

      ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, pCur.x, pCur.y)
    }

    let lastP = this.getPointAtIndex(n - 1)
    ctx.lineTo(lastP.x, bottomY)
    ctx.closePath()

    let gradient = ctx.createLinearGradient(0, 0, 0, bottomY)
    gradient.addColorStop(0, 'rgba(0, 122, 255, 0.20)')
    gradient.addColorStop(1, 'rgba(0, 122, 255, 0.03)')
    ctx.fillStyle = gradient
    ctx.fill()
  }

  drawStaticParts(): void {
    let data = this.internalData
    let ctx = this.context
    let w = ctx.width
    let h = this.chartHeight
    let drawH = h - 16

    ctx.strokeStyle = '#F0F0F0'
    ctx.lineWidth = 1
    for (let i = 0; i <= 4; i++) {
      let y = 8 + (drawH / 4) * i
      ctx.beginPath()
      ctx.moveTo(this.chartPadding, y)
      ctx.lineTo(w - this.chartPadding, y)
      ctx.stroke()
    }

    ctx.fillStyle = '#007AFF'
    let dotInterval = Math.max(1, Math.floor(data.length / 8))
    for (let i = 0; i < data.length; i += dotInterval) {
      let p = this.getPointAtIndex(i)
      ctx.beginPath()
      ctx.arc(p.x, p.y, 3, 0, Math.PI * 2)
      ctx.fill()
    }

    let lastIdx = data.length - 1
    let lastP = this.getPointAtIndex(lastIdx)
    ctx.fillStyle = '#FFFFFF'
    ctx.strokeStyle = '#007AFF'
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.arc(lastP.x, lastP.y, 4, 0, Math.PI * 2)
    ctx.fill()
    ctx.stroke()
  }

  startAnimateDraw(): void {
    if (this.animTimerId !== -1) {
      clearInterval(this.animTimerId)
      this.animTimerId = -1
    }
    this.animStep = 0
    this.drawAtProgress(0)
    this.animTimerId = setInterval(() => {
      this.animStep++
      if (this.animStep >= this.animTotalSteps) {
        clearInterval(this.animTimerId)
        this.animTimerId = -1
        this.drawAtProgress(1)
      } else {
        this.drawAtProgress(this.animStep / this.animTotalSteps)
      }
    }, 16)
  }

  drawAtProgress(progress: number): void {
    let data = this.internalData
    if (data.length === 0) return
    let ctx = this.context
    let w = ctx.width
    ctx.clearRect(0, 0, w, this.chartHeight)
    this.drawStaticParts()
    let drawCount = Math.max(1, Math.floor(data.length * progress))
    if (drawCount > data.length) drawCount = data.length
    this.drawSmoothFillTo(drawCount - 1)
    this.drawSmoothLineTo(drawCount - 1)
  }

  drawChart(): void {
    this.drawAtProgress(1)
  }

  build() {
    Column() {
      if (this.internalData.length >= 1) {
        Row() {
          Text(this.getMaxNav().toFixed(4))
            .fontSize(10)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)

        Canvas(this.context)
          .width('100%')
          .height(this.chartHeight)
          .onReady(() => {
            this.isCanvasReady = true
            this.startAnimateDraw()
          })

        Row() {
          Text(this.getMinNav().toFixed(4))
            .fontSize(10)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)

        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.navData || [], (item: NavPoint) => {
              Column({ space: 2 }) {
                Text(item.date.substring(5))
                  .fontSize(10)
                  .fontColor(AppColors.TEXT_TERTIARY)
                Text(item.unitNav.toFixed(4))
                  .fontSize(10)
                  .fontColor(AppColors.TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Center)
            })
          }
          .padding({ top: 8, bottom: 4 })
        }
        .width('100%')
        .height(36)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

      } else {
        Text('数据不足，无法绘制折线图')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .height(this.chartHeight)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
  }
}
