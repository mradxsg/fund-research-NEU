export interface NavPoint {
  date: string
  unitNav: number
  accumNav: number
  dailyReturn?: number
}

export interface NavSeries {
  oneMonth: NavPoint[]
  threeMonth: NavPoint[]
  sixMonth: NavPoint[]
  oneYear: NavPoint[]
}
