export interface Portfolio {
  id: number
  userId: number
  name: string
  createdAt?: string
  createdTime?: string
  items?: PortfolioItem[]
  funds?: PortfolioFundItem[]
  fundCount?: number
}

export interface PortfolioItem {
  portfolioId: number
  fundId: number
  fundCode?: string
  fundName?: string
  latestNav?: number
}

export interface PortfolioFundItem {
  fundId: number
  fundCode: string
  fundName: string
  fundType: string
  latestNav?: number
}

export interface PortfolioSummary {
  portfolioCount: number
  fundCount: number
}

export type PortfolioListData = Portfolio[]
