import { HttpClient } from '../HttpClient'
import { ApiResponse, TagTree } from '../../common/types'

export class TagApi {
  static async getTree(dimension: string): Promise<TagTree[] | null> {
    const res = await HttpClient.get<ApiResponse<TagTree[]>>('/api/tags', { 'dimension': dimension })
    if (res != null) { return res.data }
    return null
  }
}