import { AppColors, AppFontSize, AppSpacing, AppLayout, AppResponsive } from '../../common/constants/AppConstants'
import { SearchBar } from '../common/SearchBar'
import { ManagerCard } from '../common/ManagerCard'
import { LoadingIndicator } from '../base/LoadingIndicator'
import { EmptyState } from '../base/EmptyState'
import { ErrorState } from '../base/ErrorState'
import { ToastUtil } from '../base/ToastUtil'
import { ManagerApi } from '../../services/api/ManagerApi'
import { ManagerInfo } from '../../common/types'
import { navReplaceTo } from '../../services/NavigationService'

const STATUS_BAR_HEIGHT: number = 44
const TOPBAR_TOTAL: number = 136
const BOTTOM_SPACER: number = 90

@Preview
@Component
export struct ManagerListContent {
  @State keyword: string = ''
  @State managerList: ManagerInfo[] = []
  @State currentPage: number = 0
  @State totalPages: number = 1
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State hasError: boolean = false
  @State isFirstLoad: boolean = true

  aboutToAppear(): void {
    this.loadData(0, true)
  }

  navToManager(manager: ManagerInfo): void {
    navReplaceTo('managerDetail', manager.id)
  }

  async loadData(page: number, firstLoad: boolean): Promise<void> {
    if (firstLoad) { this.isLoading = true }
    this.hasError = false

    const params: Record<string, string> = { 'page': '' + page }
    if (this.keyword.trim() !== '') { params['keyword'] = this.keyword.trim() }

    const result = await ManagerApi.list(params)
    if (result != null) {
      if (page === 0) {
        this.managerList = result.records
      } else {
        this.managerList = this.managerList.concat(result.records)
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

  onLoadMore(): void {
    if (this.isLoadingMore || this.isLoading || this.currentPage >= this.totalPages - 1) { return }
    this.isLoadingMore = true
    this.loadData(this.currentPage + 1, false)
  }

  onRetry(): void {
    this.isFirstLoad = true
    this.loadData(0, true)
  }

  @Builder
  ListBody() {
    if (this.isFirstLoad || this.isLoading) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6).width('100%')
        LoadingIndicator({ mode: 'skeleton', skeletonCount: 4 }).layoutWeight(1)
      }.width('100%').height('100%')
    } else if (this.hasError && this.managerList.length === 0) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6).width('100%')
        ErrorState({
          errTitle: '加载失败',
          errDesc: '无法获取基金经理数据，请检查后端服务地址',
          retryLabel: '重试',
          onRetry: (): void => { this.onRetry() }
        }).layoutWeight(1)
      }.width('100%').height('100%')
    } else if (this.managerList.length === 0) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6).width('100%')
        EmptyState({
          emptyTitle: '未找到基金经理',
          emptyDesc: this.keyword.trim() !== '' ? '没有匹配当前关键词的经理' : '暂无经理数据',
          actionLabel: this.keyword.trim() !== '' ? '清除搜索' : '',
          onAction: (): void => {
            this.keyword = ''
            this.loadData(0, true)
          }
        }).layoutWeight(1)
      }.width('100%').height('100%')
    } else {
      Scroll() {
        Column({ space: AppSpacing.SM }) {
          Column().height(TOPBAR_TOTAL + 6).width('100%')

          ForEach(this.managerList, (manager: ManagerInfo) => {
            ManagerCard({
              managerName: manager.name,
              experienceYears: manager.experienceYears,
              fundCount: manager.fundCount != null ? manager.fundCount : 0,
              onCardClick: (): void => { this.navToManager(manager) }
            })
          }, (manager: ManagerInfo) => manager.id.toString())

          if (this.isLoadingMore) {
            LoadingIndicator({ mode: 'spinner', loadText: '加载更多...' }).height(56)
          } else if (this.currentPage >= this.totalPages - 1) {
            Text('已加载全部 ' + this.managerList.length + ' 位经理')
              .fontSize(AppFontSize.SMALL).fontColor(AppColors.TEXT_TERTIARY)
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
              Text('基金经理')
                .fontSize(AppFontSize.TITLE).fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold).width('100%')
              SearchBar({
                placeholder: '搜索基金经理',
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
