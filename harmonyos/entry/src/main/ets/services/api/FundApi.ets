import { HttpClient } from '../HttpClient'
import { ApiResponse, FundPageResult, FundDetailResult, FundInfo } from '../../common/types'

export class FundApi {
  static async list(params: Record<string, string>): Promise<FundPageResult | null> {
    const res = await HttpClient.get<ApiResponse<FundPageResult>>('/api/funds', params)
    if (res != null) { return res.data }
    return null
  }

  static async detail(id: number): Promise<FundDetailResult | null> {
    const res = await HttpClient.get<ApiResponse<FundDetailResult>>('/api/funds/' + id)
    if (res != null) { return res.data }
    return null
  }

  static async getByCode(code: string): Promise<FundInfo | null> {
    const res = await HttpClient.get<ApiResponse<FundInfo>>('/api/funds/code/' + code)
    if (res != null) { return res.data }
    return null
  }

  /** 获取基金类型列表（动态从后端加载） */
  static async getTypes(): Promise<string[] | null> {
    const res = await HttpClient.get<ApiResponse<string[]>>('/api/funds/types')
    if (res != null && res.data != null) { return res.data }
    return null
  }
}


