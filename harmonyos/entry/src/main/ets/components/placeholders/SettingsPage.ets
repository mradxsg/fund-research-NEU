import { AppColors, AppFontSize, AppSpacing, AppButtonHeight, AppRadius } from '../../common/constants/AppConstants'
import { GenericPage } from '../common/GenericPage'
import { AppTextInput } from '../base/AppTextInput'
import { AppButton } from '../base/AppButton'
import { AppDialog } from '../base/AppDialog'
import { ToastUtil } from '../base/ToastUtil'
import { HttpClient } from '../../services/HttpClient'
import { AppCache } from '../../services/storage/AppCache'
import { UserApi } from '../../services/api/UserApi'
import { inputMethod } from '@kit.IMEKit'

@Preview
@Component
export struct SettingsPage {
  @StorageLink('user_name') userName: string = ''
  @StorageLink('user_id') userId: number = 0
  @StorageLink('user_logged') userLogged: boolean = false

  @State baseUrl: string = ''
  @State newUrl: string = ''

  // 修改用户名相关
  @State newUserName: string = ''
  @State userNamePassword: string = ''

  // 修改密码相关
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''

  // 弹窗控制
  @State showSaveUrlDialog: boolean = false
  @State showClearCacheDialog: boolean = false
  @State showUpdateUsernameDialog: boolean = false
  @State showUpdatePasswordDialog: boolean = false

  @State dialogTitle: string = ''
  @State dialogContent: string = ''

  onBack: () => void = (): void => {}

  aboutToAppear(): void {
    this.baseUrl = HttpClient.getBaseUrl()
    this.newUrl = this.baseUrl
    this.newUserName = this.userName
  }

  onSaveUrlConfirm(): void {
    const self = this
    HttpClient.setBaseUrl(self.newUrl.trim()).then((): void => {
      self.baseUrl = self.newUrl.trim()
      ToastUtil.success('地址已更新')
    })
  }

  onClearCacheConfirm(): void {
    const self = this
    AppCache.clearAll().then((): void => {
      HttpClient.initBaseUrl().then((): void => {
        self.baseUrl = HttpClient.getBaseUrl()
        self.newUrl = self.baseUrl
        ToastUtil.success('缓存已清除')
      })
    })
  }

  onUpdateUsernameConfirm(): void {
    const self = this
    UserApi.updateUsername(self.userId, self.newUserName.trim(), self.userNamePassword).then((res) => {
      if (res != null && res.code === 200) {
        AppStorage.set('user_name', self.newUserName.trim())
        self.userName = self.newUserName.trim()
        self.userNamePassword = ''
        ToastUtil.success('用户名已更新')
      } else {
        ToastUtil.error(res?.message || '修改失败，请检查密码')
      }
    })
  }

  onUpdatePasswordConfirm(): void {
    const self = this
    UserApi.updatePassword(self.userId, self.oldPassword, self.newPassword).then((res) => {
      if (res != null && res.code === 200) {
        self.oldPassword = ''
        self.newPassword = ''
        self.confirmPassword = ''
        ToastUtil.success('密码已更新')
      } else {
        ToastUtil.error(res?.message || '修改失败，请检查原密码')
      }
    })
  }

  saveUrl(): void {
    if (this.newUrl.trim() === '') {
      ToastUtil.warning('请输入后端服务地址')
      return
    }
    this.dialogTitle = '确认修改'
    this.dialogContent = '修改后端地址为：' + this.newUrl.trim()
    this.showSaveUrlDialog = true
  }

  clearCache(): void {
    this.dialogTitle = '清除缓存'
    this.dialogContent = '确定要清除本地缓存吗？后端地址也会恢复为默认值。'
    this.showClearCacheDialog = true
  }

  dismissKeyboard(): void {
    try {
      inputMethod.getController().stopInputSession()
    } catch (_) {
      // 忽略关键盘失败
    }
  }

  updateUsername(): void {
    if (!this.userLogged) {
      ToastUtil.warning('请先登录')
      return
    }
    if (this.newUserName.trim() === '') {
      ToastUtil.warning('请输入新的用户名')
      return
    }
    if (this.userNamePassword === '') {
      ToastUtil.warning('请输入密码验证身份')
      return
    }
    this.dismissKeyboard()
    this.dialogTitle = '确认修改用户名'
    this.dialogContent = '将用户名修改为：' + this.newUserName.trim()
    this.showUpdateUsernameDialog = true
  }

  updatePassword(): void {
    if (!this.userLogged) {
      ToastUtil.warning('请先登录')
      return
    }
    if (this.oldPassword === '') {
      ToastUtil.warning('请输入原密码')
      return
    }
    if (this.newPassword === '') {
      ToastUtil.warning('请输入新密码')
      return
    }
    if (this.newPassword.length < 6) {
      ToastUtil.warning('新密码长度不能少于6位')
      return
    }
    if (this.newPassword !== this.confirmPassword) {
      ToastUtil.warning('两次输入的新密码不一致')
      return
    }
    this.dismissKeyboard()
    this.dialogTitle = '确认修改密码'
    this.dialogContent = '确定要修改登录密码吗？'
    this.showUpdatePasswordDialog = true
  }

  build() {
    Stack() {
      GenericPage({
        pageTitle: '设置',
        showBack: true,
        onBack: this.onBack
      }) {
        Column({ space: AppSpacing.LG }) {
          // ===== 修改用户名 =====
          if (this.userLogged) {
            Column({ space: AppSpacing.MD }) {
              Text('修改用户名')
                .fontSize(AppFontSize.BODY_LARGE)
                .fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold)
                .width('100%')

              Text('当前用户名：' + this.userName)
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.TEXT_TERTIARY)
                .width('100%')

              AppTextInput({
                phText: '输入新的用户名',
                initValue: this.newUserName,
                onChange: (v: string): void => { this.newUserName = v }
              })

              AppTextInput({
                phText: '输入密码验证身份',
                initValue: this.userNamePassword,
                isPassword: true,
                onChange: (v: string): void => { this.userNamePassword = v }
              })

              AppButton({
                btnLabel: '保存用户名',
                btnHeight: AppButtonHeight.MEDIUM,
                onClickAction: (): void => { this.updateUsername() }
              })
            }
            .width('100%')
            .padding(AppSpacing.LG)
            .backgroundColor(AppColors.WHITE)
            .borderRadius(AppRadius.CARD)
          }

          // ===== 修改密码 =====
          if (this.userLogged) {
            Column({ space: AppSpacing.MD }) {
              Text('修改密码')
                .fontSize(AppFontSize.BODY_LARGE)
                .fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold)
                .width('100%')

              Text('请先验证原密码，再设置新密码。')
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.TEXT_TERTIARY)
                .width('100%')

              AppTextInput({
                phText: '输入原密码',
                initValue: this.oldPassword,
                isPassword: true,
                onChange: (v: string): void => { this.oldPassword = v }
              })

              AppTextInput({
                phText: '输入新密码（至少6位）',
                initValue: this.newPassword,
                isPassword: true,
                onChange: (v: string): void => { this.newPassword = v }
              })

              AppTextInput({
                phText: '再次输入新密码',
                initValue: this.confirmPassword,
                isPassword: true,
                onChange: (v: string): void => { this.confirmPassword = v }
              })

              AppButton({
                btnLabel: '保存密码',
                btnHeight: AppButtonHeight.MEDIUM,
                onClickAction: (): void => { this.updatePassword() }
              })
            }
            .width('100%')
            .padding(AppSpacing.LG)
            .backgroundColor(AppColors.WHITE)
            .borderRadius(AppRadius.CARD)
          }

          // ===== 后端服务地址 =====
          Column({ space: AppSpacing.MD }) {
            Text('后端服务地址')
              .fontSize(AppFontSize.BODY_LARGE)
              .fontColor(AppColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .width('100%')

            Text('当前：' + this.baseUrl)
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
              .width('100%')

            AppTextInput({
              phText: '例如 http://192.168.1.10:8080',
              initValue: this.newUrl,
              onChange: (v: string): void => { this.newUrl = v }
            })

            AppButton({
              btnLabel: '保存地址',
              btnHeight: AppButtonHeight.MEDIUM,
              onClickAction: (): void => { this.saveUrl() }
            })
          }
          .width('100%')
          .padding(AppSpacing.LG)
          .backgroundColor(AppColors.WHITE)
          .borderRadius(AppRadius.CARD)

          // ===== 本地数据 =====
          Column({ space: AppSpacing.MD }) {
            Text('本地数据')
              .fontSize(AppFontSize.BODY_LARGE)
              .fontColor(AppColors.TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .width('100%')

            Text('清除接口缓存、登录缓存和后端地址缓存。')
              .fontSize(AppFontSize.SMALL)
              .fontColor(AppColors.TEXT_TERTIARY)
              .width('100%')

            AppButton({
              btnLabel: '清除本地缓存',
              btnHeight: AppButtonHeight.MEDIUM,
              btnColor: AppColors.WARNING,
              onClickAction: (): void => { this.clearCache() }
            })
          }
          .width('100%')
          .padding(AppSpacing.LG)
          .backgroundColor(AppColors.WHITE)
          .borderRadius(AppRadius.CARD)

          Text('版本 1.0.0')
            .fontSize(AppFontSize.SMALL)
            .fontColor(AppColors.TEXT_TERTIARY)
            .width('100%')
            .textAlign(TextAlign.Center)

          Column().height(32)
        }
        .width('100%')
        .padding({ left: AppSpacing.LG, right: AppSpacing.LG, top: AppSpacing.MD })
      }

      // ===== 弹窗层 =====
      AppDialog({
        showDialog: this.showSaveUrlDialog,
        dialogTitle: this.dialogTitle,
        dialogContent: this.dialogContent,
        confirmText: '保存',
        cancelText: '取消',
        onConfirm: (): void => { this.onSaveUrlConfirm() },
        onCancel: (): void => {}
      })
      AppDialog({
        showDialog: this.showClearCacheDialog,
        dialogTitle: this.dialogTitle,
        dialogContent: this.dialogContent,
        confirmText: '清除',
        cancelText: '取消',
        onConfirm: (): void => { this.onClearCacheConfirm() },
        onCancel: (): void => {}
      })
      AppDialog({
        showDialog: this.showUpdateUsernameDialog,
        dialogTitle: this.dialogTitle,
        dialogContent: this.dialogContent,
        confirmText: '确认修改',
        cancelText: '取消',
        onConfirm: (): void => { this.onUpdateUsernameConfirm() },
        onCancel: (): void => {}
      })
      AppDialog({
        showDialog: this.showUpdatePasswordDialog,
        dialogTitle: this.dialogTitle,
        dialogContent: this.dialogContent,
        confirmText: '确认修改',
        cancelText: '取消',
        onConfirm: (): void => { this.onUpdatePasswordConfirm() },
        onCancel: (): void => {}
      })
    }
    .width('100%')
    .height('100%')
  }
}
