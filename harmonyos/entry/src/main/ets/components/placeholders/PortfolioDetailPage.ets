import { AppColors, AppFontSize, AppSpacing, AppRadius, AppButtonHeight } from '../../common/constants/AppConstants'
import { GenericPage } from '../common/GenericPage'
import { PortfolioFundItem } from '../common/PortfolioFundItem'
import { LoadingIndicator } from '../base/LoadingIndicator'
import { ErrorState } from '../base/ErrorState'
import { EmptyState } from '../base/EmptyState'
import { AppTextInput } from '../base/AppTextInput'
import { AppButton } from '../base/AppButton'
import { AppDialog } from '../base/AppDialog'
import { ToastUtil } from '../base/ToastUtil'
import { PortfolioApi } from '../../services/api/PortfolioApi'
import { FundApi } from '../../services/api/FundApi'
import { Portfolio, PortfolioFundItem as PortfolioFund } from '../../common/types'
import { navPushTo } from '../../services/NavigationService'

@Preview
@Component
export struct PortfolioDetailPage {
  @Prop portfolioId: number = 0
  @State detail: Portfolio | null = null
  @State isLoading: boolean = true
  @State hasError: boolean = false
  @State addFundCode: string = ''
  @State isAdding: boolean = false
  @State showRemoveDialog: boolean = false
  @State removeFundId: number = 0
  @State removeFundName: string = ''
  onBack: () => void = (): void => {}

  aboutToAppear(): void {
    this.loadDetail()
  }

  async loadDetail(): Promise<void> {
    this.isLoading = true
    this.hasError = false
    const result = await PortfolioApi.detail(this.portfolioId)
    if (result != null) {
      this.detail = result
    } else {
      this.hasError = true
    }
    this.isLoading = false
  }

  getFundList(): PortfolioFund[] {
    if (this.detail == null || this.detail.funds == null) {
      return []
    }
    return this.detail.funds
  }

  async addFundByCode(): Promise<void> {
    if (this.addFundCode.trim() === '') {
      ToastUtil.warning('请输入基金代码')
      return
    }
    this.isAdding = true

    // 通过基金代码查找基金ID
    const fundInfo = await FundApi.getByCode(this.addFundCode.trim())
    if (fundInfo == null) {
      ToastUtil.error('未找到该基金，请检查代码')
      this.isAdding = false
      return
    }

    const result = await PortfolioApi.addFunds(this.portfolioId, [fundInfo.id])
    this.isAdding = false
    if (result != null) {
      ToastUtil.success('基金已添加到组合')
      this.addFundCode = ''
      this.loadDetail()
    } else {
      ToastUtil.error('添加失败')
    }
  }

  confirmRemoveFund(fundId: number, fundName: string): void {
    this.removeFundId = fundId
    this.removeFundName = fundName
    this.showRemoveDialog = true
  }

  async removeFund(fundId: number): Promise<void> {
    const ok = await PortfolioApi.removeFund(this.portfolioId, fundId)
    if (ok) {
      ToastUtil.success('已从组合移除')
      this.loadDetail()
    } else {
      ToastUtil.error('移除失败')
    }
  }

  openFund(fundId: number): void {
    navPushTo('fundDetail', fundId)
  }

  @Builder
  DetailContent() {
    Column({ space: AppSpacing.MD }) {
      Column({ space: AppSpacing.SM }) {
        Text(this.detail!.name)
          .fontSize(AppFontSize.TITLE)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('共 ' + this.getFundList().length + ' 只基金')
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
          .width('100%')
      }
      .width('100%')
      .padding(AppSpacing.LG)
      .backgroundColor(AppColors.WHITE)
      .borderRadius(AppRadius.CARD)

      if (this.getFundList().length === 0) {
        EmptyState({
          emptyTitle: '组合内暂无基金',
          emptyDesc: '创建组合时选择的基金会显示在这里'
        })
          .height(220)
      } else {
        Column({ space: 0 }) {
          ForEach(this.getFundList(), (fund: PortfolioFund, index: number) => {
            Column() {
              PortfolioFundItem({
                fundCode: fund.fundCode,
                fundName: fund.fundName,
                fundType: fund.fundType,
                latestNav: fund.latestNav != null ? fund.latestNav : 0,
                showRemove: true,
                onItemClick: (): void => { this.openFund(fund.fundId) },
                onRemove: (): void => {
                  this.confirmRemoveFund(fund.fundId, fund.fundName)
                }
              })

              if (index < this.getFundList().length - 1) {
                Row()
                  .width('100%')
                  .height(0.5)
                  .backgroundColor(AppColors.DIVIDER)
                  .margin({ left: AppSpacing.LG, right: AppSpacing.LG })
              }
            }
          }, (fund: PortfolioFund) => fund.fundId.toString())
        }
        .width('100%')
        .backgroundColor(AppColors.WHITE)
        .borderRadius(AppRadius.CARD)
      }

      Column({ space: AppSpacing.MD }) {
        Text('添加基金')
          .fontSize(AppFontSize.BODY_LARGE)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Row({ space: AppSpacing.SM }) {
          TextInput({ placeholder: '输入基金代码，如 110011', text: this.addFundCode })
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(AppRadius.MEDIUM)
            .padding({ left: AppSpacing.MD })
            .fontSize(AppFontSize.BODY)
            .placeholderColor(AppColors.TEXT_TERTIARY)
            .onChange((v: string): void => { this.addFundCode = v })

          AppButton({
            btnLabel: this.isAdding ? '添加中...' : '添加',
            btnWidth: 80,
            btnHeight: 44,
            btnDisabled: this.isAdding,
            btnFontSize: AppFontSize.BODY,
            btnRadius: AppRadius.MEDIUM,
            onClickAction: (): void => { this.addFundByCode() }
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding(AppSpacing.LG)
      .backgroundColor(AppColors.WHITE)
      .borderRadius(AppRadius.CARD)

      Column().height(32)
    }
    .width('100%')
    .padding({ left: AppSpacing.LG, right: AppSpacing.LG })
  }

  build() {
    Stack() {
      GenericPage({
        pageTitle: this.detail != null ? this.detail.name : '组合详情',
        showBack: true,
        onBack: this.onBack
      }) {
        if (this.isLoading) {
          LoadingIndicator({ mode: 'spinner', loadText: '加载组合详情...' })
            .height(360)
        } else if (this.hasError || this.detail == null) {
          ErrorState({
            errTitle: '加载失败',
            errDesc: '无法获取组合详情',
            retryLabel: '重试',
            onRetry: (): void => { this.loadDetail() }
          })
            .height(360)
        } else {
          this.DetailContent()
        }
      }

      AppDialog({
        showDialog: this.showRemoveDialog,
        dialogTitle: '确认移除',
        dialogContent: '确定将「' + this.removeFundName + '」从该组合中移除吗？',
        confirmText: '移除',
        onConfirm: (): void => {
          this.removeFund(this.removeFundId)
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
