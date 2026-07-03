import { HttpClient } from '../HttpClient'
import { ApiResponse, CompanyInfo, CompanyPageResult, FundPageResult } from '../../common/types'

export class CompanyApi {
  static async list(params: Record<string, string>): Promise<CompanyPageResult | null> {
    const res = await HttpClient.get<ApiResponse<CompanyPageResult>>('/api/companies', params)
    if (res != null) { return res.data }
    return null
  }

  static async detail(id: number): Promise<CompanyInfo | null> {
    const res = await HttpClient.get<ApiResponse<CompanyInfo>>('/api/companies/' + id)
    if (res != null) { return res.data }
    return null
  }

  static async funds(id: number, params: Record<string, string>): Promise<FundPageResult | null> {
    const res = await HttpClient.get<ApiResponse<FundPageResult>>('/api/companies/' + id + '/funds', params)
    if (res != null) { return res.data }
    return null
  }
}


