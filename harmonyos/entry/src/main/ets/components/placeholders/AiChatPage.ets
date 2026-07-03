import { AppColors, AppFontSize, AppSpacing, AppRadius, AppButtonHeight, AppLayout, AppResponsive } from '../../common/constants/AppConstants'
import { TopBar } from '../common/TopBar'
import { LoadingIndicator } from '../base/LoadingIndicator'
import { AppButton } from '../base/AppButton'
import { AiApi } from '../../services/api/AiApi'

interface ChatMessage {
  role: string
  content: string
}

const STATUS_BAR_HEIGHT: number = 44
/** 顶栏总高度 = 状态栏 + 标题行 */
const TOPBAR_TOTAL: number = STATUS_BAR_HEIGHT + 48
const BOTTOM_INPUT_HEIGHT: number = 80

@Preview
@Component
export struct AiChatPage {
  @State messages: ChatMessage[] = []
  @State inputText: string = ''
  @State isLoading: boolean = false
  onBack: () => void = (): void => {}
  scrollCtrl: Scroller = new Scroller()

  async sendMessage(): Promise<void> {
    const text: string = this.inputText.trim()
    if (text === '' || this.isLoading) {
      return
    }

    this.messages = this.messages.concat([{ role: 'user', content: text }])
    this.inputText = ''
    this.isLoading = true

    const reply = await AiApi.chat(text)
    this.isLoading = false

    if (reply != null && reply !== '') {
      this.messages = this.messages.concat([{ role: 'ai', content: reply }])
    } else {
      this.messages = this.messages.concat([{ role: 'ai', content: '抱歉，我暂时无法回答这个问题。' }])
    }
  }

  @Builder
  MessageList() {
    Column({ space: AppSpacing.MD }) {
      // 占位：与悬浮 topBar 同高
      Column()
        .height(TOPBAR_TOTAL)
        .width('100%')

      if (this.messages.length === 0) {
        Column({ space: AppSpacing.SM }) {
          Text('AI 基金助手')
            .fontSize(AppFontSize.HEADING)
            .fontColor(AppColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)

          Text('可以询问基金筛选、风险理解、组合分析等问题。')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(AppSpacing.XL)
        .alignItems(HorizontalAlign.Center)
      }

      ForEach(this.messages, (msg: ChatMessage, index: number) => {
        Column({ space: 4 }) {
          Text(msg.role === 'user' ? '我' : 'AI')
            .fontSize(AppFontSize.SMALL)
            .fontColor(msg.role === 'user' ? AppColors.PRIMARY : AppColors.SUCCESS)
            .fontWeight(FontWeight.Bold)
            .width('100%')

          Text(msg.content)
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
            .lineHeight(22)
            .width('100%')
        }
        .width('100%')
        .padding(AppSpacing.MD)
        .backgroundColor(msg.role === 'user' ? AppColors.PRIMARY_LIGHT : AppColors.WHITE)
        .borderRadius(AppRadius.MEDIUM)
        .alignItems(HorizontalAlign.Start)
      }, (_msg: ChatMessage, index: number) => index.toString())

      if (this.isLoading) {
        LoadingIndicator({ mode: 'spinner', loadText: 'AI 思考中...' })
          .height(60)
      }

      // 底部输入栏占位
      Column()
        .height(BOTTOM_INPUT_HEIGHT)
        .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.LG)
  }

  build() {
    Stack() {
      // === 内容层 ===
      Scroll(this.scrollCtrl) {
        Column() {
          this.MessageList()
        }
        .width('100%')
        .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // === 悬浮 TopBar ===
      TopBar({
        pageTitle: 'AI 助手',
        showBack: true,
        onBack: this.onBack
      })
      .position({ top: 0 })

      // === 底部输入栏（悬浮） — 平板下居中最大宽度 ===
      Column() {
        Row({ space: AppSpacing.SM }) {
          TextInput({ placeholder: '输入你的问题...', text: this.inputText })
            .layoutWeight(1)
            .height(44)
            .backgroundColor(AppColors.WHITE)
            .borderRadius(AppRadius.MEDIUM)
            .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
            .placeholderColor(AppColors.TEXT_TERTIARY)
            .onChange((v: string): void => { this.inputText = v })
            .onSubmit((_val: EnterKeyType): void => { this.sendMessage() })

          AppButton({
            btnLabel: '发送',
            btnWidth: 72,
            btnHeight: AppButtonHeight.MEDIUM,
            btnDisabled: this.isLoading,
            onClickAction: (): void => { this.sendMessage() }
          })
        }
        .width('100%')
        .constraintSize({ maxWidth: AppResponsive.CONTENT_MAX_WIDTH })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(AppColors.BACKGROUND)
      .padding({
        left: AppSpacing.LG,
        right: AppSpacing.LG,
        top: AppSpacing.SM,
        bottom: AppSpacing.LG
      })
      .position({ bottom: 0 })
    }
    .width('100%')
    .height('100%')
  }
}
