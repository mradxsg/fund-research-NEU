import { HttpClient } from '../HttpClient'
import { ApiResponse, Portfolio, PortfolioListData, PortfolioSummary } from '../../common/types'

class CreatePortfolioBody {
  userId: number
  name: string
  fundIds: number[]

  constructor(userId: number, name: string, fundIds: number[]) {
    this.userId = userId
    this.name = name
    this.fundIds = fundIds
  }
}

class RenamePortfolioBody {
  name: string

  constructor(name: string) {
    this.name = name
  }
}

class AddFundsBody {
  fundIds: number[]

  constructor(fundIds: number[]) {
    this.fundIds = fundIds
  }
}

function unwrapApiData<T>(res: ApiResponse<T> | null): T | null {
  if (res == null || res.data == null) {
    return null
  }
  if (res.code != null && res.code !== 200) {
    return null
  }
  return res.data
}

export class PortfolioApi {
  static async create(userId: number, name: string, fundIds: number[]): Promise<Portfolio | null> {
    const body: CreatePortfolioBody = new CreatePortfolioBody(userId, name, fundIds)
    const res = await HttpClient.post<ApiResponse<Portfolio>>('/api/portfolios', body)
    return unwrapApiData(res)
  }

  static async list(userId: number): Promise<PortfolioListData | null> {
    const res = await HttpClient.get<ApiResponse<PortfolioListData>>('/api/portfolios', { 'userId': '' + userId })
    return unwrapApiData(res)
  }

  static async getSummary(userId: number): Promise<PortfolioSummary | null> {
    const res = await HttpClient.get<ApiResponse<PortfolioSummary>>('/api/portfolios/summary', { 'userId': '' + userId })
    return unwrapApiData(res)
  }

  static async detail(id: number): Promise<Portfolio | null> {
    const res = await HttpClient.get<ApiResponse<Portfolio>>('/api/portfolios/' + id)
    return unwrapApiData(res)
  }

  static async delete(id: number): Promise<void> {
    await HttpClient.delete<ApiResponse<null>>('/api/portfolios/' + id)
  }

  static async rename(id: number, name: string): Promise<Portfolio | null> {
    const body: RenamePortfolioBody = new RenamePortfolioBody(name)
    const res = await HttpClient.put<ApiResponse<Portfolio>>('/api/portfolios/' + id + '/rename', body)
    return unwrapApiData(res)
  }

  static async addFunds(id: number, fundIds: number[]): Promise<Portfolio | null> {
    const body: AddFundsBody = new AddFundsBody(fundIds)
    const res = await HttpClient.post<ApiResponse<Portfolio>>('/api/portfolios/' + id + '/funds', body)
    return unwrapApiData(res)
  }

  static async removeFund(id: number, fundId: number): Promise<boolean> {
    const res = await HttpClient.delete<ApiResponse<null>>('/api/portfolios/' + id + '/funds/' + fundId)
    return res != null
  }
}
