import { AppColors, AppSpacing, AppFontSize, AppRadius } from '../../common/constants/AppConstants'
import { GenericPage } from '../common/GenericPage'
import { AnnouncementApi } from '../../services/api/AnnouncementApi'
import { FundAnnouncement } from '../../common/types'
import { LoadingIndicator } from '../base/LoadingIndicator'

@Preview
@Component
export struct AnnouncementDetailPage {
  @StorageLink('nav_param') @Watch('onNavParamChange') navParam: number = 0
  @StorageLink('nav_page') navPage: string = ''
  @State announcement: FundAnnouncement | null = null
  @State isLoading: boolean = false
  @State isError: boolean = false

  onBack: () => void = (): void => {}

  aboutToAppear(): void {
    this.loadAnnouncement()
  }

  onNavParamChange(): void {
    if (this.navPage === 'announcementDetail') {
      this.loadAnnouncement()
    }
  }

  async loadAnnouncement(): Promise<void> {
    if (this.navParam <= 0) {
      const title: string = AppStorage.get<string>('ann_title') || ''
      const date: string = AppStorage.get<string>('ann_date') || ''
      const content: string = AppStorage.get<string>('ann_content') || ''
      if (title !== '') {
        this.announcement = { id: this.navParam, title: title, publishDate: date, content: content }
      }
      return
    }
    this.isLoading = true
    this.isError = false
    const result = await AnnouncementApi.detail(this.navParam)
    if (result != null) {
      this.announcement = result
    } else {
      const title: string = AppStorage.get<string>('ann_title') || ''
      const date: string = AppStorage.get<string>('ann_date') || ''
      const content: string = AppStorage.get<string>('ann_content') || ''
      if (title !== '') {
        this.announcement = { id: this.navParam, title: title, publishDate: date, content: content }
      } else {
        this.isError = true
      }
    }
    this.isLoading = false
  }

  build() {
    Stack() {
      GenericPage({
        pageTitle: this.announcement != null ? this.announcement.title : '公告详情',
        showBack: true,
        onBack: this.onBack
      }) {
        if (this.navPage !== 'announcementDetail') {
          Stack().height(360)
        } else if (this.isLoading) {
          LoadingIndicator({ mode: 'spinner', loadText: '加载公告详情...' })
            .height(360)
        } else if (this.isError || this.announcement == null) {
          Column() {
            Text('暂无公告')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          // GenericPage 外部已包裹 Scroll，这里不需要再套 Scroll
          Column({ space: AppSpacing.MD }) {
            Column({ space: AppSpacing.SM }) {
              Text(this.announcement.title)
                .fontSize(AppFontSize.BODY_LARGE)
                .fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold)
                .width('100%')

              Text(this.announcement.publishDate)
                .fontSize(AppFontSize.SMALL)
                .fontColor(AppColors.TEXT_TERTIARY)
                .width('100%')

              Row().width('100%').height(0.5).backgroundColor(AppColors.DIVIDER)
                .margin({ top: AppSpacing.SM, bottom: AppSpacing.SM })

              if (this.announcement.content != null && this.announcement.content !== '') {
                Text(this.announcement.content)
                  .fontSize(AppFontSize.BODY)
                  .fontColor(AppColors.TEXT_SECONDARY)
                  .lineHeight(24)
                  .width('100%')
              } else {
                Text('暂无公告正文')
                  .fontSize(AppFontSize.BODY)
                  .fontColor(AppColors.TEXT_TERTIARY)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ top: AppSpacing.XL, bottom: AppSpacing.XL })
              }
            }
            .width('100%')
            .padding(AppSpacing.LG)
            .backgroundColor(AppColors.WHITE)
            .borderRadius(AppRadius.CARD)

            Column().height(24)
          }
          .width('100%')
          .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}
