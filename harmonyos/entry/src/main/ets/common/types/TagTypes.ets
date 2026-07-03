export interface TagInfo {
  id: number
  name: string
  dimension: string
  parentId: number | null
  children?: TagInfo[]
}

export interface TagTree {
  id: number
  name: string
  dimension: string
  children?: TagTree[]
}