import { AppColors, AppFontSize, AppSpacing, AppRadius, AppLayout, AppButtonHeight, AppResponsive } from '../../common/constants/AppConstants'
import { PortfolioCard } from '../common/PortfolioCard'
import { LoadingIndicator } from '../base/LoadingIndicator'
import { EmptyState } from '../base/EmptyState'
import { ErrorState } from '../base/ErrorState'
import { AppDialog } from '../base/AppDialog'
import { AppButton } from '../base/AppButton'
import { ToastUtil } from '../base/ToastUtil'
import { PortfolioApi } from '../../services/api/PortfolioApi'
import { Portfolio } from '../../common/types'
import { navReplaceTo } from '../../services/NavigationService'
import { resolveUserId } from '../../services/PortfolioStats'

const STATUS_BAR_HEIGHT: number = 44
const TOPBAR_TOTAL: number = 112
const BOTTOM_SPACER: number = 90

@Preview
@Component
export struct PortfolioListContent {
  @Watch('onUserSessionChange') @StorageLink('user_logged') userLogged: boolean = false
  @Watch('onUserSessionChange') @StorageLink('user_id') userId: number = 0
  @StorageLink('user_name') userName: string = ''
  @StorageLink('home_last_page') lastPageIndex: number = 0

  @State portfolioList: Portfolio[] = []
  @State isLoading: boolean = false
  @State hasError: boolean = false

  // 删除对话框
  @State showDeleteDialog: boolean = false
  @State deleteTarget: Portfolio | null = null

  // 创建对话框
  @State showCreateDialog: boolean = false
  @State createName: string = ''

  // 重命名对话框
  @State showRenameDialog: boolean = false
  @State renameTarget: Portfolio | null = null
  @State renameName: string = ''

  aboutToAppear(): void {
    if (this.userLogged) {
      this.loadPortfolios()
    }
  }

  onUserSessionChange(): void {
    if (this.userLogged) {
      this.loadPortfolios()
    } else {
      this.portfolioList = []
    }
  }

  async loadPortfolios(): Promise<void> {
    if (!this.userLogged) {
      this.portfolioList = []
      return
    }

    const uid: number = resolveUserId(this.userId)
    if (uid <= 0) {
      this.portfolioList = []
      return
    }

    this.isLoading = true
    this.hasError = false
    const result = await PortfolioApi.list(uid)
    if (result != null) {
      this.portfolioList = result
    } else {
      this.hasError = true
    }
    this.isLoading = false
  }

  navToPortfolio(portfolio: Portfolio): void {
    navReplaceTo('portfolioDetail', portfolio.id)
  }

  showDeleteDialogFor(portfolio: Portfolio): void {
    this.deleteTarget = portfolio
    this.showDeleteDialog = true
  }

  async doDelete(): Promise<void> {
    if (this.deleteTarget == null) {
      return
    }
    await PortfolioApi.delete(this.deleteTarget.id)
    ToastUtil.success('已删除')
    this.deleteTarget = null
    this.loadPortfolios()
  }

  onOpenCreate(): void {
    this.createName = ''
    this.showCreateDialog = true
  }

  async doCreate(): Promise<void> {
    if (this.createName.trim() === '') {
      ToastUtil.error('请输入组合名称')
      return
    }
    const result = await PortfolioApi.create(this.userId, this.createName.trim(), [])
    if (result != null) {
      ToastUtil.success('组合创建成功')
      this.createName = ''
      this.showCreateDialog = false
      this.loadPortfolios()
    } else {
      ToastUtil.error('创建失败')
    }
  }

  onOpenRename(portfolio: Portfolio): void {
    this.renameTarget = portfolio
    this.renameName = portfolio.name
    this.showRenameDialog = true
  }

  async doRename(): Promise<void> {
    if (this.renameName.trim() === '' || this.renameTarget == null) {
      ToastUtil.error('请输入组合名称')
      return
    }
    const result = await PortfolioApi.rename(this.renameTarget.id, this.renameName.trim())
    if (result != null) {
      ToastUtil.success('组合已重命名')
      this.showRenameDialog = false
      this.renameTarget = null
      this.loadPortfolios()
    } else {
      ToastUtil.error('重命名失败')
    }
  }

  goFundList(): void {
    this.lastPageIndex = 0
  }

  goLogin(): void {
    AppStorage.set('nav_page', 'login')
  }

  getPortfolioFundCount(portfolio: Portfolio): number {
    if (portfolio.fundCount != null) {
      return portfolio.fundCount
    }
    if (portfolio.funds != null) {
      return portfolio.funds.length
    }
    if (portfolio.items != null) {
      return portfolio.items.length
    }
    return 0
  }

  getCreatedTime(portfolio: Portfolio): string {
    if (portfolio.createdTime != null) {
      return portfolio.createdTime
    }
    if (portfolio.createdAt != null) {
      return portfolio.createdAt
    }
    return ''
  }

  @Builder
  ListBody() {
    if (!this.userLogged) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6)
          .width('100%')

        EmptyState({
          emptyTitle: '请先登录',
          emptyDesc: '登录后可以用基金详情页创建自选组合',
          actionLabel: '去登录',
          onAction: (): void => { this.goLogin() }
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    } else if (this.isLoading) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6)
          .width('100%')

        LoadingIndicator({ mode: 'skeleton', skeletonCount: 3 })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    } else if (this.hasError) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6)
          .width('100%')

        ErrorState({
          errTitle: '加载失败',
          errDesc: '无法获取自选组合，请检查后端服务',
          retryLabel: '重试',
          onRetry: (): void => { this.loadPortfolios() }
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    } else if (this.portfolioList.length === 0) {
      Column() {
        Column().height(TOPBAR_TOTAL + 6)
          .width('100%')

        EmptyState({
          emptyTitle: '还没有自选组合',
          emptyDesc: '创建你的第一个自选组合，管理关注基金',
          actionLabel: '创建组合',
          onAction: (): void => { this.onOpenCreate() }
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    } else {
      Scroll() {
        Column({ space: AppSpacing.SM }) {
          Column().height(TOPBAR_TOTAL + 6)
            .width('100%')

          ForEach(this.portfolioList, (portfolio: Portfolio) => {
            PortfolioCard({
              portfolioName: portfolio.name,
              fundCount: this.getPortfolioFundCount(portfolio),
              createdAt: this.getCreatedTime(portfolio),
              onCardClick: (): void => { this.navToPortfolio(portfolio) },
              onCardDelete: (): void => { this.showDeleteDialogFor(portfolio) },
              onCardRename: (): void => { this.onOpenRename(portfolio) }
            })
          }, (portfolio: Portfolio) => portfolio.id.toString())

          AppButton({
            btnLabel: '+ 创建组合',
            btnWidth: '100%',
            btnHeight: 48,
            btnColor: AppColors.WHITE,
            btnTextColor: AppColors.PRIMARY,
            btnRadius: AppRadius.MEDIUM,
            onClickAction: (): void => { this.onOpenCreate() }
          })

          Column().height(BOTTOM_SPACER)
        }
        .width('100%')
        .padding({ left: AppSpacing.LG, right: AppSpacing.LG, top: AppSpacing.SM })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  build() {
    Stack() {
      // === 内容层 ===
      this.ListBody()

      // === topBar 层（悬浮） ===
      Stack() {
        Stack()
          .width('100%')
          .height('100%')
          .backgroundColor(AppColors.TOPBAR_BG)
          .blur(AppLayout.TOPBAR_BLUR)

        Column() {
          Row()
            .height(STATUS_BAR_HEIGHT)
            .width('100%')

          Column() {
            Column({ space: AppSpacing.SM }) {
              Text('我的自选')
                .fontSize(AppFontSize.TITLE)
                .fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold)
                .width('100%')

              Text(this.userLogged ? '登录用户：' + this.userName : '登录后可管理自选组合')
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.TEXT_TERTIARY)
                .width('100%')
            }
            .width('100%')
            .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({
            left: AppSpacing.LG,
            right: AppSpacing.LG,
            top: AppSpacing.SM,
            bottom: AppSpacing.SM
          })
        }

        // 底部半透明分割线
        Row()
          .width('100%')
          .height(1)
          .backgroundColor('rgba(0,0,0,0.06)')
          .position({ bottom: 0 })
      }
      .width('100%')
      .height(TOPBAR_TOTAL)
      .position({ top: 0 })

      // === 删除确认弹窗 ===
      AppDialog({
        showDialog: this.showDeleteDialog,
        dialogTitle: '删除组合',
        dialogContent: this.deleteTarget != null ? '确定要删除"' + this.deleteTarget.name + '"吗？' : '',
        confirmText: '删除',
        onConfirm: (): void => { this.doDelete() }
      })

      // === 创建组合弹窗 ===
      CreatePortfolioContent({
        showDialog: this.showCreateDialog,
        portfolioName: this.createName,
        onNameChange: (v: string): void => { this.createName = v },
        onCreate: (): void => { this.doCreate() }
      })

      // === 重命名组合弹窗 ===
      RenamePortfolioContent({
        showDialog: this.showRenameDialog,
        portfolioName: this.renameName,
        onNameChange: (v: string): void => { this.renameName = v },
        onRename: (): void => { this.doRename() }
      })
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct CreatePortfolioContent {
  @Link showDialog: boolean
  @Prop portfolioName: string = ''
  private onNameChange: (v: string) => void = (): void => {}
  private onCreate: () => void = (): void => {}

  build() {
    if (this.showDialog) {
      Stack() {
        // 点击空白关闭区域（透明，全屏）
        Stack()
          .width('100%')
          .height('100%')
          .onClick((): void => {
            this.showDialog = false
          })

        // 弹窗卡片（固定180px高度）
        Stack() {
          // 模糊层
          Stack()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(255,255,255,0.45)')
            .blur(12)

          // 内容
          Column({ space: AppSpacing.LG }) {
            Text('创建组合')
              .fontSize(AppFontSize.BODY_LARGE)
              .fontColor(AppColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .width('100%')

            TextInput({ placeholder: '请输入组合名称', text: this.portfolioName })
              .width('100%')
              .height(44)
              .backgroundColor('rgba(255,255,255,0.3)')
              .borderRadius(AppRadius.MEDIUM)
              .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
              .fontSize(AppFontSize.BODY)
              .placeholderColor(AppColors.TEXT_TERTIARY)
              .onChange((v: string): void => { this.onNameChange(v) })

            Row({ space: AppSpacing.MD }) {
              AppButton({
                btnLabel: '取消',
                btnWidth: '45%',
                btnHeight: AppButtonHeight.MEDIUM,
                btnColor: 'rgba(0,0,0,0.06)',
                btnTextColor: AppColors.TEXT_PRIMARY,
                btnFontSize: AppFontSize.BODY,
                btnRadius: AppRadius.MEDIUM,
                onClickAction: (): void => {
                  this.showDialog = false
                }
              })

              AppButton({
                btnLabel: '创建',
                btnWidth: '45%',
                btnHeight: AppButtonHeight.MEDIUM,
                btnFontSize: AppFontSize.BODY,
                btnRadius: AppRadius.MEDIUM,
                onClickAction: (): void => {
                  this.onCreate()
                }
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .padding(AppSpacing.XL)
        }
        .width('85%')
        .height(200)
        .borderRadius(AppRadius.LARGE)
        .border({ width: 1.5, color: 'rgba(200,200,200,0.8)' })
        .clip(true)
        .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .height('100%')
      .transition(TransitionEffect.translate({ y: 300 }).combine(TransitionEffect.opacity(0)))
      .animation({ duration: 350, curve: Curve.FastOutSlowIn })
    }
  }
}

@Component
export struct RenamePortfolioContent {
  @Link showDialog: boolean
  @Prop portfolioName: string = ''
  private onNameChange: (v: string) => void = (): void => {}
  private onRename: () => void = (): void => {}

  build() {
    if (this.showDialog) {
      Stack() {
        // 点击空白关闭区域（透明，全屏）
        Stack()
          .width('100%')
          .height('100%')
          .onClick((): void => {
            this.showDialog = false
          })

        // 弹窗卡片（固定200px高度）
        Stack() {
          // 模糊层
          Stack()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(255,255,255,0.45)')
            .blur(12)

          // 内容
          Column({ space: AppSpacing.LG }) {
            Text('重命名组合')
              .fontSize(AppFontSize.BODY_LARGE)
              .fontColor(AppColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .width('100%')

            TextInput({ placeholder: '请输入新名称', text: this.portfolioName })
              .width('100%')
              .height(44)
              .backgroundColor('rgba(255,255,255,0.3)')
              .borderRadius(AppRadius.MEDIUM)
              .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
              .fontSize(AppFontSize.BODY)
              .placeholderColor(AppColors.TEXT_TERTIARY)
              .onChange((v: string): void => { this.onNameChange(v) })

            Row({ space: AppSpacing.MD }) {
              AppButton({
                btnLabel: '取消',
                btnWidth: '45%',
                btnHeight: AppButtonHeight.MEDIUM,
                btnColor: 'rgba(0,0,0,0.06)',
                btnTextColor: AppColors.TEXT_PRIMARY,
                btnFontSize: AppFontSize.BODY,
                btnRadius: AppRadius.MEDIUM,
                onClickAction: (): void => {
                  this.showDialog = false
                }
              })

              AppButton({
                btnLabel: '确定',
                btnWidth: '45%',
                btnHeight: AppButtonHeight.MEDIUM,
                btnFontSize: AppFontSize.BODY,
                btnRadius: AppRadius.MEDIUM,
                onClickAction: (): void => {
                  this.onRename()
                }
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          }
          .padding(AppSpacing.XL)
        }
        .width('85%')
        .height(200)
        .borderRadius(AppRadius.LARGE)
        .border({ width: 1.5, color: 'rgba(200,200,200,0.8)' })
        .clip(true)
        .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .height('100%')
      .transition(TransitionEffect.translate({ y: 300 }).combine(TransitionEffect.opacity(0)))
      .animation({ duration: 350, curve: Curve.FastOutSlowIn })
    }
  }
}
