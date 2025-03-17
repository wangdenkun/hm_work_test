import { display, window } from '@kit.ArkUI'
const debug: boolean = false

@Observed
export class MoveAbleWrapperParams {
  /**
   * 相对于屏幕的定位
   */
  edges: Edges
  /**
   * 是否显示
   */
  show: boolean

  constructor(edges: Edges, show: boolean) {
    this.edges = edges
    this.show = show
  }
}

@Component
export struct AppOverlayWrapper {
  @ObjectLink setting: MoveAbleWrapperParams

  @Builder
  childBuilder() {
  }

  @BuilderParam child: () => void = this.childBuilder
  @State debugTitle: string = 'Drag Me Please'
  @State localPosition: Position = { x: 0, y: 0 }
  @State windowWidth: number = 0
  @State windowHeight: number = 0
  @State systemBarHeight: number = 0
  @State bottomNavHeight: number = 0
  @State selfSize: Size = { width: 0, height: 0 }
  @State transX: number = 0
  @State transY: number = 0

  async aboutToAppear() {
    let windowSize = display.getDefaultDisplaySync()
    this.windowWidth = px2vp(windowSize.width)
    this.windowHeight = px2vp(windowSize.height)

    let win = await window.getLastWindow(getContext(this))
    let systemBar = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
    if (systemBar.visible) {
      this.systemBarHeight = px2vp(systemBar.topRect.height)
    }
    let bottomNav = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
    if (bottomNav.visible) {
      this.bottomNavHeight = px2vp(bottomNav.bottomRect.height)
    }
  }

  build() {
    Stack() {
      if (!debug && this.setting.show) {
        this.child()
      }
      if (debug && this.setting.show) Column() {
        Text(this.debugTitle)
        Text(`windowWidth: ${this.windowWidth.toFixed(2)}`)
        Text(`windowHeight: ${this.windowHeight.toFixed(2)}`)
        Text(`systemBar: ${this.systemBarHeight.toFixed(2)}`)
        Text(`bottomNavHeight: ${this.bottomNavHeight.toFixed(2)}`)
        Text(`selfWidth: ${this.selfSize.width.toFixed(2)}`)
        Text(`selfHeight: ${this.selfSize.height.toFixed(2)}`)
      }
    }
    .onAreaChange((ov, nv) => {
      if (ov.width !== nv.width) {
        this.selfSize.width = Number(nv.width)
      }
      if (ov.height !== nv.height) {
        this.selfSize.height = Number(nv.height)
      }
    })
    .backgroundColor(debug ? Color.Red : Color.Transparent)
    .gesture(
      PanGesture()
        .onActionUpdate((event) => {
          if (!this.setting.show) {
            return
          }
          this.transX = event.offsetX
          this.transY = event.offsetY
        })
        .onActionEnd(() => {
          // 不可超出安全区域
          let x = clamp(0, 10, 4)
          console.log('---> x:', x)
          if (this.setting.edges.left !== undefined) {
            let left = Number(this.setting.edges.left) + this.transX
            this.setting.edges.left = clamp(0, left, this.windowWidth - this.selfSize.width)
          }
          if (this.setting.edges.right !== undefined) {
            let right = Number(this.setting.edges.right) - this.transX
            this.setting.edges.right = clamp(0, right, this.windowWidth - this.selfSize.width)
          }
          if (this.setting.edges.top !== undefined) {
            let top = Number(this.setting.edges.top) + this.transY
            this.setting.edges.top = clamp(0, top, this.windowHeight - this.systemBarHeight - this.bottomNavHeight - this.selfSize.height)
          }
          if (this.setting.edges.bottom !== undefined) {
            let bottom = Number(this.setting.edges.bottom) - this.transY
            this.setting.edges.bottom = clamp(0, bottom, this.windowHeight - this.systemBarHeight - this.bottomNavHeight - this.selfSize.height)
          }
          this.transX = 0
          this.transY = 0
        })
    )
    .gesture(
      TapGesture()
        .onAction(() => {
          if (debug) {
            this.debugTitle += "1"
          }
        })
    )
    .hitTestBehavior(HitTestMode.Block)
    .position(this.setting.edges)
    .translate({ x: this.transX, y: this.transY })
  }
}

function clamp(min: number, num: number, max: number) {
  return num <= min
    ? min
    : num >= max
      ? max
      : num
}