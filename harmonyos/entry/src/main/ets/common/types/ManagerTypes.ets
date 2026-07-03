export interface ManagerInfo {
  id: number
  name: string
  experienceYears: number
  companyName?: string
  fundCount?: number
}

export interface ManagerListData {
  total: number
  page: number
  pageSize: number
  items: ManagerInfo[]
}
