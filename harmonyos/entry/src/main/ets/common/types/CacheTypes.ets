export interface CacheEntry<T> {
  data: T
  cachedTime: number
  expireTime: number
  source: CacheSource
}

export enum CacheSource {
  NETWORK = 'network',
  CACHE = 'cache'
}

export interface CachePolicy {
  ttl: number
  maxEntries?: number
}

export const FUND_LIST_POLICY: CachePolicy = { ttl: 300000, maxEntries: 10 }
export const FUND_DETAIL_POLICY: CachePolicy = { ttl: 600000, maxEntries: 50 }
export const NAV_HISTORY_POLICY: CachePolicy = { ttl: 1800000, maxEntries: 20 }
export const COMPANY_LIST_POLICY: CachePolicy = { ttl: 300000, maxEntries: 5 }
export const MANAGER_LIST_POLICY: CachePolicy = { ttl: 300000, maxEntries: 5 }
export const TAG_TREE_POLICY: CachePolicy = { ttl: 600000, maxEntries: 3 }
export const PORTFOLIO_POLICY: CachePolicy = { ttl: 0 }
export const USER_SESSION_POLICY: CachePolicy = { ttl: 86400000 }
