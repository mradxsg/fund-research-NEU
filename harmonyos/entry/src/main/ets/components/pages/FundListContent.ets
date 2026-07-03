import { AppColors, AppFontSize, AppSpacing, AppLayout, AppResponsive } from '../../common/constants/AppConstants'
import { SearchBar } from '../common/SearchBar'
import { TagChip } from '../common/TagChip'
import { FundCard } from '../common/FundCard'
import { LoadingIndicator } from '../base/LoadingIndicator'
import { EmptyState } from '../base/EmptyState'
import { ErrorState } from '../base/ErrorState'
import { ToastUtil } from '../base/ToastUtil'
import { FundApi } from '../../services/api/FundApi'
import { FundInfo } from '../../common/types'
import { navReplaceTo } from '../../services/NavigationService'

const STATUS_BAR_HEIGHT: number = 44
const TOPBAR_TOTAL: number = 136
const BOTTOM_SPACER: number = 90
const RISK_LEVELS: string[] = ['全部', '低风险', '中低风险', '中风险', '中高风险', '高风险']

@Preview
@Component
export struct FundListContent {
  @State keyword: string = ''
  @State typeIndex: number = 0
  @State riskIndex: number = 0
  @State fundTypes: string[] = ['全部']
  @State fundList: FundInfo[] = []
  @State currentPage: number = 0
  @State totalPages: number = 1
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State hasError: boolean = false
  @State isFirstLoad: boolean = true

  aboutToAppear(): void {
    this.loadTypes()
    this.loadData(0, true)
  }

  async loadTypes(): Promise<void> {
    const types = await FundApi.getTypes()
    if (types != null && types.length > 0) {
      this.fundTypes = ['全部', ...types]
    }
  }

  navToFund(fund: FundInfo): void {
    navReplaceTo('fundDetail', fund.id)
  }

  getFundNav(fund: FundInfo): number {
    if (fund.unitNav != null) { return fund.unitNav }
    if (fund.latestNav != null) { return fund.latestNav }
    return 0
  }

  getFundReturn(fund: FundInfo): number {
    if (fund.dailyReturn != null) { return fund.dailyReturn }
    if (fund.latestDailyReturn != null) { return fund.latestDailyReturn }
    return 0
  }

  async loadData(page: number, firstLoad: boolean): Promise<void> {
    if (firstLoad) { this.isLoading = true }
    this.hasError = false

    const params: Record<string, string> = { 'page': '' + page }
    if (this.keyword.trim() !== '') { params['keyword'] = this.keyword.trim() }
    if (this.typeIndex > 0 && this.fundTypes[this.typeIndex] != null) {
      params['type'] = this.fundTypes[this.typeIndex]
    }
    if (this.riskIndex > 0) { params['riskLevel'] = RISK_LEVELS[this.riskIndex] }

    const result = await FundApi.list(params)
    if (result != null) {
      if (page === 0) {
        this.fundList = result.records
      } else {
        this.fundList = this.fundList.concat(result.records)
      }
      this.currentPage = page
      this.totalPages = result.pages > 0 ? result.pages : 1
    } else if (page === 0) {
      this.hasError = true
    } else {
      ToastUtil.error('加载更多失败')
    }

    this.isLoading = false
    this.isLoadingMore = false
    this.isFirstLoad = false
  }

  onSearch(val: string): void {
    this.keyword = val
    this.isFirstLoad = true
    this.loadData(0, true)
  }

  onTypeSelect(index: number): void {
    const nextIndex: number = index < 0 ? 0 : index
    if (nextIndex === this.typeIndex) { return }
    this.typeIndex = nextIndex
    this.isFirstLoad = true
    this.loadData(0, true)
  }

  onRiskSelect(index: number): void {
    const nextIndex: number = index < 0 ? 0 : index
    if (nextIndex === this.riskIndex) { return }
    this.riskIndex = nextIndex
    this.isFirstLoad = true
    this.loadData(0, true)
  }

  onLoadMore(): void {
    if (this.isLoadingMore || this.isLoading) { return }
    const nextPage: number = this.currentPage + 1
    if (nextPage >= this.totalPages) { return }
    this.isLoadingMore = true
    this.loadData(nextPage, false)
  }

  onRetry(): void {
    this.isFirstLoad = true
    this.loadData(0, true)
  }

  clearFilters(): void {
    this.keyword = ''
    this.typeIndex = 0
    this.riskIndex = 0
    this.loadData(0, true)
  }

  @Builder
  FilterRow() {
    Column({ space: AppSpacing.SM }) {
      // 类型筛选行（可横向滚动）
      Scroll() {
        Row({ space: AppSpacing.SM }) {
          ForEach(this.fundTypes, (type: string, idx: number) => {
            TagChip({
              label: type,
              selected: idx === this.typeIndex,
              mode: 'fill',
              onChipClick: (): void => { this.onTypeSelect(idx) }
            })
          }, (type: string, idx: number) => `fund_type_${idx}`)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: AppSpacing.LG, right: AppSpacing.LG })

      // 风险等级筛选行（可横向滚动）
      Scroll() {
        Row({ space: AppSpacing.SM }) {
          ForEach(RISK_LEVELS, (level: string, idx: number) => {
            TagChip({
              label: level,
              selected: idx === this.riskIndex,
              mode: 'fill',
              onChipClick: (): void => { this.onRiskSelect(idx) }
            })
          }, (level: string, idx: number) => `risk_${idx}`)

          // 有任一筛选激活时显示清除按钮
          if (this.typeIndex > 0 || this.riskIndex > 0 || this.keyword.trim() !== '') {
            Text('清除')
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.ERROR)
              .fontWeight(FontWeight.Medium)
              .margin({ left: AppSpacing.XS })
              .onClick((): void => { this.clearFilters() })
          }
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
    }
    .width('100%')
    .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
  }

  @Builder
  ListBody() {
    if (this.isFirstLoad || this.isLoading) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6).width('100%')
        LoadingIndicator({ mode: 'skeleton', skeletonCount: 4 }).layoutWeight(1)
      }.width('100%').height('100%')
    } else if (this.hasError && this.fundList.length === 0) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6).width('100%')
        ErrorState({
          errTitle: '加载失败',
          errDesc: '无法获取基金列表，请检查网络连接',
          retryLabel: '重试',
          onRetry: (): void => { this.onRetry() }
        }).layoutWeight(1)
      }.width('100%').height('100%')
    } else if (this.fundList.length === 0) {
      Scroll() {
        Column({ space: AppSpacing.SM }) {
          Column().height(TOPBAR_TOTAL + 6).width('100%')

          // 筛选行保留，用户可以继续调整
          this.FilterRow()

          EmptyState({
            emptyTitle: '暂无基金数据',
            emptyDesc: this.keyword.trim() !== '' ? '没有匹配当前条件的基金' : '请稍后再试',
            actionLabel: this.keyword.trim() !== '' || this.typeIndex > 0 || this.riskIndex > 0 ? '清除筛选' : '',
            onAction: (): void => { this.clearFilters() }
          })
            .padding({ top: 48 })

          Column().height(BOTTOM_SPACER)
        }.width('100%').padding({ left: AppSpacing.LG, right: AppSpacing.LG, top: AppSpacing.SM })
      }.layoutWeight(1).scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
    } else {
      Scroll() {
        Column({ space: AppSpacing.SM }) {
          Column().height(TOPBAR_TOTAL + 6).width('100%')

          // 筛选行：类型 + 风险等级
          this.FilterRow()

          ForEach(this.fundList, (fund: FundInfo) => {
            FundCard({
              fundCode: fund.code,
              fundName: fund.name,
              fundType: fund.type,
              riskLevel: fund.riskLevel != null ? fund.riskLevel : '',
              latestNav: this.getFundNav(fund),
              dailyReturn: this.getFundReturn(fund),
              showMarketData: true,
              onCardClick: (): void => { this.navToFund(fund) }
            })
          }, (fund: FundInfo) => fund.id.toString())

          if (this.isLoadingMore) {
            LoadingIndicator({ mode: 'spinner', loadText: '加载更多...' }).height(56)
          } else if (this.currentPage >= this.totalPages - 1) {
            Text('— 已加载全部 —')
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
              .width('100%').textAlign(TextAlign.Center)
              .padding({ top: AppSpacing.SM, bottom: AppSpacing.MD })
          }

          Column().height(BOTTOM_SPACER)
        }.width('100%').padding({ left: AppSpacing.LG, right: AppSpacing.LG, top: AppSpacing.SM })
      }.layoutWeight(1).scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring).onReachEnd(() => { this.onLoadMore() })
    }
  }

  build() {
    Stack() {
      // 内容层
      this.ListBody()

      // topBar 悬浮层
      Stack() {
        Stack().width('100%').height('100%')
          .backgroundColor(AppColors.TOPBAR_BG).blur(AppLayout.TOPBAR_BLUR)

        Column() {
          Row().height(STATUS_BAR_HEIGHT).width('100%')
          Column() {
            Column({ space: AppSpacing.SM }) {
              Text('基金研究')
                .fontSize(AppFontSize.TITLE).fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold).width('100%')
              SearchBar({
                placeholder: '搜索基金代码或名称',
                initValue: this.keyword,
                onChange: (val: string): void => { this.keyword = val },
                onSearch: (val: string): void => { this.onSearch(val) }
              })
            }
            .width('100%')
            .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ left: AppSpacing.LG, right: AppSpacing.LG, top: AppSpacing.SM, bottom: AppSpacing.SM })
        }

        Row().width('100%').height(1).backgroundColor('rgba(0,0,0,0.06)').position({ bottom: 0 })
      }.width('100%').height(TOPBAR_TOTAL).position({ top: 0 })
    }.width('100%').height('100%')
  }
}
