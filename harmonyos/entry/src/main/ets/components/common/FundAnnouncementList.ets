import { AppColors, AppRadius, AppFontSize, AppSpacing } from '../../common/constants/AppConstants'
import { FundAnnouncement } from '../../common/types'

/**
 * 基金公告列表
 */
@Preview
@Component
export struct FundAnnouncementList {
  @Prop announcements: FundAnnouncement[] = []
  /** 点击公告跳转到详情，由父组件传入 */
  onNavigateToAnnouncement: (id: number) => void = (): void => {}

  build() {
    Column({ space: AppSpacing.MD }) {
      Text('基金公告')
        .fontSize(AppFontSize.BODY_LARGE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      if (this.announcements.length === 0) {
        Text('暂无公告')
          .fontSize(AppFontSize.SMALL)
          .fontColor(AppColors.TEXT_TERTIARY)
          .height(40)
      } else {
        ForEach(this.announcements, (a: FundAnnouncement, i: number) => {
          Column() {
            Row({ space: AppSpacing.SM }) {
              Column({ space: 4 }) {
                Text(a.title)
                  .fontSize(AppFontSize.BODY)
                  .fontColor(AppColors.TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                Text(a.publishDate)
                  .fontSize(AppFontSize.SMALL)
                  .fontColor(AppColors.TEXT_TERTIARY)
                  .width('100%')
              }
              .layoutWeight(1)

              Text('>')
                .fontSize(AppFontSize.BODY)
                .fontColor(AppColors.TEXT_TERTIARY)
                .margin({ left: 4 })
            }
            .width('100%')
            .padding({ top: AppSpacing.SM, bottom: AppSpacing.SM })
            .onClick((): void => {
              const announceId: number = a.id != null ? a.id : -1
              console.info('FUND_CLICK', '点击公告 id=' + announceId + ', title=' + a.title)
              this.onNavigateToAnnouncement(announceId)
            })
          }
          .width('100%')

          if (i < this.announcements.length - 1) {
            Row().width('100%').height(0.5).backgroundColor(AppColors.DIVIDER)
          }
        })
      }
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.WHITE)
    .borderRadius(AppRadius.CARD)
  }
}
