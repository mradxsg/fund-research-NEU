import { StorageManager } from './StorageManager'
import { FundInfo } from '../../common/types/FundTypes'
import { NavSeries } from '../../common/types/NavTypes'
import { CompanyInfo } from '../../common/types/CompanyTypes'
import { ManagerInfo } from '../../common/types/ManagerTypes'
import { TagTree } from '../../common/types/TagTypes'
import { Portfolio } from '../../common/types/PortfolioTypes'
import { UserSession } from '../../common/types/UserTypes'
import { FundAnnouncement } from '../../common/types/AnnouncementTypes'
import { FundHoldings } from '../../common/types/HoldingTypes'
import { FundDetailResult } from '../../common/types/ApiTypes'
import {
  FUND_LIST_POLICY, FUND_DETAIL_POLICY, NAV_HISTORY_POLICY,
  COMPANY_LIST_POLICY, MANAGER_LIST_POLICY, TAG_TREE_POLICY,
  PORTFOLIO_POLICY, USER_SESSION_POLICY
} from '../../common/types/CacheTypes'

const DEFAULT_BASE_URL: string = 'http://10.38.162.203:8080'

function fundDetailKey(id: number): string {
  return 'fund_detail_' + id
}

export class AppCache {
  static async getFundList(): Promise<FundInfo[] | null> {
    const entry = await StorageManager.getInstance().get<FundInfo[]>('fund_list')
    if (entry != null) { return entry.data }
    return null
  }
  static async getFundListForce(): Promise<FundInfo[] | null> {
    const entry = await StorageManager.getInstance().getForce<FundInfo[]>('fund_list')
    if (entry != null) { return entry.data }
    return null
  }
  static async setFundList(data: FundInfo[]): Promise<void> {
    await StorageManager.getInstance().put<FundInfo[]>('fund_list', data, FUND_LIST_POLICY)
  }

  static async getFundDetail(id: number): Promise<FundDetailResult | null> {
    const entry = await StorageManager.getInstance().get<FundDetailResult>(fundDetailKey(id))
    if (entry != null) { return entry.data }
    return null
  }

  static async setFundDetail(id: number, data: FundDetailResult): Promise<void> {
    await StorageManager.getInstance().put<FundDetailResult>(fundDetailKey(id), data, FUND_DETAIL_POLICY)
  }

  static async getCompanyList(): Promise<CompanyInfo[] | null> {
    const entry = await StorageManager.getInstance().get<CompanyInfo[]>('company_list')
    if (entry != null) { return entry.data }
    return null
  }
  static async setCompanyList(data: CompanyInfo[]): Promise<void> {
    await StorageManager.getInstance().put<CompanyInfo[]>('company_list', data, COMPANY_LIST_POLICY)
  }

  static async getTagTree(dimension: string): Promise<TagTree[] | null> {
    const entry = await StorageManager.getInstance().get<TagTree[]>('tag_tree_' + dimension)
    if (entry != null) { return entry.data }
    return null
  }
  static async setTagTree(dimension: string, data: TagTree[]): Promise<void> {
    await StorageManager.getInstance().put<TagTree[]>('tag_tree_' + dimension, data, TAG_TREE_POLICY)
  }

  static async getUserSession(): Promise<UserSession | null> {
    const entry = await StorageManager.getInstance().get<UserSession>('user_session')
    if (entry != null) { return entry.data }
    return null
  }
  static async setUserSession(data: UserSession): Promise<void> {
    await StorageManager.getInstance().put<UserSession>('user_session', data, USER_SESSION_POLICY)
  }
  static async clearUserSession(): Promise<void> {
    await StorageManager.getInstance().remove('user_session')
  }

  static async clearAll(): Promise<void> {
    await StorageManager.getInstance().clear()
  }

  // ---- 后端地址持久化 ----

  static async getBaseUrl(): Promise<string> {
    const entry = await StorageManager.getInstance().get<string>('base_url')
    if (entry != null) { return entry.data }
    return DEFAULT_BASE_URL
  }

  static async setBaseUrl(url: string): Promise<void> {
    await StorageManager.getInstance().put<string>('base_url', url, { ttl: 0 })
  }
}
