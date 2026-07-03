/**
 * 图标名称常量
 */
export class AppIcons {
  static readonly USER: string = 'user'
  static readonly FOLDER: string = 'folder'
  static readonly ROBOT: string = 'robot'
  static readonly SETTINGS: string = 'settings'
  static readonly CHART: string = 'chart'
  static readonly COMPANY: string = 'company'
  static readonly MANAGER: string = 'manager'
  static readonly CHAT: string = 'chat'
  static readonly ANNOUNCEMENT: string = 'announcement'
  static readonly INFO: string = 'info'
  static readonly STAR: string = 'star'
  static readonly LOGOUT: string = 'logout'
}

function iconResource(name: string): Resource {
  switch (name) {
    case AppIcons.USER:
      return $r('app.media.icon_user')
    case AppIcons.FOLDER:
      return $r('app.media.icon_folder')
    case AppIcons.ROBOT:
      return $r('app.media.icon_robot')
    case AppIcons.SETTINGS:
      return $r('app.media.icon_settings')
    case AppIcons.CHART:
      return $r('app.media.icon_chart')
    case AppIcons.COMPANY:
      return $r('app.media.icon_company')
    case AppIcons.MANAGER:
      return $r('app.media.icon_manager')
    case AppIcons.CHAT:
      return $r('app.media.icon_chat')
    case AppIcons.ANNOUNCEMENT:
      return $r('app.media.icon_announcement')
    case AppIcons.STAR:
      return $r('app.media.icon_star')
    case AppIcons.LOGOUT:
      return $r('app.media.icon_logout')
    default:
      return $r('app.media.icon_info')
  }
}

/**
 * SVG 图标组件
 * 使用 media 目录下的 SVG 资源，通过 fillColor 着色
 */
@Component
export struct SvgIcon {
  @Prop iconName: string = AppIcons.INFO
  @Prop iconSize: number = 24
  @Prop iconColor: ResourceColor = '#007AFF'

  build() {
    Image(iconResource(this.iconName))
      .width(this.iconSize)
      .height(this.iconSize)
      .fillColor(this.iconColor)
      .objectFit(ImageFit.Contain)
  }
}
