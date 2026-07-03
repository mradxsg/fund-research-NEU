import { HttpClient } from '../HttpClient'
import { ApiResponse, FundAnnouncement } from '../../common/types'

export class AnnouncementApi {
  static async detail(id: number): Promise<FundAnnouncement | null> {
    const res = await HttpClient.get<ApiResponse<FundAnnouncement>>('/api/funds/announcement/' + id)
    if (res != null) { return res.data }
    return null
  }
}
