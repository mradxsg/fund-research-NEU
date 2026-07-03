import router from '@ohos.router'
import { MainPageContainer } from '../components/page-shell/MainPageContainer'
import { getLaunchFundCode } from '../entryability/EntryAbility'

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    // 检测从 SplashPage 传入的基金ID参数（来自元服务启动）
    const params = router.getParams() as Record<string, Object>
    if (params != null && params['navToFundId'] != null) {
      const fundId = params['navToFundId'] as number
      if (fundId > 0) {
        // 延迟一帧确保页面渲染完成后再导航
        setTimeout(() => {
          AppStorage.set('nav_page', 'fundDetail')
          AppStorage.set('nav_param', fundId)
        }, 100)
      }
    }
  }

  build() {
    Column() {
      MainPageContainer()
    }
    .width('100%')
    .height('100%')
  }
}
