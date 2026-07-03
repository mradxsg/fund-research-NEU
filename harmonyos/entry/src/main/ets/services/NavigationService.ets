/**
 * 导航服务 — 独立文件，避免循环依赖
 * MainPageContainer 和所有子页面都引用此文件而不是互相引用
 */

export interface NavEntry {
  page: string
  param: number
}

/** 记录上一次的 nav_page，用于计算页面过渡方向（全局变量） */
let prevNavPage: string = ''

/**
 * 全局导航函数：推入一个新页面（前进）
 * 用于右侧详情页内部的跳转（如基金详情→基金经理），支持逐级返回
 * 将当前页压入栈，返回时从栈弹出
 */
export function navPushTo(page: string, param: number): void {
  const stackStr: string = AppStorage.get<string>('nav_stack') || '[]'
  const stackArr: NavEntry[] = JSON.parse(stackStr)
  const currentPage: string = AppStorage.get<string>('nav_page') || ''
  const currentParam: number = AppStorage.get<number>('nav_param') || 0
  // 保存旧页面用于动画方向
  prevNavPage = currentPage
  // 将当前页保存到栈中（记录完整路径）
  if (currentPage !== '') {
    stackArr.push({ page: currentPage, param: currentParam })
  }
  AppStorage.set('nav_stack', JSON.stringify(stackArr))
  AppStorage.set('nav_dir', 'push')
  AppStorage.set('nav_param', param)
  AppStorage.set('nav_page', page)
}

/**
 * 替换导航：清空导航栈，直接跳转到新页面
 * 用于左侧列表点击（平行视界下替换右侧面板）
 * 返回时会直接关闭右侧面板，不会回到上一个页面
 */
export function navReplaceTo(page: string, param: number): void {
  prevNavPage = AppStorage.get<string>('nav_page') || ''
  AppStorage.set('nav_stack', '[]')
  AppStorage.set('nav_dir', 'push')
  AppStorage.set('nav_param', param)
  AppStorage.set('nav_page', page)
  // 发送刷新信号，让平行视界右面板同步参数（即使 navPage 没变）
  AppStorage.set('nav_parallel_refresh', Date.now())
}

/**
 * 获取上一个导航页面（用于方向计算）
 */
export function getPrevNavPage(): string {
  return prevNavPage
}

/**
 * 设置上一个导航页面
 */
export function setPrevNavPage(page: string): void {
  prevNavPage = page
}
