import { promptAction } from '@kit.ArkUI'

/**
 * 系统级 Toast 工具（使用 promptAction.showToast）
 * 适合在代码任意处快速调用
 */
export class ToastUtil {
  static show(message: string, duration: number = 2000): void {
    try {
      promptAction.showToast({ message: message, duration: duration })
    } catch (e) {
      console.error('ToastUtil.show failed: ' + JSON.stringify(e))
    }
  }

  static success(message: string): void {
    ToastUtil.show('✅ ' + message)
  }

  static error(message: string): void {
    ToastUtil.show('❌ ' + message)
  }

  static warning(message: string): void {
    ToastUtil.show('⚠️ ' + message)
  }

  static info(message: string): void {
    ToastUtil.show('ℹ️ ' + message)
  }
}
