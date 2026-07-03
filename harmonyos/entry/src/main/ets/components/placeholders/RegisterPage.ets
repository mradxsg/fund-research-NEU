import { AppColors, AppFontSize, AppSpacing, AppButtonHeight } from '../../common/constants/AppConstants'
import { GenericPage } from '../common/GenericPage'
import { AppTextInput } from '../base/AppTextInput'
import { AppButton } from '../base/AppButton'
import { ToastUtil } from '../base/ToastUtil'
import { UserApi } from '../../services/api/UserApi'
import { AppCache } from '../../services/storage/AppCache'

@Preview
@Component
export struct RegisterPage {
  @State username: string = ''
  @State password: string = ''
  @State confirmPwd: string = ''
  @State isLoading: boolean = false
  onBack: () => void = (): void => {}
  onGoLogin: () => void = (): void => {}
  onRegisterSuccess: () => void = (): void => {}

  async doRegister(): Promise<void> {
    if (this.username.trim() === '' || this.password.trim() === '') {
      ToastUtil.warning('请输入用户名和密码')
      return
    }
    if (this.password.trim().length < 6) {
      ToastUtil.warning('密码长度不能少于6位')
      return
    }
    if (this.password !== this.confirmPwd) {
      ToastUtil.warning('两次密码不一致')
      return
    }
    this.isLoading = true
    const res = await UserApi.register(this.username.trim(), this.password.trim())
    this.isLoading = false
    if (res != null && res.data != null && (res.code === 200)) {
      const uData = res.data
      const uid: number = uData.userId != null ? uData.userId : (uData.id != null ? uData.id : 0)
      AppStorage.set('user_logged', true)
      AppStorage.set('user_id', uid)
      AppStorage.set('user_name', uData.username)
      await AppCache.setUserSession({ userId: uid, username: uData.username, loginTime: Date.now() })
      ToastUtil.success('注册成功')
      this.onRegisterSuccess()
    } else {
      const errMsg: string = (res != null && res.message != null) ? res.message : '服务器连接失败，请检查后端是否启动'
      ToastUtil.error('注册失败：' + errMsg)
    }
  }

  build() {
    GenericPage({
      pageTitle: '注册',
      showBack: true,
      onBack: this.onBack
    }) {
      Column({ space: AppSpacing.XL }) {
        Column({ space: AppSpacing.SM }) {
          Text('创建账号')
            .fontSize(AppFontSize.TITLE)
            .fontColor(AppColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
            .width('100%')

          Text('注册后即可创建和管理自选组合')
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
          AppTextInput({
            phText: '确认密码',
            initValue: this.confirmPwd,
            isPassword: true,
            onChange: (v: string): void => { this.confirmPwd = v }
          })
        }
        .width('100%')

        AppButton({
          btnLabel: this.isLoading ? '注册中...' : '注册',
          btnHeight: AppButtonHeight.LARGE,
          btnDisabled: this.isLoading,
          onClickAction: (): void => { this.doRegister() }
        })

        Row() {
          Text('已有账号？')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_TERTIARY)

          Text('立即登录')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.PRIMARY)
            .fontWeight(FontWeight.Medium)
            .onClick(() => { this.onGoLogin() })
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
