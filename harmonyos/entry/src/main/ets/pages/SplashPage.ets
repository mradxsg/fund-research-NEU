import router from '@ohos.router'
import { AppCache } from '../services/storage/AppCache'
import { initAppSessionStorage } from '../services/PortfolioStats'
import { getLaunchFundCode } from '../entryability/EntryAbility'
import { FundApi } from '../services/api/FundApi'

const SPLASH_TIMEOUT: number = 5000

@Entry
@Component
struct SplashPage {
  @State statusText: string = '正在加载...'

  async aboutToAppear(): Promise<void> {
    initAppSessionStorage()
    await this.waitForSession()
  }

  async waitForSession(): Promise<void> {
    this.statusText = '正在验证登录状态...'

    const result = await Promise.race([
      this.tryRestoreSession(),
      this.timeout(SPLASH_TIMEOUT)
    ])

    if (result === 'timeout') {
      this.statusText = '即将进入...'
    } else {
      this.statusText = '登录成功，即将进入...'
    }

    await this.delay(600)

    // 检测是否从元服务（桌面卡片/快捷方式）启动
    const launchCode = getLaunchFundCode()
    if (launchCode != null) {
      // 从基金代码查询基金ID，然后导航到详情页
      const fundInfo = await FundApi.getByCode(launchCode)
      if (fundInfo != null && fundInfo.id > 0) {
        router.replaceUrl({
          url: 'pages/Index',
          params: { 'navToFundId': fundInfo.id }
        })
        return
      }
    }

    router.replaceUrl({ url: 'pages/Index' })
  }

  async tryRestoreSession(): Promise<'session' | 'timeout'> {
    const session = await AppCache.getUserSession()
    if (session != null) {
      AppStorage.set('user_logged', true)
      AppStorage.set('user_id', session.userId)
      AppStorage.set('user_name', session.username)
      return 'session'
    }
    return 'timeout'
  }

  timeout(ms: number): Promise<'timeout'> {
    return new Promise<'timeout'>((resolve) => {
      setTimeout(() => { resolve('timeout') }, ms)
    })
  }

  delay(ms: number): Promise<void> {
    return new Promise<void>((resolve) => {
      setTimeout(() => { resolve() }, ms)
    })
  }

  build() {
    Column() {
      Column() {
        Image($r('app.media.startIcon'))
          .width(100)
          .height(100)
          .objectFit(ImageFit.Contain)

        Text(this.statusText)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 24 })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
