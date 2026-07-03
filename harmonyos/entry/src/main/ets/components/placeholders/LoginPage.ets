import { AppColors, AppFontSize, AppSpacing, AppButtonHeight } from '../../common/constants/AppConstants'
import { GenericPage } from '../common/GenericPage'
import { AppTextInput } from '../base/AppTextInput'
import { AppButton } from '../base/AppButton'
import { ToastUtil } from '../base/ToastUtil'
import { UserApi } from '../../services/api/UserApi'
import { AppCache } from '../../services/storage/AppCache'

@Preview
@Component
export struct LoginPage {
  @State username: string = ''
  @State password: string = ''
  @State isLoading: boolean = false
  onBack: () => void = (): void => {}
  onGoRegister: () => void = (): void => {}
  onLoginSuccess: () => void = (): void => {}

  async doLogin(): Promise<void> {
    if (this.username.trim() === '' || this.password.trim() === '') {
      ToastUtil.warning('请输入用户名和密码')
      return
    }
    this.isLoading = true
    const res = await UserApi.login(this.username.trim(), this.password.trim())
    this.isLoading = false
    if (res != null && res.data != null && (res.code === 200)) {
      const uData = res.data
      const uid: number = uData.userId != null ? uData.userId : (uData.id != null ? uData.id : 0)
      AppStorage.set('user_logged', true)
      AppStorage.set('user_id', uid)
      AppStorage.set('user_name', uData.username)
      await AppCache.setUserSession({ userId: uid, username: uData.username, loginTime: Date.now() })
      ToastUtil.success('登录成功')
      this.onLoginSuccess()
    } else {
      const errMsg: string = (res != null && res.message != null) ? res.message : '服务器连接失败，请检查后端是否启动'
      ToastUtil.error('登录失败：' + errMsg)
    }
  }

  build() {
    GenericPage({
      pageTitle: '登录',
      showBack: true,
      onBack: this.onBack
    }) {
      Column({ space: AppSpacing.XL }) {
        Column({ space: AppSpacing.SM }) {
          Text('欢迎回来')
            .fontSize(AppFontSize.TITLE)
            .fontColor(AppColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .width('100%')

          Text('登录以管理你的自选组合')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width('100%')
        }
        .width('100%')
        .padding({ top: AppSpacing.XXL })

        Column({ space: AppSpacing.MD }) {
          AppTextInput({
            phText: '用户名',
            initValue: this.username,
            onChange: (v: string): void => { this.username = v }
          })

          AppTextInput({
            phText: '密码',
            initValue: this.password,
            isPassword: true,
            onChange: (v: string): void => { this.password = v }
          })
        }
        .width('100%')

        AppButton({
          btnLabel: this.isLoading ? '登录中...' : '登录',
          btnHeight: AppButtonHeight.LARGE,
          btnDisabled: this.isLoading,
          onClickAction: (): void => { this.doLogin() }
        })

        Row() {
          Text('还没有账号？')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_TERTIARY)

          Text('立即注册')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.PRIMARY)
            .fontWeight(FontWeight.Medium)
            .onClick(() => { this.onGoRegister() })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Column().height(32)
      }
      .width('100%')
      .padding({ left: AppSpacing.XXL, right: AppSpacing.XXL })
    }
  }
}
