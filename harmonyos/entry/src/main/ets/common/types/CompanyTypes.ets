export interface CompanyInfo {
  id: number
  name: string
  description: string
  fundCount?: number
}

export interface CompanyListData {
  total: number
  page: number
  pageSize: number
  items: CompanyInfo[]
}