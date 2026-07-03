import { AppColors, AppSpacing, AppFontSize, AppRadius } from '../../common/constants/AppConstants'
import { GenericPage } from '../common/GenericPage'
import { ManagerCard } from '../common/ManagerCard'
import { FundCard } from '../common/FundCard'
import { LoadingIndicator } from '../base/LoadingIndicator'
import { ErrorState } from '../base/ErrorState'
import { EmptyState } from '../base/EmptyState'
import { ToastUtil } from '../base/ToastUtil'
import { ManagerApi } from '../../services/api/ManagerApi'
import { ManagerInfo, FundInfo } from '../../common/types'
import { navPushTo } from '../../services/NavigationService'

@Preview
@Component
export struct ManagerDetailPage {
  @Watch('onManagerIdChange')
  @Prop managerId: number = 0
  @State manager: ManagerInfo | null = null
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

  onManagerIdChange(): void {
    if (this.managerId > 0) {
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
    const managerResult = await ManagerApi.detail(this.managerId)
    const fundResult = await ManagerApi.funds(this.managerId, { 'page': '0' })
    if (managerResult != null) {
      this.manager = managerResult
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
    const result = await ManagerApi.funds(this.managerId, { 'page': '' + nextPage })
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
      // 顶部直接展示经理详细信息，无箭头，无点击导航
      Stack() {
        Column({ space: AppSpacing.SM }) {
          ManagerCard({
            managerName: this.manager!.name,
            experienceYears: this.manager!.experienceYears,
            fundCount: this.manager!.fundCount != null ? this.manager!.fundCount : this.fundList.length,
            showArrow: false,
            onCardClick: (): void => {}
          })

          if (this.manager!.companyName != null && this.manager!.companyName !== '') {
            Row() {
              Text('所属公司：')
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.TEXT_TERTIARY)
              Text(this.manager!.companyName)
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.PRIMARY)
                .fontWeight(FontWeight.Medium)
              Text('>')
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.TEXT_TERTIARY)
                .margin({ left: 4 })
            }
            .width('100%')
            .padding({ left: AppSpacing.LG, right: AppSpacing.LG, bottom: AppSpacing.MD })
            .onClick(() => {
              // 跳转到公司详情页（需要公司ID，目前经理信息中不包含公司ID，暂时只做UI展示）
              // 如有需要可扩展后端返回 manager 的 companyId
            })
          }
        }
        .width('100%')
        .backgroundColor(AppColors.WHITE)
        .borderRadius(AppRadius.CARD)
      }
      .width('100%')

      Text('管理基金')
        .fontSize(AppFontSize.BODY_LARGE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 4 })

      if (this.fundList.length === 0) {
        EmptyState({
          emptyTitle: '暂无基金数据',
          emptyDesc: '该经理管理的基金暂未返回'
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
      pageTitle: this.manager != null ? this.manager.name : '基金经理',
      showBack: true,
      onBack: this.onBack
    }) {
      if (this.isLoading) {
        LoadingIndicator({ mode: 'spinner', loadText: '加载基金经理...' })
          .height(360)
      } else if (this.hasError || this.manager == null) {
        ErrorState({
          errTitle: '加载失败',
          errDesc: '无法获取基金经理详情',
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
