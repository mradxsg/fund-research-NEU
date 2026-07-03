import { AppLayout, AppResponsive, AppSpacing, AppColors, AppFontSize } from '../../common/constants/AppConstants'
import { BottomTabBar } from '../common/BottomTabBar'
import { FundListContent } from '../pages/FundListContent'
import { CompanyListContent } from '../pages/CompanyListContent'
import { ManagerListContent } from '../pages/ManagerListContent'
import { PortfolioListContent } from '../pages/PortfolioListContent'
import { ProfileContent } from '../pages/ProfileContent'
import { GradientBackground } from '../base/GradientBackground'
import { FundDetailPage } from '../placeholders/FundDetailPage'
import { CompanyDetailPage } from '../placeholders/CompanyDetailPage'
import { ManagerDetailPage } from '../placeholders/ManagerDetailPage'
import { LoginPage } from '../placeholders/LoginPage'
import { RegisterPage } from '../placeholders/RegisterPage'
import { SettingsPage } from '../placeholders/SettingsPage'
import { AiChatPage } from '../placeholders/AiChatPage'
import { PortfolioDetailPage } from '../placeholders/PortfolioDetailPage'
import { AnnouncementDetailPage } from '../placeholders/AnnouncementDetailPage'
import { AppDialog } from '../base/AppDialog'
import { AppCache } from '../../services/storage/AppCache'
import { ToastUtil } from '../base/ToastUtil'
import { navPushTo, setPrevNavPage, NavEntry } from '../../services/NavigationService'
/** 所有可导航的页面名称列表（用于同时渲染在 Stack 中） */
const NAV_PAGES: string[] = [
  'fundDetail', 'companyDetail', 'managerDetail', 'portfolioDetail',
  'login', 'register', 'settings', 'aiChat', 'announcementDetail'
]

@Preview
@Component
export struct MainPageContainer {
  @StorageLink('home_last_page') lastPageIndex: number = 0
  @StorageLink('nav_page') @Watch('onNavPageChange') navPage: string = ''
  @StorageLink('nav_param') navParam: number = 0
  @StorageLink('nav_stack') navStack: string = '[]'
  @StorageLink('nav_dir') navDir: string = 'push'
  @StorageLink('show_logout_dialog') showLogoutDialog: boolean = false
  @StorageLink('nav_parallel_refresh') @Watch('onParallelRefresh') parallelRefresh: number = 0
  @State containerWidth: number = 0
  @State currentPageIndex: number = 0
  @State isTablet: boolean = false
  @State isLandscape: boolean = false
  @State parallelNavParam: number = 0
  @State useHalfSplit: boolean = false

  aboutToAppear(): void {
    this.currentPageIndex = this.getCurrentPageIndex()
    this.isTablet = AppStorage.get<boolean>('is_tablet') || false
    this.syncParallelNav()
    // useHalfSplit 将在 onAreaChange 中根据实际容器宽高比设置
    this.useHalfSplit = false
  }

  /** navPage 变化时同步平行视界参数 */
  onNavPageChange(): void {
    this.parallelNavParam = this.navParam
  }

  /** 平行视界刷新信号（处理 navPage 不变但 navParam 变的情况） */
  onParallelRefresh(): void {
    if (this.isTablet && (this.isLandscape || this.useHalfSplit) && this.navPage !== '') {
      this.parallelNavParam = this.navParam
    }
  }

  syncParallelNav(): void {
    this.parallelNavParam = this.navParam
  }

  onSwitchPage(index: number): void {
    if (index === this.currentPageIndex) {
      return
    }
    this.currentPageIndex = index
    this.lastPageIndex = index
    // 平行视界切换tab时，关闭右侧详情
    if (this.isTablet && (this.isLandscape || this.useHalfSplit) && this.navPage !== '') {
      // 直接清空右侧面板，同时清空栈
      AppStorage.set('nav_stack', '[]')
      AppStorage.set('nav_dir', 'pop')
      AppStorage.set('nav_page', '')
    }
  }

  getCurrentPageIndex(): number {
    if (this.lastPageIndex >= 0 && this.lastPageIndex <= 4) {
      return this.lastPageIndex
    }
    return 0
  }

  /** 保留原始的完整栈回溯关闭，供非平行视界模式使用 */
  closeNavPageStack(): void {
    setPrevNavPage(this.navPage)
    const stackStr: string = AppStorage.get<string>('nav_stack') || '[]'
    const stackArr: NavEntry[] = JSON.parse(stackStr)
    if (stackArr.length > 0) {
      const prev: NavEntry = stackArr.pop()!
      AppStorage.set('nav_stack', JSON.stringify(stackArr))
      AppStorage.set('nav_dir', 'pop')
      AppStorage.set('nav_param', prev.param)
      AppStorage.set('nav_page', prev.page)
    } else {
      AppStorage.set('nav_dir', 'pop')
      AppStorage.set('nav_page', '')
    }
  }

  /** 关闭导航页面：统一使用栈回溯 */
  closeNavPage(): void {
    this.closeNavPageStack()
  }

  async doLogout(): Promise<void> {
    AppStorage.set('user_logged', false)
    AppStorage.set('user_id', 0)
    AppStorage.set('user_name', '')
    await AppCache.clearUserSession()
    ToastUtil.success('已退出登录')
    AppStorage.set('show_logout_dialog', false)
  }

  @Builder
  MainTabs() {
    Stack() {
      FundListContent()
        .width('100%').height('100%')
        .translate({ x: this.containerWidth * (0 - this.currentPageIndex) })
        .opacity(this.currentPageIndex === 0 ? 1 : 0)
        .animation({ duration: 350, curve: Curve.FastOutSlowIn })

      CompanyListContent()
        .width('100%').height('100%')
        .translate({ x: this.containerWidth * (1 - this.currentPageIndex) })
        .opacity(this.currentPageIndex === 1 ? 1 : 0)
        .animation({ duration: 350, curve: Curve.FastOutSlowIn })

      ManagerListContent()
        .width('100%').height('100%')
        .translate({ x: this.containerWidth * (2 - this.currentPageIndex) })
        .opacity(this.currentPageIndex === 2 ? 1 : 0)
        .animation({ duration: 350, curve: Curve.FastOutSlowIn })

      PortfolioListContent()
        .width('100%').height('100%')
        .translate({ x: this.containerWidth * (3 - this.currentPageIndex) })
        .opacity(this.currentPageIndex === 3 ? 1 : 0)
        .animation({ duration: 350, curve: Curve.FastOutSlowIn })

      ProfileContent()
        .width('100%').height('100%')
        .translate({ x: this.containerWidth * (4 - this.currentPageIndex) })
        .opacity(this.currentPageIndex === 4 ? 1 : 0)
        .animation({ duration: 350, curve: Curve.FastOutSlowIn })

      BottomTabBar({
        currentPageIndex: this.currentPageIndex,
        containerWidth: this.containerWidth,
        isTablet: this.isTablet,
        onPageChange: (index: number): void => { this.onSwitchPage(index) }
      })
        .width(this.isTablet ? 280 : 230)
        .position({ left: AppSpacing.LG, bottom: AppLayout.BOTTOMBAR_BOTTOM_GAP })
    }
    .width('100%').height('100%')
  }

  /** 判断是否当前激活页面 */
  isNavActive(pageName: string): boolean {
    return this.navPage === pageName
  }

  /** 检查页面是否应该参与交互 */
  navHitTest(pageName: string): HitTestMode {
    return this.isNavActive(pageName) ? HitTestMode.Default : HitTestMode.None
  }

  @Builder
  renderNavPage(pageName: string) {
    if (pageName === 'fundDetail') {
      FundDetailPage({ fundId: this.navParam, onBack: (): void => { this.closeNavPage() } })
    } else if (pageName === 'companyDetail') {
      CompanyDetailPage({ companyId: this.navParam, onBack: (): void => { this.closeNavPage() } })
    } else if (pageName === 'managerDetail') {
      ManagerDetailPage({ managerId: this.navParam, onBack: (): void => { this.closeNavPage() } })
    } else if (pageName === 'portfolioDetail') {
      PortfolioDetailPage({ portfolioId: this.navParam, onBack: (): void => { this.closeNavPage() } })
    } else if (pageName === 'login') {
      LoginPage({ onBack: (): void => { this.closeNavPage() },
        onGoRegister: (): void => { navPushTo('register', 0) },
        onLoginSuccess: (): void => { this.closeNavPage() } })
    } else if (pageName === 'register') {
      RegisterPage({ onBack: (): void => { this.closeNavPage() },
        onGoLogin: (): void => { navPushTo('login', 0) },
        onRegisterSuccess: (): void => { this.closeNavPage() } })
    } else if (pageName === 'settings') {
      SettingsPage({ onBack: (): void => { this.closeNavPage() } })
    } else if (pageName === 'aiChat') {
      AiChatPage({ onBack: (): void => { this.closeNavPage() } })
    } else if (pageName === 'announcementDetail') {
      AnnouncementDetailPage({ onBack: (): void => { this.closeNavPage() } })
    }
  }

  build() {
    Stack() {
      GradientBackground()

      if (this.isTablet && (this.isLandscape || this.useHalfSplit)) {
        // ============================================================
        // 平板横屏：平行视界分栏布局
        // ============================================================
        Row() {
          // 左侧：主页面（tab 列表 + 底部栏）
          Stack() { this.MainTabs() }
            .width(this.useHalfSplit ? '50%' : '35%')
            .height('100%')

          // 分割线
          Column()
            .width(1)
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.06)')

          // 右侧：详情面板（平行视界，用 if/else if 只渲染一个页面 + transition 淡入淡出）
          Stack() {
            if (this.navPage === 'fundDetail') {
              FundDetailPage({ fundId: this.parallelNavParam, onBack: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else if (this.navPage === 'companyDetail') {
              CompanyDetailPage({ companyId: this.parallelNavParam, onBack: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else if (this.navPage === 'managerDetail') {
              ManagerDetailPage({ managerId: this.parallelNavParam, onBack: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else if (this.navPage === 'portfolioDetail') {
              PortfolioDetailPage({ portfolioId: this.parallelNavParam, onBack: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else if (this.navPage === 'announcementDetail') {
              AnnouncementDetailPage({ onBack: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else if (this.navPage === 'login') {
              LoginPage({ onBack: (): void => { this.closeNavPage() },
                  onGoRegister: (): void => { navPushTo('register', 0) },
                  onLoginSuccess: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else if (this.navPage === 'register') {
              RegisterPage({ onBack: (): void => { this.closeNavPage() },
                  onGoLogin: (): void => { navPushTo('login', 0) },
                  onRegisterSuccess: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else if (this.navPage === 'settings') {
              SettingsPage({ onBack: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else if (this.navPage === 'aiChat') {
              AiChatPage({ onBack: (): void => { this.closeNavPage() } })
                .transition({ type: TransitionType.Insert, opacity: 0 })
            } else {
              // 空状态占位（navPage为空时显示）
              Column() {
                Text('选择一个项目查看详情')
                  .fontSize(AppFontSize.BODY_LARGE)
                  .fontColor(AppColors.TEXT_TERTIARY)
              }
                .width('100%').height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
          }
            .width(this.useHalfSplit ? '50%' : '65%')
            .height('100%')
        }
        .width('100%').height('100%')
      } else {
        // ============================================================
        // 手机 / 平板竖屏：原叠加布局
        // ============================================================

        // === 主页面 ===
        Stack() { this.MainTabs() }
          .width('100%').height('100%')
          .opacity(this.navPage === '' ? 1 : 0)
          .hitTestBehavior(this.navPage === '' ? HitTestMode.Default : HitTestMode.None)
          .animation({ duration: 350, curve: Curve.FastOutSlowIn })

        // === 导航页面栈 ===
        if (this.navPage !== '') {
          Stack() {
            ForEach(NAV_PAGES, (pageName: string) => {
              Stack() {
                Stack() {
                  this.renderNavPage(pageName)
                }
                  .opacity(this.isNavActive(pageName) ? 1 : 0)
                  .hitTestBehavior(this.navHitTest(pageName))
                  .animation({ duration: 350, curve: Curve.FastOutSlowIn })
              }
                .width('100%').height('100%')
                .translate({ x: this.isNavActive(pageName) ? 0 : this.containerWidth })
            }, (pageName: string) => pageName)
          }
            .width('100%').height('100%')
        }
      }

      // === 全局弹窗（始终在最上层） ===
      AppDialog({
        showDialog: this.showLogoutDialog,
        dialogTitle: '退出登录',
        dialogContent: '确定要退出当前账号吗？',
        confirmText: '退出',
        onConfirm: (): void => { this.doLogout() }
      })
    }
    .width('100%').height('100%')
.onAreaChange((_old: Area, newV: Area) => {
      const w: number = newV.width as number
      const h: number = newV.height as number
      if (typeof w === 'number' && w > 0) {
        // 更新宽度和横竖屏
        if (Math.abs(w - this.containerWidth) > 1) {
          this.containerWidth = w
        }
        const wasLandscape: boolean = this.isLandscape
        const wasTablet: boolean = this.isTablet
        this.isLandscape = w > h

        // 更新平板状态
        const tabletMode: boolean = w >= AppResponsive.TABLET_BREAKPOINT
        if (tabletMode !== this.isTablet) {
          this.isTablet = tabletMode
          AppStorage.set('is_tablet', tabletMode)
        }

        // 折叠屏检测：宽高比 < 1.35（接近正方形）→ 折叠屏展开 → 50/50 平分
        // 宽高比 ≥ 1.35（长方形）→ 普通平板 → 35/65 不变
        // 使用 max/min 确保横竖屏都能正确判断
        this.useHalfSplit = tabletMode && (Math.max(w, h) / Math.min(w, h)) < 1.35

        const nowParallel: boolean = this.isTablet && (this.isLandscape || this.useHalfSplit)
        const wasParallel: boolean = wasTablet && (wasLandscape || this.useHalfSplit)
        if (nowParallel !== wasParallel) {
          // 进入/退出平行视界：清空导航状态
          AppStorage.set('nav_stack', '[]')
          AppStorage.set('nav_page', '')
          AppStorage.set('nav_param', 0)
        }
      }
    })
  }
}
