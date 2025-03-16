import { display, window } from '@kit.ArkUI'

const debug: boolean = false

export class MoveAbleWrapperParams {
  /**
   * 相对于屏幕的定位
   */
  edges: Edges | undefined
  /**
   * 是否显示
   */
  show: boolean

  constructor(edges: Edges | undefined, show: boolean) {
    this.edges = edges
    this.show = show
  }
}

@Component
export struct AppOverlayWrapper {
  @Watch('changeEdges')
  @Prop edges: Edges
  @State _edges: Edges = {}
  @Watch('changeShow')
  @Prop show: boolean

  @Builder
  childBuilder() {
  }

  @BuilderParam child: () => void = this.childBuilder
  @State debugTitle: string = 'Drag Me Please'
  private lastX: number = 0
  private lastY: number = 0
  @State x: number = 0
  @State y: number = 0
  @State windowWidth: number = 0
  @State windowHeight: number = 0
  @State selfWidth: number = 0
  @State selfHeight: number = 0
  // @State globalPositionX: number = 0
  // @State globalPositionY: number = 0
  @State globalPosition: Position = { x: 0, y: 0 }
  @State fingerInfo: string = ''
  private panOffsetDx: number = 0
  private panOffsetDy: number = 0
  @State systemBarHeight: number = 0
  @State bottomNavHeight: number = 0
  private needMatchRightAndX = false
  private needMatchBottomAndY = false

  changeEdges() {
    this.lastX = 0
    this.lastY = 0
    if (this.edges?.left !== undefined) {
      this.lastX = Number(this.edges.left)
    }
    if (this.edges?.top !== undefined) {
      this.lastY = Number(this.edges.top)
    }
    if (this.edges?.right !== undefined) {
      this.lastX = this.windowWidth - Number(this.edges.right) - this.selfWidth
    }
    if (this.edges.bottom !== undefined) {
      this.lastY =
        this.windowHeight - this.systemBarHeight - this.selfHeight - this.bottomNavHeight - Number(this.edges.right)
    }
    this._edges = { left: this.lastX, top: this.lastY }
  }

  changeShow() {
    if (this.show) {
      if (this.edges) {
        this._edges = this.edges
      }
      if (this._edges?.left !== undefined) {
        this.lastX = Number(this._edges.left)
      }
      if (this._edges?.top !== undefined) {
        this.lastY = Number(this._edges.top)
      }
      // check一下是否需要在build后重建localPosition
      // 只关注 top <==> lastY, left <==> lastX
      if (this._edges?.right !== undefined) {
        this.needMatchRightAndX = true
      }
      if (this._edges?.bottom !== undefined) {
        this.needMatchBottomAndY = true
      }
    }
  }

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
      if (!debug && this.show) {
        this.child()
      }
      if (debug && this.show) Column() {
        Text(this.debugTitle)
        Text(`windowWidth: ${this.windowWidth.toFixed(2)}`)
        Text(`windowHeight: ${this.windowHeight.toFixed(2)}`)
        Text(`systemBar: ${this.systemBarHeight.toFixed(2)}`)
        Text(`bottomNavHeight: ${this.bottomNavHeight.toFixed(2)}`)
        Text(`globalPositionX: ${Number(this.globalPosition.x).toFixed(2)}`)
        Text(`globalPositionY: ${Number(this.globalPosition.y).toFixed(2)}`)
        Text(`selfWidth: ${this.selfWidth.toFixed(2)}`)
        Text(`selfHeight: ${this.selfHeight.toFixed(2)}`)
        Text(`x: ${this.x.toFixed(2)}`)
        Text(`y: ${this.y.toFixed(2)}`)
      }
    }
    .onAreaChange((ov, nv) => {
      this.globalPosition = {
        x: nv.globalPosition.x,
        y: nv.globalPosition.y
      }
      if (ov.width !== nv.width) {
        this.selfWidth = nv.width as number
        if (this.needMatchRightAndX) {
          this.lastX = this.windowWidth - Number(this._edges.right) - this.selfWidth
          this._edges.left = this.lastX
          this._edges.right = undefined
          this.needMatchRightAndX = false
        }
      }
      if (ov.height !== nv.height) {
        this.selfHeight = nv.height as number
        if (this.needMatchBottomAndY) {
          this.lastY = this.windowHeight - Number(this._edges.bottom) - this.selfHeight - this.systemBarHeight -
          this.bottomNavHeight
          this._edges.top = this.lastY
          this._edges.bottom = undefined
          this.needMatchBottomAndY = false
        }
      }
    })
    .backgroundColor(Color.Red)
    .gesture(
      PanGesture()
        .onActionStart((event) => {
          if (!this.show) {
            return
          }
          if (event.fingerList.length > 0) {
            this.panOffsetDx = -event.fingerList[0].localX
            this.panOffsetDy = -event.fingerList[0].localY
          }
        })
        .onActionUpdate((event) => {
          if (!this.show) {
            return
          }
          if (event.fingerList.length > 0) {
            this.x = this.lastX + this.panOffsetDx + event.fingerList[0].localX
            this.y = this.lastY + this.panOffsetDy + event.fingerList[0].localY

            this._edges.left = this.x
            this._edges.top = this.y
          }
        })
        .onActionEnd(() => {
          // 不可超出可视窗口
          this.x = clamp(0, this.x, this.windowWidth - this.selfWidth)
          this.y = clamp(0, this.y, this.windowHeight - this.systemBarHeight - this.bottomNavHeight - this.selfHeight)
          this.lastX = this.x
          this.lastY = this.y
          this._edges.left = this.x
          this._edges.top = this.y
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
    .position(this._edges)
  }
}

function clamp(min: number, num: number, max: number) {
  return num <= min
    ? min
    : num >= max
      ? max
      : num
}