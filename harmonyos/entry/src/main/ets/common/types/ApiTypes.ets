import { FundInfo, FundProfile } from './FundTypes'
import { CompanyInfo } from './CompanyTypes'
import { ManagerInfo } from './ManagerTypes'
import { TagTree } from './TagTypes'

export interface ApiResponse<T> {
  code: number
  data: T
  message: string
}

export interface PageParams {
  keyword?: string
  tagIds?: string
  page?: number
  size?: number
}

export interface PageData<T> {
  records: T[]
  total: number
  pages: number
}

export interface FundPageResult extends PageData<FundInfo> {}

export interface FundDetailResult extends FundProfile {}

export interface CompanyPageResult extends PageData<CompanyInfo> {}

export interface ManagerPageResult extends PageData<ManagerInfo> {}

export interface TagTreeResult extends Array<TagTree> {}

export interface CreatePortfolioRequest {
  name: string
  fundIds: number[]
}

export interface AiChatRequest {
  message: string
}

export interface AiChatResponse {
  reply: string
}
