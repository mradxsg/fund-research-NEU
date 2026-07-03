import { AppColors, AppFontSize, AppSpacing, AppRadius, AppLayout, AppResponsive } from '../../common/constants/AppConstants'
import { AppButton } from '../base/AppButton'
import { ToastUtil } from '../base/ToastUtil'
import { AppCache } from '../../services/storage/AppCache'
import { navReplaceTo } from '../../services/NavigationService'
import { SvgIcon, AppIcons } from '../base/SvgIcon'

const STATUS_BAR_HEIGHT: number = 44
const TOPBAR_TOTAL: number = 88
const BOTTOM_SPACER: number = 90

@Preview
@Component
export struct ProfileContent {
  @StorageLink('user_name') userName: string = ''
  @Watch('onUserSessionChange') @StorageLink('user_logged') userLogged: boolean = false
  @Watch('onUserSessionChange') @StorageLink('user_id') userId: number = 0
  @StorageLink('show_logout_dialog') showLogoutDialog: boolean = false

  aboutToAppear(): void {
    this.tryRestoreSession()
  }

  onUserSessionChange(): void {
  }

  async tryRestoreSession(): Promise<void> {
    if (!this.userLogged) {
      const session = await AppCache.getUserSession()
      if (session != null) {
        AppStorage.set('user_logged', true)
        AppStorage.set('user_id', session.userId)
        AppStorage.set('user_name', session.username)
      }
    }
  }

  goLogin(): void {
    navReplaceTo('login', 0)
  }

  goAiChat(): void {
    navReplaceTo('aiChat', 0)
  }

  goSettings(): void {
    navReplaceTo('settings', 0)
  }

  logout(): void {
    AppStorage.set('show_logout_dialog', true)
  }

  async doLogout(): Promise<void> {
    AppStorage.set('user_logged', false)
    AppStorage.set('user_id', 0)
    AppStorage.set('user_name', '')
    await AppCache.clearUserSession()
    ToastUtil.success('已退出登录')
    this.userLogged = false
    AppStorage.set('show_logout_dialog', false)
  }

  @Builder
  line() {
    Row()
      .width('100%')
      .height(0.5)
      .backgroundColor(AppColors.DIVIDER)
  }

  @Builder
  QuickCard(icon: string, label: string, desc: string, action: () => void) {
    Row({ space: AppSpacing.MD }) {
      SvgIcon({ iconName: icon, iconSize: 36, iconColor: AppColors.PRIMARY })

      Column({ space: 2 }) {
        Text(label)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Text(desc)
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('〉')
        .fontSize(AppFontSize.BODY)
        .fontColor(AppColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding({ top: AppSpacing.MD, bottom: AppSpacing.MD, left: AppSpacing.MD, right: AppSpacing.SM })
    .alignItems(VerticalAlign.Center)
    .onClick(() => { action() })
  }

  @Builder
  FeatureCard(icon: string, title: string, desc: string) {
    Row({ space: AppSpacing.MD }) {
      Stack() {
        SvgIcon({ iconName: icon, iconSize: 32, iconColor: AppColors.PRIMARY })
      }
      .width(56)
      .height(56)
      .backgroundColor(AppColors.PRIMARY_LIGHT)
      .borderRadius(AppRadius.MEDIUM)
      .alignContent(Alignment.Center)

      Column({ space: 2 }) {
        Text(title)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Text(desc)
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .lineHeight(18)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
  }

  build() {
    Stack() {
      // === 内容层 ===
      Scroll() {
        Column({ space: AppSpacing.MD }) {
          Column().height(TOPBAR_TOTAL + 6).width('100%')

          // ===== 用户信息卡片 =====
          Column({ space: AppSpacing.MD }) {
            Row({ space: AppSpacing.MD }) {
              Stack() {
                Circle()
                  .width(56)
                  .height(56)
                  .fill(this.userLogged ? AppColors.PRIMARY : AppColors.DIVIDER)

                Text(this.userLogged && this.userName.length > 0 ? this.userName.substring(0, 1) : '?')
                  .fontSize(AppFontSize.BODY_LARGE)
                  .fontColor(this.userLogged ? AppColors.WHITE : AppColors.TEXT_TERTIARY)
                  .fontWeight(FontWeight.Bold)
              }
              .width(56)
              .height(56)

              Column({ space: 4 }) {
                Text(this.userLogged ? this.userName : '未登录')
                  .fontSize(AppFontSize.HEADING)
                  .fontColor(AppColors.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')

                Text(this.userLogged
                  ? '欢迎回来，管理你的自选组合'
                  : '登录后可以管理自选组合和更多功能')
                  .fontSize(AppFontSize.SMALL)
                  .fontColor(AppColors.TEXT_TERTIARY)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            if (!this.userLogged) {
              AppButton({
                btnLabel: '登录 / 注册',
                btnWidth: 160,
                btnHeight: 40,
                onClickAction: (): void => { this.goLogin() }
              })
            }
          }
          .width('100%')
          .padding(AppSpacing.LG)
          .backgroundColor(AppColors.WHITE)
          .borderRadius(AppRadius.CARD)
          .alignItems(HorizontalAlign.Start)

          // ===== 快捷入口 =====
          Column() {
            Text('快捷功能')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_SECONDARY)
              .padding({ left: 4, bottom: AppSpacing.XS })

            Column({ space: 0 }) {
              this.QuickCard(AppIcons.ROBOT, 'AI 助手', '智能问答与基金分析', (): void => { this.goAiChat() })
              this.line()
              this.QuickCard(AppIcons.SETTINGS, '设置', '后端地址配置、缓存管理等', (): void => { this.goSettings() })
            }
            .width('100%')
            .backgroundColor(AppColors.WHITE)
            .borderRadius(AppRadius.CARD)
          }
          .width('100%')

          // ===== 功能介绍 =====
          Column() {
            Text('功能介绍')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_SECONDARY)
              .padding({ left: 4, bottom: AppSpacing.XS })

            Column({ space: 0 }) {
              Column({ space: 0 }) {
                this.FeatureCard(AppIcons.CHART, '基金浏览', '浏览全部基金列表，按标签分类快速筛选，查看基金详情、净值走势、行业持仓等信息。')
                this.line()
                this.FeatureCard(AppIcons.COMPANY, '基金公司', '浏览基金公司列表，查看公司管理的基金产品，了解公司信息。')
                this.line()
                this.FeatureCard(AppIcons.MANAGER, '基金经理', '浏览基金经理列表，查看经理背景、管理经验和历史业绩。')
                this.line()
                this.FeatureCard(AppIcons.STAR, '自选组合', '创建和管理自选组合，将关注的基金添加到组合中统一跟踪。')
                this.line()
                this.FeatureCard(AppIcons.CHAT, 'AI 智能问答', '基于 DeepSeek 的 AI 助手，解答基金投资相关问题。')
                this.line()
                this.FeatureCard(AppIcons.ANNOUNCEMENT, '公告中心', '查看基金公告、分红信息、基金经理变更等最新动态。')
              }
              .width('100%')
            }
            .width('100%')
          }
          .width('100%')
          .padding(AppSpacing.LG)
          .backgroundColor(AppColors.WHITE)
          .borderRadius(AppRadius.CARD)

          // ===== 关于 =====
          Column() {
            Text('关于')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_SECONDARY)
              .padding({ left: 4, bottom: AppSpacing.XS })

            Column({ space: 0 }) {
              Row({ space: AppSpacing.SM }) {
                Text('版本').fontSize(AppFontSize.BODY).fontColor(AppColors.TEXT_SECONDARY).layoutWeight(1)
                Text('1.0.0').fontSize(AppFontSize.BODY).fontColor(AppColors.TEXT_PRIMARY)
              }
              .width('100%')
              .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
              this.line()
              Row({ space: AppSpacing.SM }) {
                Text('技术栈').fontSize(AppFontSize.BODY).fontColor(AppColors.TEXT_SECONDARY).layoutWeight(1)
                Text('Spring Boot + ArkTS').fontSize(AppFontSize.BODY).fontColor(AppColors.TEXT_PRIMARY)
              }
              .width('100%')
              .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
              this.line()
              Row({ space: AppSpacing.SM }) {
                Text('数据来源').fontSize(AppFontSize.BODY).fontColor(AppColors.TEXT_SECONDARY).layoutWeight(1)
                Text('模拟数据 · 仅供参考').fontSize(AppFontSize.SMALL).fontColor(AppColors.TEXT_TERTIARY)
              }
              .width('100%')
              .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
            }
            .width('100%')
            .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
            .backgroundColor(AppColors.WHITE)
            .borderRadius(AppRadius.CARD)
          }
          .width('100%')

          if (this.userLogged) {
            AppButton({
              btnLabel: '退出登录',
              btnHeight: 44,
              btnColor: AppColors.WHITE,
              btnTextColor: AppColors.ERROR,
              onClickAction: (): void => { this.logout() }
            })
          }

          Column().height(BOTTOM_SPACER)
        }
        .width('100%')
        .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
        .padding({ left: AppSpacing.LG, right: AppSpacing.LG, top: AppSpacing.SM })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // === topBar ===
      Stack() {
        Stack()
          .width('100%')
          .height('100%')
          .backgroundColor(AppColors.TOPBAR_BG)
          .blur(AppLayout.TOPBAR_BLUR)

        Column() {
          Row().height(STATUS_BAR_HEIGHT).width('100%')
          Column() {
            Column({ space: AppSpacing.SM }) {
              Text('个人信息')
                .fontSize(AppFontSize.TITLE)
                .fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold)
                .width('100%')
            }
            .width('100%')
            .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ left: AppSpacing.LG, right: AppSpacing.LG, top: AppSpacing.SM, bottom: AppSpacing.SM })
        }

        Row()
          .width('100%')
          .height(1)
          .backgroundColor('rgba(0,0,0,0.06)')
          .position({ bottom: 0 })
      }
      .width('100%')
      .height(TOPBAR_TOTAL)
      .position({ top: 0 })
    }
    .width('100%')
    .height('100%')
  }
}
