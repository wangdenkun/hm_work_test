import { AppOverlayWrapper, MoveAbleWrapperParams } from './AppOverlayWrapper'
import { ComponentContent, OverlayManager, UIContext, window } from '@kit.ArkUI'
import { HashMap } from '@kit.ArkTS'



interface AppOverlayWrapperBuildData {
  setting: MoveAbleWrapperParams,
  builder: WrappedBuilder<[]>
}

@Builder
function builderOverlay(setting: AppOverlayWrapperBuildData) {
  AppOverlayWrapper(
    {
      show: setting.setting.show,
      edges: setting.setting.edges,
      child: setting.builder.builder
    }
  )
    .position({ x: 0, y: 0 })
    .hitTestBehavior(HitTestMode.None)
}

/**
 * xxComponent 是与OverlayManager对齐的相关方法
 * xxOverlay 是新的方法 外部使用@Builder构建时不用关系OverlayManager的相关问题(添加一层Stack并设置position)
 *
 */
class AppOverlayManager {
  private constructor() {
  }

  private static instance: AppOverlayManager

  public static getInstance() {
    if (!AppOverlayManager.instance) {
      AppOverlayManager.instance = new AppOverlayManager()
    }
    return AppOverlayManager.instance
  }

  private overlayManager?: OverlayManager

  /**
   * 注册 OverlayManger
   * @param overlayManger
   */
  registerOverlayManger(overlayManger: OverlayManager) {
    this.overlayManager = overlayManger
  }

  /**
   * 存放悬浮节点
   */
  private overlayWindowNodes: HashMap<string, Content> = new HashMap()


  addComponentContent(content: ComponentContent<MoveAbleWrapperParams>, index?: number) {
    this.overlayManager?.addComponentContent(content, index)
  }

  addComponentContentForKey(content: ComponentContent<MoveAbleWrapperParams>, index?: number, type?: string) {
    if (type !== undefined) {
      if (this.overlayWindowNodes.hasKey(type)) {
        let component = this.overlayWindowNodes.get(type)
        this.overlayManager?.removeComponentContent(component)
      }
      this.overlayWindowNodes?.set(type, content)
    }
    this.overlayManager?.addComponentContent(content, index)
  }

  removeComponentContent(contentOrKey: ComponentContent<MoveAbleWrapperParams> | string) {
    if ((typeof contentOrKey) === 'string') {
      let overlayKey = contentOrKey as string
      let hasNode = this.overlayWindowNodes.hasKey(overlayKey)
      if (hasNode) {
        let component = this.overlayWindowNodes.get(overlayKey)
        this.overlayManager?.removeComponentContent(component)
        this.overlayWindowNodes.remove(overlayKey)
      }
    }
    if (contentOrKey instanceof ComponentContent) {
      this.overlayManager?.removeComponentContent(contentOrKey)
    }
  }

  showComponentContent(contentOrKey: ComponentContent<MoveAbleWrapperParams> | string) {
    if ((typeof contentOrKey) === 'string') {
      let overlayKey = contentOrKey as string
      let hasNode = this.overlayWindowNodes.hasKey(overlayKey)
      if (hasNode) {
        let component = this.overlayWindowNodes.get(overlayKey)
        this.overlayManager?.showComponentContent(component)
      }
    }
    if (contentOrKey instanceof ComponentContent) {
      this.overlayManager?.showComponentContent(contentOrKey)
    }
  }

  hideComponentContent(contentOrType: ComponentContent<MoveAbleWrapperParams> | string) {
    if ((typeof contentOrType) === 'string') {
      let overlayKey = contentOrType as string
      let hasNode = this.overlayWindowNodes.hasKey(overlayKey)
      if (hasNode) {
        let component = this.overlayWindowNodes.get(overlayKey)
        this.overlayManager?.hideComponentContent(component)
      }
    }
    if (contentOrType instanceof ComponentContent) {
      this.overlayManager?.hideComponentContent(contentOrType)
    }
  }

  showAllComponentContents() {
    this.overlayManager?.showAllComponentContents()
  }

  hideAllComponentContents() {
    this.overlayManager?.hideAllComponentContents()
  }

  /**
   * 存放悬浮构建信息
   */
  private overlayWindowsBuildData: HashMap<string, AppOverlayWrapperBuildData> = new HashMap()

  addOverlay(content: UIContext, builder: WrappedBuilder<[]>, setting: MoveAbleWrapperParams, tag: string,
    index?: number) {
    let hasSuchTagBuilder = this.overlayWindowNodes.hasKey(tag)
    if (hasSuchTagBuilder) {
      this.removeOverlay(tag)
    }
    let buildData = { setting: setting, builder: builder } as AppOverlayWrapperBuildData
    this.overlayWindowsBuildData.set(tag, buildData)
    let overlayNode: ComponentContent<AppOverlayWrapperBuildData> =
      new ComponentContent(
        content, wrapBuilder(builderOverlay),
        buildData,
        { nestingBuilderSupported: true }
      )
    this.overlayWindowNodes.set(tag, overlayNode)
    this.overlayManager?.addComponentContent(overlayNode, index)
  }

  removeOverlay(tag: string) {
    if (this.overlayWindowsBuildData.hasKey(tag)) {
      this.overlayWindowsBuildData.remove(tag)
    }
    if (this.overlayWindowNodes.hasKey(tag)) {
      this.overlayManager?.removeComponentContent(this.overlayWindowNodes.get(tag))
      let node = this.overlayWindowNodes.get(tag) as ComponentContent<AppOverlayWrapperBuildData>
      node.dispose()
      this.overlayWindowNodes.remove(tag)
    }
  }

  showOverlay(tag: string, setting?: MoveAbleWrapperParams) {
    if (this.overlayWindowNodes.hasKey(tag)) {
      this.overlayManager?.showComponentContent(this.overlayWindowNodes.get(tag))
    }
    if (setting) {
      if (this.overlayWindowsBuildData.hasKey(tag)) {
        this.updateSettingForOverlay(setting, tag)
      }
    }
  }

  hideOverlay(tag: string) {
    if (this.overlayWindowNodes.hasKey(tag)) {
      this.overlayManager?.hideComponentContent(this.overlayWindowNodes.get(tag))
      this.overlayWindowsBuildData.get(tag).setting.show = false
    }
  }

  updateSettingForOverlay(setting: MoveAbleWrapperParams, tag: string) {
    let hasNode = this.overlayWindowNodes.hasKey(tag)
    let hasBuilder = this.overlayWindowsBuildData.hasKey(tag)
    if (!hasNode || !hasBuilder) {
      return
    }
    let node = this.overlayWindowNodes.get(tag) as ComponentContent<AppOverlayWrapperBuildData>
    let builder = this.overlayWindowsBuildData.get(tag).builder
    this.overlayWindowsBuildData.get(tag).setting = setting
    node.update({
      setting: setting,
      builder: builder
    })
  }

  getOverlayIsShowing(tag: string) {
    let hasNode = this.overlayWindowNodes.hasKey(tag)
    if (!hasNode) return false
    let hasBuildInfo = this.overlayWindowsBuildData.hasKey(tag)
    if (!hasBuildInfo) return false
    let buildInfo = this.overlayWindowsBuildData.get(tag)
    return buildInfo.setting.show
  }

  getInfoOfOverlay(tag: string): MoveAbleWrapperParams | undefined {
    let hasBuildInfo = this.overlayWindowsBuildData.hasKey(tag)
    if (hasBuildInfo === false) return undefined
    return this.overlayWindowsBuildData.get(tag).setting
  }

}

const appOverlayManager = AppOverlayManager.getInstance()

export { appOverlayManager }