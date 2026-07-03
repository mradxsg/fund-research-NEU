export interface FundSector {
  id?: number
  fundId?: number
  sectorName: string
  ratio: number
}

export interface FundStock {
  id?: number
  fundId?: number
  stockName: string
  ratio: number
}

export interface FundHoldings {
  sectors: FundSector[]
  stocks: FundStock[]
}
