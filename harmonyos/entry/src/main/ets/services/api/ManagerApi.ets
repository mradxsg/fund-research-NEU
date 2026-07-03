import { HttpClient } from '../HttpClient'
import { ApiResponse, ManagerInfo, ManagerPageResult, FundPageResult } from '../../common/types'

export class ManagerApi {
  static async list(params: Record<string, string>): Promise<ManagerPageResult | null> {
    const res = await HttpClient.get<ApiResponse<ManagerPageResult>>('/api/managers', params)
    if (res != null) { return res.data }
    return null
  }

  static async detail(id: number): Promise<ManagerInfo | null> {
    const res = await HttpClient.get<ApiResponse<ManagerInfo>>('/api/managers/' + id)
    if (res != null) { return res.data }
    return null
  }

  static async funds(id: number, params: Record<string, string>): Promise<FundPageResult | null> {
    const res = await HttpClient.get<ApiResponse<FundPageResult>>('/api/managers/' + id + '/funds', params)
    if (res != null) { return res.data }
    return null
  }
}


