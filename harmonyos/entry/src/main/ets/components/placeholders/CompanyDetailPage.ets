import { AppColors, AppSpacing, AppFontSize, AppRadius } from '../../common/constants/AppConstants'
import { GenericPage } from '../common/GenericPage'
import { FundCard } from '../common/FundCard'
import { LoadingIndicator } from '../base/LoadingIndicator'
import { ErrorState } from '../base/ErrorState'
import { EmptyState } from '../base/EmptyState'
import { ToastUtil } from '../base/ToastUtil'
import { CompanyApi } from '../../services/api/CompanyApi'
import { CompanyInfo, FundInfo } from '../../common/types'
import { navPushTo } from '../../services/NavigationService'

@Preview
@Component
export struct CompanyDetailPage {
  @Watch('onCompanyIdChange')
  @Prop companyId: number = 0
  @State company: CompanyInfo | null = null
  @State fundList: FundInfo[] = []
  @State currentPage: number = 0
  @State totalPages: number = 1
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false
  @State hasError: boolean = false
  onBack: () => void = (): void => {}

  aboutToAppear(): void {
    this.loadData()
  }

  onCompanyIdChange(): void {
    if (this.companyId > 0) {
      this.loadData()
    }
  }

  getFundNav(fund: FundInfo): number {
    if (fund.unitNav != null) {
      return fund.unitNav
    }
    if (fund.latestNav != null) {
      return fund.latestNav
    }
    return 0
  }

  getFundReturn(fund: FundInfo): number {
    if (fund.dailyReturn != null) {
      return fund.dailyReturn
    }
    if (fund.latestDailyReturn != null) {
      return fund.latestDailyReturn
    }
    return 0
  }

  navToFund(fund: FundInfo): void {
    navPushTo('fundDetail', fund.id)
  }

  async loadData(): Promise<void> {
    this.isLoading = true
    this.hasError = false
    const companyResult = await CompanyApi.detail(this.companyId)
    const fundResult = await CompanyApi.funds(this.companyId, { 'page': '0' })
    if (companyResult != null) {
      this.company = companyResult
      if (fundResult != null) {
        this.fundList = fundResult.records
        this.totalPages = fundResult.pages > 0 ? fundResult.pages : 1
        this.currentPage = 0
      }
    } else {
      this.hasError = true
    }
    this.isLoading = false
  }

  async loadMore(): Promise<void> {
    if (this.isLoadingMore || this.currentPage >= this.totalPages - 1) {
      return
    }
    this.isLoadingMore = true
    const nextPage = this.currentPage + 1
    const result = await CompanyApi.funds(this.companyId, { 'page': '' + nextPage })
    if (result != null) {
      this.fundList = this.fundList.concat(result.records)
      this.currentPage = nextPage
      this.totalPages = result.pages > 0 ? result.pages : 1
    } else {
      ToastUtil.error('加载更多失败')
    }
    this.isLoadingMore = false
  }

  @Builder
  DetailContent() {
    Column({ space: AppSpacing.MD }) {
      Column({ space: AppSpacing.SM }) {
        Text(this.company!.name)
          .fontSize(AppFontSize.HEADING)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        if (this.company!.description != null && this.company!.description !== '') {
          Text(this.company!.description)
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .lineHeight(22)
            .width('100%')
        }

        Text('管理 ' + (this.company!.fundCount != null ? this.company!.fundCount : this.fundList.length) + ' 只基金')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .width('100%')
      }
      .width('100%')
      .padding(AppSpacing.LG)
      .backgroundColor(AppColors.WHITE)
      .borderRadius(AppRadius.CARD)

      Text('旗下基金')
        .fontSize(AppFontSize.BODY_LARGE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 4 })

      if (this.fundList.length === 0) {
        EmptyState({
          emptyTitle: '暂无基金数据',
          emptyDesc: '该公司旗下基金暂未返回'
        })
          .height(180)
      } else {
        Column({ space: AppSpacing.SM }) {
          ForEach(this.fundList, (fund: FundInfo) => {
            FundCard({
              fundCode: fund.code,
              fundName: fund.name,
              fundType: fund.type,
              riskLevel: fund.riskLevel != null ? fund.riskLevel : '',
              latestNav: this.getFundNav(fund),
              dailyReturn: this.getFundReturn(fund),
              onCardClick: (): void => { this.navToFund(fund) }
            })
          }, (fund: FundInfo) => fund.id.toString())

          if (this.isLoadingMore) {
            LoadingIndicator({ mode: 'spinner', loadText: '加载更多...' })
              .height(56)
          } else if (this.currentPage < this.totalPages - 1) {
            Text('上拉加载更多')
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: AppSpacing.SM, bottom: AppSpacing.MD })
          }
        }
        .width('100%')
      }

      Column().height(24)
    }
    .width('100%')
    .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
  }

  build() {
    GenericPage({
      pageTitle: this.company != null ? this.company.name : '公司详情',
      showBack: true,
      onBack: this.onBack
    }) {
      if (this.isLoading) {
        LoadingIndicator({ mode: 'spinner', loadText: '加载公司详情...' })
          .height(360)
      } else if (this.hasError || this.company == null) {
        ErrorState({
          errTitle: '加载失败',
          errDesc: '无法获取公司详情',
          retryLabel: '重试',
          onRetry: (): void => { this.loadData() }
        })
          .height(360)
      } else {
        this.DetailContent()
      }
    }
  }
}
