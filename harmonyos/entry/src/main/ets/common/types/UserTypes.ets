export interface UserInfo {
  id: number
  username: string
  createdAt: string
}

export interface LoginRequest {
  username: string
  password: string
}

export interface RegisterRequest {
  username: string
  password: string
}

export interface UserAuthResponse {
  userId: number
  id?: number
  username: string
}

export interface UserSession {
  userId: number
  username: string
  loginTime: number
}