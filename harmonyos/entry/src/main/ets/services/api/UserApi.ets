import { HttpClient } from '../HttpClient'
import { ApiResponse, UserAuthResponse } from '../../common/types'

export class UserApi {
  static async register(username: string, password: string): Promise<ApiResponse<UserAuthResponse> | null> {
    const body: Record<string, string> = { 'username': username, 'password': password }
    const res = await HttpClient.post<ApiResponse<UserAuthResponse>>('/api/user/register', body)
    return res
  }

  static async login(username: string, password: string): Promise<ApiResponse<UserAuthResponse> | null> {
    const body: Record<string, string> = { 'username': username, 'password': password }
    const res = await HttpClient.post<ApiResponse<UserAuthResponse>>('/api/user/login', body)
    return res
  }

  static async updateUsername(userId: number, newUsername: string, password: string): Promise<ApiResponse<null> | null> {
    const body: Record<string, Object> = { 'userId': userId, 'newUsername': newUsername, 'password': password }
    const res = await HttpClient.put<ApiResponse<null>>('/api/user/updateUsername', body)
    return res
  }

  static async updatePassword(userId: number, oldPassword: string, newPassword: string): Promise<ApiResponse<null> | null> {
    const body: Record<string, Object> = { 'userId': userId, 'oldPassword': oldPassword, 'newPassword': newPassword }
    const res = await HttpClient.put<ApiResponse<null>>('/api/user/updatePassword', body)
    return res
  }
}

