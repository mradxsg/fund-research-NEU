import { HttpClient } from '../HttpClient'
import { ApiResponse, AiChatResponse } from '../../common/types'

export class AiApi {
  static async chat(message: string): Promise<string | null> {
    const body: Record<string, string> = { 'message': message }
    const res = await HttpClient.post<ApiResponse<AiChatResponse>>('/api/ai/chat', body)
    if (res != null && res.data != null) { return res.data.reply }
    return null
  }
}
