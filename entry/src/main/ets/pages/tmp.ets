import { curves, window } from '@kit.ArkUI';

@Entry
@Component
export  struct Tmp {
  @State message: string = 'Hello World';
  private topRect: number = 0
  private bottomRect: number = 0
  // 父组件宽度
  @State containerWidth: number = 0;
  // 父组件高度
  @State containerHeight: number = 0;

  async aboutToAppear() {
    let win = await window.getLastWindow(getContext(this))
    let area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    this.topRect = px2vp(area.topRect.height)
    let bottomArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
    this.bottomRect = px2vp(bottomArea.bottomRect.height)

  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
        .onClick(() => {
          this.message = 'Welcome';
        })


      // 悬浮窗
      FloatWindowView({ containerWidth: this.containerWidth, containerHeight: this.containerHeight })

    }
    .height('100%')
    .width('100%').onAreaChange((oldValue: Area, newValue: Area) => {
      // TODO：性能知识点：onAreaChange是高频回调，仅在父组件尺寸改变时获取新的父组件宽高，避免性能损耗
      if (oldValue.width !== newValue.width) {
        this.containerWidth = newValue.width as number;
      }
      if (oldValue.height !== newValue.height) {
        this.containerHeight = newValue.height as number;
      }
    })
  }
}


@Component
struct FloatWindowView {
  private topRect: number = 0
  private bottomRect: number = 0

  async aboutToAppear() {
    let win = await window.getLastWindow(getContext(this))
    let area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    this.topRect = px2vp(area.topRect.height)
    let bottomArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
    this.bottomRect = px2vp(bottomArea.bottomRect.height)

  }

  // y: number = 300; // 悬浮窗相对父容器左上角的Y坐标初始值

  //控件宽度
  childW: number = 120;
  childH:number = 120
  ping: number = 12;
  // 悬浮窗相对于父组件四条边的距离，top和bottom同时设置时top生效，right和left同时设置时left生效
  @State edge: Edges = { top: this.topRect, right: this.ping };
  @Link containerWidth: number;
  @Link containerHeight: number;
  // 拖拽移动开始时悬浮窗在窗口中的坐标，每次移动回调触发时更新
  private windowStartX: number = 0;
  private windowStartY: number = 0;

  /**
   * 触摸回调，悬浮窗跟手和贴边动画
   */
  onTouchEvent(event: TouchEvent): void {
    switch (event.type) {
      case TouchType.Down: {
        // 获取拖拽开始时悬浮窗在窗口中的坐标
        this.windowStartX = event.touches[0].windowX;
        this.windowStartY = event.touches[0].windowY;
        break;
      }
      case TouchType.Move: {
        const windowX: number = event.touches[0].windowX;
        const windowY: number = event.touches[0].windowY;
        // TODO：知识点：跟手动画，推荐使用默认参数的弹性跟手动画曲线curves.responsiveSpringMotion。
        animateTo({ curve: curves.responsiveSpringMotion() }, () => {
          // 判断当前edge中属性left和right哪个不为undefined，用于控制悬浮窗水平方向的位置
          if (this.edge.left !== undefined) {
            this.edge.left = this.edge.left as number + (windowX - this.windowStartX);
          } else {
            this.edge.right = this.edge.right as number - (windowX - this.windowStartX);
          }
          this.edge.top = this.edge.top as number + (windowY - this.windowStartY);
          this.windowStartX = windowX;
          this.windowStartY = windowY;
        })
        break;
      }
      case TouchType.Up: {
        // 计算悬浮窗中心点在父组件中水平方向的坐标
        let centerX: number;
        if (this.edge.left !== undefined) {
          centerX = this.edge.left as number + this.childW / 2;
        } else {
          centerX = this.containerWidth - (this.edge.right as number) - this.childW / 2;
        }
        // TODO：知识点：通过判断悬浮窗在父组件中的位置，设置悬浮窗贴边，使用curves.springMotion()弹性动画曲线，可以实现阻尼动画效果
        animateTo({ curve: curves.springMotion() }, () => {
          // 判断悬浮窗中心在水平方向是否超过父组件宽度的一半，根据结果设置靠左或靠右
          if (centerX > (this.containerWidth / 2)) {
            this.edge.right = this.ping;
            this.edge.left = undefined;
          } else {
            this.edge.right = undefined;
            this.edge.left = this.ping;
          }
          // 判断悬浮窗是否超出内容区上下边界，根据结果将悬浮窗设置在边界位置
          if (this.edge.top as number < this.ping) {
            this.edge.top = this.ping;
          } else if (this.edge.top as number > this.containerHeight - this.childW - this.ping) {
            this.edge.top = this.containerHeight - this.childH - this.ping;
          }
        })
        break;
      }
      default: {
        break;
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text("sd")
        .id('a')
        .alignRules({
          top: { anchor: 'HelloWorld', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .textAlign(TextAlign.Center)
        .height(120)
        .width(120)
        .backgroundColor('#000fff')
    }.onTouch((event: TouchEvent) => {
      this.onTouchEvent(event);
    }).backgroundColor('#fff000').position(this.edge)

  }
}