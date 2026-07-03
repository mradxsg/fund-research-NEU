import { AppColors, AppSpacing, AppRadius, AppFontSize, AppButtonHeight } from '../../common/constants/AppConstants'
import { GenericPage } from '../common/GenericPage'
import { FundBasicInfo } from '../common/FundBasicInfo'
import { NavChart } from '../common/NavChart'
import { HoldingSectorChart } from '../common/HoldingSectorChart'
import { HoldingStockList } from '../common/HoldingStockList'
import { FundAnnouncementList } from '../common/FundAnnouncementList'
import { LoadingIndicator } from '../base/LoadingIndicator'
import { ErrorState } from '../base/ErrorState'
import { AppTextInput } from '../base/AppTextInput'
import { AppButton } from '../base/AppButton'
import { AppDialog } from '../base/AppDialog'
import { ToastUtil } from '../base/ToastUtil'
import { FundApi } from '../../services/api/FundApi'
import { PortfolioApi } from '../../services/api/PortfolioApi'
import { FundDetailResult, NavPoint, Portfolio } from '../../common/types'
import { navPushTo } from '../../services/NavigationService'

@Preview
@Component
export struct FundDetailPage {
  @StorageLink('user_logged') userLogged: boolean = false
  @StorageLink('user_id') userId: number = 0
  @StorageLink('home_last_page') lastPageIndex: number = 0
  @State detail: FundDetailResult | null = null
  @State isLoading: boolean = true
  @State hasError: boolean = false
  @State periodIndex: number = 0
  @State showCreate: boolean = false
  @State portfolioName: string = ''
  @State isCreating: boolean = false
  @State userPortfolios: Portfolio[] = []
  @State showAddMenu: boolean = true
  @State addedPortfolioIds: number[] = []
  @State showRemoveDialog: boolean = false
  @State removePortfolioId: number = 0
  @State removePortfolioName: string = ''
  onBack: () => void = (): void => {}

  aboutToAppear(): void {
    this.loadDetail()
  }

  @Watch('onFundIdChange')
  @Prop fundId: number = 0

  onFundIdChange(): void {
    if (this.fundId > 0) {
      this.loadDetail()
    }
  }

  /** 导航到指定页面 - 使用 NavigationService 的 navPushTo，保证栈管理和动画方向正确 */
  navigateTo(page: string, param: number): void {
    navPushTo(page, param)
  }

  async loadDetail(): Promise<void> {
    this.isLoading = true
    this.hasError = false
    const result = await FundApi.detail(this.fundId)
    if (result != null) {
      this.detail = result
      console.info('FUND_DEBUG', '加载完成: managerId=' + JSON.stringify(result.managerId) + ', companyId=' + JSON.stringify(result.companyId))
      console.info('FUND_DEBUG', 'managerName=' + result.managerName + ', companyName=' + result.companyName)
      // 默认展开「添加到组合」时，同时加载用户组合数据
      if (this.showAddMenu && this.userLogged) {
        this.refreshAddedIds()
      }
    } else {
      this.hasError = true
    }
    this.isLoading = false
  }

  getNavData(): NavPoint[] {
    const d = this.detail
    if (d == null || d.navSeries == null) {
      return []
    }
    const navs: NavPoint[] = d.navSeries
    if (this.periodIndex === 0) {
      return navs.slice(Math.max(0, navs.length - 22), navs.length)
    }
    if (this.periodIndex === 1) {
      return navs.slice(Math.max(0, navs.length - 66), navs.length)
    }
    if (this.periodIndex === 2) {
      return navs.slice(Math.max(0, navs.length - 132), navs.length)
    }
    return navs
  }

  async createPortfolioWithCurrentFund(): Promise<void> {
    const d = this.detail
    if (d == null) {
      return
    }
    if (!this.userLogged || this.userId <= 0) {
      ToastUtil.warning('请先登录')
      navPushTo('login', 0)
      return
    }
    if (this.portfolioName.trim() === '') {
      ToastUtil.warning('请输入组合名称')
      return
    }

    this.isCreating = true
    const created = await PortfolioApi.create(this.userId, this.portfolioName.trim(), [d.id])
    this.isCreating = false
    if (created != null) {
      ToastUtil.success('已创建自选组合')
      this.showCreate = false
      this.portfolioName = ''
      this.lastPageIndex = 3
    } else {
      ToastUtil.error('创建失败，请检查后端服务')
    }
  }

  async refreshAddedIds(): Promise<void> {
    const portfolios = await PortfolioApi.list(this.userId)
    if (portfolios == null) {
      return
    }
    this.userPortfolios = portfolios
    const addedIds: number[] = []
    const fundId = this.detail?.id
    if (fundId != null) {
      for (const p of portfolios) {
        if (p.funds != null) {
          for (let j: number = 0; j < p.funds.length; j++) {
            if (p.funds[j].fundId === fundId) {
              addedIds.push(p.id)
              break
            }
          }
        }
      }
    }
    this.addedPortfolioIds = addedIds
  }

  async addToPortfolio(portfolioId: number): Promise<void> {
    const d = this.detail
    if (d == null) {
      return
    }
    ToastUtil.info('添加中...')
    const result = await PortfolioApi.addFunds(portfolioId, [d.id])
    if (result != null) {
      ToastUtil.success('已添加到组合')
      this.addedPortfolioIds.push(portfolioId)
    } else {
      ToastUtil.error('添加失败')
    }
  }

  confirmRemoveFromPortfolio(portfolioId: number, portfolioName: string): void {
    this.removePortfolioId = portfolioId
    this.removePortfolioName = portfolioName
    this.showRemoveDialog = true
  }

  async removeFromPortfolio(portfolioId: number): Promise<void> {
    const d = this.detail
    if (d == null) { return }
    const ok = await PortfolioApi.removeFund(portfolioId, d.id)
    if (ok) {
      ToastUtil.success('已从组合移除')
      const idx = this.addedPortfolioIds.indexOf(portfolioId)
      if (idx >= 0) {
        this.addedPortfolioIds.splice(idx, 1)
      }
    } else {
      ToastUtil.error('移除失败')
    }
  }

  @Builder
  line() {
    Row()
      .width('100%')
      .height(0.5)
      .backgroundColor(AppColors.DIVIDER)
  }

  @Builder
  DetailContent() {
    Column({ space: AppSpacing.MD }) {
      FundBasicInfo({
        fundCode: this.detail!.code,
        fundName: this.detail!.name,
        fundType: this.detail!.type,
        fundScale: this.detail!.scale,
        establishDate: this.detail!.establishDate,
        riskLevel: this.detail!.riskLevel,
        benchmark: this.detail!.benchmark
      })

      Column({ space: 0 }) {
        // 标签展示
        if (this.detail!.tags != null && this.detail!.tags.length > 0) {
          Row({ space: AppSpacing.XS }) {
            ForEach(this.detail!.tags, (tag: string) => {
              Text(tag)
                .fontSize(AppFontSize.TINY)
                .fontColor(AppColors.PRIMARY)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor(AppColors.PRIMARY_LIGHT)
                .borderRadius(4)
            })
          }.width('100%').padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
          this.line()
        }

        // 基金经理（文本行，点击跳转经理详情）
        Row({ space: AppSpacing.SM }) {
          Text('基金经理')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
          Text(this.detail!.managerName != null && this.detail!.managerName !== '' ? this.detail!.managerName : '--')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
            .textAlign(TextAlign.End)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          if (this.detail!.managerId != null && this.detail!.managerId > 0) {
            Text('>')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
        }
        .width('100%')
        .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
        .onClick((): void => {
          const d = this.detail!
          console.info('FUND_DETAIL_DEBUG', '点击基金经理managerId=' + JSON.stringify(d.managerId))
          this.navigateTo('managerDetail', d.managerId != null ? d.managerId : 1)
        })

        this.line()

        // 基金公司（文本行，点击跳转公司详情）
        Row({ space: AppSpacing.SM }) {
          Text('基金公司')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
          Text(this.detail!.companyName != null && this.detail!.companyName !== '' ? this.detail!.companyName : '--')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
            .textAlign(TextAlign.End)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          if (this.detail!.companyId != null && this.detail!.companyId > 0) {
            Text('>')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
        }
        .width('100%')
        .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
        .onClick((): void => {
          const d = this.detail!
          console.info('FUND_DETAIL_DEBUG', '点击基金公司companyId=' + JSON.stringify(d.companyId))
          this.navigateTo('companyDetail', d.companyId != null ? d.companyId : 1)
        })
      }
      .width('100%')
      .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
      .backgroundColor(AppColors.WHITE)
      .borderRadius(AppRadius.CARD)

      NavChart({
        navData: this.getNavData(),
        selectedPeriod: this.periodIndex,
        onPeriodChange: (i: number): void => { this.periodIndex = i }
      })

      HoldingSectorChart({ sectors: this.detail!.sectors })

      HoldingStockList({ stocks: this.detail!.topHoldings })

      Column({ space: AppSpacing.SM }) {
        Text('业绩归因')
          .fontSize(AppFontSize.BODY_LARGE)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text(this.detail!.attributionText != null && this.detail!.attributionText !== '' ?
          this.detail!.attributionText : '暂无业绩归因说明')
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
          .lineHeight(22)
          .width('100%')
      }
      .width('100%')
      .padding(AppSpacing.LG)
      .backgroundColor(AppColors.WHITE)
      .borderRadius(AppRadius.CARD)

      Column({ space: AppSpacing.MD }) {
        Row() {
          Text('添加到组合')
            .fontSize(AppFontSize.BODY_LARGE)
            .fontColor(AppColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)

          if (this.userLogged) {
            Text(this.showAddMenu ? '收起' : '添加到...')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.PRIMARY)
              .onClick(() => {
                this.showAddMenu = !this.showAddMenu
                if (this.showAddMenu) {
                  this.refreshAddedIds()
                }
              })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        if (!this.userLogged) {
          Text('请先登录后再管理自选组合')
            .fontSize(AppFontSize.SMALL)
            .fontColor(AppColors.TEXT_TERTIARY)
            .width('100%')
        } else if (this.showAddMenu) {
          if (this.userPortfolios.length === 0) {
            Text('还没有组合，请先创建一个')
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
              .width('100%')

            AppTextInput({
              phText: '组合名称，例如：稳健观察',
              initValue: this.portfolioName,
              onChange: (v: string): void => { this.portfolioName = v }
            })

            AppButton({
              btnLabel: this.isCreating ? '创建中...' : '创建组合并添加',
              btnHeight: AppButtonHeight.MEDIUM,
              btnDisabled: this.isCreating,
              onClickAction: (): void => { this.createPortfolioWithCurrentFund() }
            })
          } else {
            ForEach(this.userPortfolios, (portfolio: Portfolio) => {
              Row({ space: AppSpacing.MD }) {
                Column({ space: 2 }) {
                  Text(portfolio.name)
                    .fontSize(AppFontSize.BODY)
                    .fontColor(AppColors.TEXT_PRIMARY)
                    .fontWeight(FontWeight.Medium)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                if (this.addedPortfolioIds.indexOf(portfolio.id) >= 0) {
                  Text('删除')
                    .fontSize(AppFontSize.BODY)
                    .fontColor(AppColors.ERROR)
                    .fontWeight(FontWeight.Medium)
                    .onClick(() => {
                      this.confirmRemoveFromPortfolio(portfolio.id, portfolio.name)
                    })
                } else {
                  Text('添加')
                    .fontSize(AppFontSize.BODY)
                    .fontColor(AppColors.PRIMARY)
                    .fontWeight(FontWeight.Medium)
                    .onClick(() => { this.addToPortfolio(portfolio.id) })
                }
              }
              .width('100%')
              .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
            }, (portfolio: Portfolio) => portfolio.id.toString())

            Row()
              .width('100%')
              .height(0.5)
              .backgroundColor(AppColors.DIVIDER)

            Text('创建新组合')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.PRIMARY)
              .padding({ top: AppSpacing.SM })
              .onClick(() => {
                this.showCreate = true
                this.portfolioName = ''
              })

            if (this.showCreate) {
              AppTextInput({
                phText: '组合名称',
                initValue: this.portfolioName,
                onChange: (v: string): void => { this.portfolioName = v }
              })

              AppButton({
                btnLabel: this.isCreating ? '创建中...' : '创建并添加',
                btnHeight: AppButtonHeight.MEDIUM,
                btnDisabled: this.isCreating,
                onClickAction: (): void => { this.createPortfolioWithCurrentFund() }
              })
            }
          }
        } else {
          Text(this.userPortfolios.length > 0 ? '点击「添加到...」选择组合' : '还没有组合，点击「添加到...」创建')
            .fontSize(AppFontSize.SMALL)
            .fontColor(AppColors.TEXT_TERTIARY)
            .width('100%')
        }
      }
      .width('100%')
      .padding(AppSpacing.LG)
      .backgroundColor(AppColors.WHITE)
      .borderRadius(AppRadius.CARD)

      FundAnnouncementList({
        announcements: this.detail!.announcements,
        onNavigateToAnnouncement: (id: number): void => {
          console.info('FUND_DETAIL_DEBUG', '点击公告按钮，id=' + id)
          // 在公告列表中查找对应的完整公告数据
          const annList = this.detail!.announcements
          for (let i = 0; i < annList.length; i++) {
            if (annList[i].id === id) {
              // 将公告字段分别存入AppStorage，避免JSON解析问题
              AppStorage.set('ann_title', annList[i].title)
              AppStorage.set('ann_date', annList[i].publishDate)
              AppStorage.set('ann_content', annList[i].content != null ? annList[i].content : '')
              console.info('FUND_DETAIL_DEBUG', '已存入公告: title=' + annList[i].title)
              break
            }
          }
          this.navigateTo('announcementDetail', id)
        }
      })

      Column().height(24)
    }
    .width('100%')
    .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
  }

  build() {
    Stack() {
      GenericPage({
        pageTitle: this.detail != null ? this.detail.name : '基金详情',
        showBack: true,
        onBack: this.onBack
      }) {
        if (this.isLoading) {
          LoadingIndicator({ mode: 'spinner', loadText: '加载基金详情...' })
            .height(360)
        } else if (this.hasError || this.detail == null) {
          ErrorState({
            errTitle: '加载失败',
            errDesc: '无法获取基金详情，请检查后端服务',
            retryLabel: '重试',
            onRetry: (): void => { this.loadDetail() }
          })
            .height(360)
        } else {
          this.DetailContent()
        }
      }

      AppDialog({
        showDialog: this.showRemoveDialog,
        dialogTitle: '确认移除',
        dialogContent: '确定将当前基金从「' + this.removePortfolioName + '」中移除吗？',
        confirmText: '移除',
        onConfirm: (): void => {
          this.removeFromPortfolio(this.removePortfolioId)
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
