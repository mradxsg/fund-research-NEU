import { Portfolio, PortfolioSummary } from '../common/types'

export function getPortfolioFundCount(portfolio: Portfolio): number {
  if (portfolio.fundCount != null) {
    return portfolio.fundCount
  }
  if (portfolio.funds != null) {
    return portfolio.funds.length
  }
  if (portfolio.items != null) {
    return portfolio.items.length
  }
  return 0
}

export function calcPortfolioSummary(portfolios: Portfolio[]): PortfolioSummary {
  let fundCount = 0
  for (const p of portfolios) {
    fundCount += getPortfolioFundCount(p)
  }
  return {
    portfolioCount: portfolios.length,
    fundCount: fundCount
  }
}

export function resolveUserId(linkedUserId: number): number {
  if (linkedUserId > 0) {
    return Math.floor(linkedUserId)
  }
  const stored: Object | undefined = AppStorage.get('user_id')
  if (stored == null) {
    return 0
  }
  if (typeof stored === 'number') {
    return Math.floor(stored)
  }
  const parsed: number = parseInt('' + stored, 10)
  return isNaN(parsed) ? 0 : parsed
}

export function initAppSessionStorage(): void {
  AppStorage.setOrCreate('user_logged', false)
  AppStorage.setOrCreate('user_id', 0)
  AppStorage.setOrCreate('user_name', '')
}
