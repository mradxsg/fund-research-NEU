import { preferences } from '@kit.ArkData'
import { CacheEntry, CachePolicy, CacheSource } from '../../common/types/CacheTypes'
import { common } from '@kit.AbilityKit'

export class StorageManager {
  private static instance: StorageManager | null = null
  private pref: preferences.Preferences | null = null
  private readonly STORE_NAME: string = 'fund_app_cache'

  private constructor() {}

  static getInstance(): StorageManager {
    if (StorageManager.instance == null) {
      StorageManager.instance = new StorageManager()
    }
    return StorageManager.instance
  }

  async init(context: common.Context): Promise<void> {
    if (this.pref != null) return
    this.pref = await preferences.getPreferences(context, this.STORE_NAME)
  }

  async put<T>(key: string, data: T, policy: CachePolicy): Promise<void> {
    if (this.pref == null) { throw new Error('StorageManager not initialized') }
    const now: number = Date.now()
    const entry: CacheEntry<T> = {
      data: data,
      cachedTime: now,
      expireTime: policy.ttl > 0 ? now + policy.ttl : 0,
      source: CacheSource.NETWORK
    }
    await this.pref.put(key, JSON.stringify(entry))
    await this.pref.flush()
  }

  async get<T>(key: string): Promise<CacheEntry<T> | null> {
    if (this.pref == null) return null
    const json: string = await this.pref.get(key, '') as string
    if (json === '') return null
    try {
      const parsed: CacheEntry<T> = JSON.parse(json) as CacheEntry<T>
      if (parsed.expireTime > 0 && Date.now() > parsed.expireTime) return null
      parsed.source = CacheSource.CACHE
      return parsed
    } catch (e) {
      return null
    }
  }

  async getForce<T>(key: string): Promise<CacheEntry<T> | null> {
    if (this.pref == null) return null
    const json: string = await this.pref.get(key, '') as string
    if (json === '') return null
    try {
      const parsed: CacheEntry<T> = JSON.parse(json) as CacheEntry<T>
      parsed.source = CacheSource.CACHE
      return parsed
    } catch (e) {
      return null
    }
  }

  async hasValid(key: string): Promise<boolean> {
    if (this.pref == null) return false
    const json: string = await this.pref.get(key, '') as string
    if (json === '') return false
    try {
      const parsed: Record<string, Object> = JSON.parse(json) as Record<string, Object>
      const expireTime: number = parsed['expireTime'] as number
      return expireTime === 0 || Date.now() <= expireTime
    } catch (e) {
      return false
    }
  }

  async remove(key: string): Promise<void> {
    if (this.pref == null) return
    await this.pref.delete(key)
    await this.pref.flush()
  }

  async clear(): Promise<void> {
    if (this.pref == null) return
    await this.pref.clear()
    await this.pref.flush()
  }
}