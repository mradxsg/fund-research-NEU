import { NavPoint } from './NavTypes'
import { FundSector, FundStock } from './HoldingTypes'
import { FundAnnouncement } from './AnnouncementTypes'

export interface FundInfo {
  id: number
  code: string
  name: string
  type?: string
  riskLevel?: string
  unitNav?: number
  dailyReturn?: number
  scale?: number
  establishDate?: string
  companyId?: number
  managerId?: number
  benchmark?: string
  attributionText?: string
  latestNav?: number
  latestAccumNav?: number
  latestNavDate?: string
  latestDailyReturn?: number
}

export interface FundProfile {
  id: number
  code: string
  name: string
  type: string
  scale: number
  establishDate: string
  companyId?: number
  companyName: string
  managerId?: number
  managerName: string
  riskLevel: string
  benchmark: string
  tags: string[]
  navSeries: NavPoint[]
  sectors: FundSector[]
  topHoldings: FundStock[]
  attributionText: string
  announcements: FundAnnouncement[]
}
