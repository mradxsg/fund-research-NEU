// ===== AppConstants.ets =====
// 应用全局常量定义

// 颜色
export class AppColors {
  static readonly PRIMARY: string = '#007AFF'
  static readonly PRIMARY_LIGHT: string = '#E8F2FF'
  static readonly BACKGROUND: string = '#F5F6FA'
  static readonly WHITE: string = '#FFFFFF'
  static readonly TEXT_PRIMARY: string = '#1A1A1A'
  static readonly TEXT_SECONDARY: string = '#666666'
  static readonly TEXT_TERTIARY: string = '#999999'
  static readonly DIVIDER: string = '#EEEEEE'
  static readonly TAB_INACTIVE: string = '#999999'
  static readonly TAB_ACTIVE: string = '#007AFF'
  static readonly BLUR_BG: string = 'rgba(255,255,255,0.80)'
  static readonly TOPBAR_BG: string = 'rgba(255,255,255,0.45)'
  static readonly SHADOW: string = 'rgba(0,0,0,0.10)'
  static readonly CARD_BG: string = '#FFFFFF'
  static readonly ERROR: string = '#FF3B30'
  static readonly SUCCESS: string = '#34C759'
  static readonly WARNING: string = '#FF9500'
}

// 渐变色（浅色/深色模式）
export class AppGradientColors {
  // 浅色模式
  static readonly LIGHT_TOP: string = '#E8F2FF'
  static readonly LIGHT_BOTTOM: string = '#FFF5E8'
  // 深色模式
  static readonly DARK_TOP: string = '#1a1a2e'
  static readonly DARK_BOTTOM: string = '#16213e'
}

// 字体大小
export class AppFontSize {
  static readonly TITLE: number = 22
  static readonly HEADING: number = 18
  static readonly BODY_LARGE: number = 16
  static readonly BODY: number = 14
  static readonly SMALL: number = 12
  static readonly TINY: number = 10
  static readonly TAB_ICON: number = 26
  static readonly TAB_TEXT: number = 11
}

// 圆角
export class AppRadius {
  static readonly SMALL: number = 4
  static readonly MEDIUM: number = 8
  static readonly LARGE: number = 12
  static readonly XLARGE: number = 16
  static readonly BOTTOMBAR: number = 30
  static readonly CARD: number = 12
  static readonly BUTTON: number = 8
  static readonly INPUT: number = 8
}

// 间距
export class AppSpacing {
  static readonly XS: number = 4
  static readonly SM: number = 8
  static readonly MD: number = 12
  static readonly LG: number = 16
  static readonly XL: number = 24
  static readonly XXL: number = 32
}

// 按钮高度
export class AppButtonHeight {
  static readonly SMALL: number = 32
  static readonly MEDIUM: number = 40
  static readonly LARGE: number = 48
}

// 高度常量
export class AppHeight {
  static readonly TOPBAR: number = 52
  static readonly BOTTOMBAR: number = 64
}

// 动画
export class AppAnimation {
  static readonly FAST: number = 150
  static readonly NORMAL: number = 250
  static readonly SLOW: number = 400
  static readonly BOTTOMBAR_TRANSITION: number = 200
  static readonly PAGE_SWITCH: number = 300
}

// 阴影
export class AppShadow {
  static readonly LIGHT_RADIUS: number = 6
  static readonly LIGHT_OFFSET_Y: number = 2
  static readonly LIGHT_COLOR: string = 'rgba(0,0,0,0.08)'

  static readonly TAB_RADIUS: number = 8
  static readonly TAB_OFFSET_Y: number = 3
  static readonly TAB_COLOR: string = 'rgba(0,122,255,0.25)'
}

// 布局
export class AppLayout {
  static readonly BOTTOMBAR_WIDTH_RATIO: number = 0.65
  static readonly BOTTOMBAR_WIDTH_RATIO_TABLET: number = 0.40
  static readonly BOTTOMBAR_BOTTOM_GAP: number = 28
  static readonly BOTTOMBAR_LEFT_GAP: number = 0
  static readonly BOTTOMBAR_HEIGHT: number = 62
  static readonly BOTTOMBAR_BLUR: number = 30
  static readonly TOPBAR_BLUR: number = 12
  static readonly BOTTOMBAR_BTN_COUNT: number = 5

  // 静态模式下各比例（以底部栏总宽度为基准）
  static readonly STATIC_BTN_WIDTH_RATIO: number = 0.20
  static readonly STATIC_GAP_RATIO: number = 0.08
  static readonly STATIC_EDGE_RATIO: number = 0.08

  // 动态模式下各比例
  static readonly DYNAMIC_BTN_WIDTH_RATIO: number = 0.25
  static readonly DYNAMIC_GAP_RATIO: number = 0
  static readonly DYNAMIC_EDGE_RATIO: number = 0

  // 图标变化
  static readonly ICON_SCALE_STATIC: number = 1.0
  static readonly ICON_SCALE_DYNAMIC: number = 1.2
}

// 响应式布局 — 平板适配
export class AppResponsive {
  /** 平板判定宽度阈值（dp） */
  static readonly TABLET_BREAKPOINT: number = 600
  /** 平板下内容最大宽度（dp） */
  static readonly CONTENT_MAX_WIDTH: number = 720
  /** 平板下水平内边距（dp） */
  static readonly PADDING_TABLET: number = 48
  /** 手机下水平内边距（dp） */
  static readonly PADDING_PHONE: number = 16
  /** 平板下底部栏最大宽度（dp） */
  static readonly BOTTOMBAR_MAX_WIDTH: number = 500
  /** 平板下卡片最大宽度（dp） */
  static readonly CARD_MAX_WIDTH: number = 680
}
