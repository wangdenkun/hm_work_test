import { ComponentContent, display, OverlayManager } from '@kit.ArkUI';
import { AppOverlayManager } from './AppOverlayManager';
import { MoveAbleWrapper, MoveAbleWrapperParams } from './MoveAbleWrapper';
import { Tmp } from './tmp';



@Builder
function builderOverlayContent() {
  Text('xxxxxxxxxxxxxx')
}

@Builder
function builderOverlay(params: MoveAbleWrapperParams) {
  MoveAbleWrapper(
    {
      show: params.show,
      edges: params.edges,
      customBuilder: builderOverlayContent
    }
  ).hitTestBehavior(HitTestMode.Transparent)
  // Tmp()
}

@Entry
@Component
struct Index {
  private uiContext: UIContext = this.getUIContext()
  private overlayManager: OverlayManager = this.uiContext.getOverlayManager()
  private overlayContent: ComponentContent<MoveAbleWrapperParams>[] = []
  controller: TextInputController = new TextInputController()
  private overlayNode: ComponentContent<MoveAbleWrapperParams> =
    new ComponentContent(
      this.uiContext, wrapBuilder(builderOverlay),
      new MoveAbleWrapperParams({ right: 0, bottom: 0 }, false),
    )
  @State showPositionX: number = 0
  @State showPositionY: number = 0
  @State windowWidth: number = 0
  @State windowHeight: number = 0

  async aboutToAppear() {
    let windowSize = display.getDefaultDisplaySync()
    this.windowWidth = px2vp(windowSize.width)
    this.windowHeight = px2vp(windowSize.height)
    AppOverlayManager.registerFeedBackOverlay(this.overlayNode)
  }

  aboutToDisappear(): void {
    let componentContent = this.overlayContent.pop()
    this.overlayManager.removeComponentContent(componentContent)
  }

  showOverlay() {
    // this.overlayNode.update(new MoveAbleWrapperParams({ left: this.showPositionX, top: this.showPositionY }, true))
    // this.overlayNode.update(new MoveAbleWrapperParams(null, true))
    AppOverlayManager.showFeedBackOverlay(new MoveAbleWrapperParams(undefined, true))
    // AppOverlayManager.showFeedBackOverlay(new MoveAbleWrapperParams({left:this.showPositionX,top:this.showPositionY}, true))
  }

  hideOverlay() {
    // this.overlayNode.update(new MoveAbleWrapperParams({ right: 0, bottom: 0 }, false))
    AppOverlayManager.hideFeedBackOverlay()
  }

  build() {
    Column() {
      Row() {
        Text('showPositionX')
        Slider({ value: $$this.showPositionX, max: this.windowWidth })
      }

      Row() {
        Text('showPositionY')
        Slider({ value: $$this.showPositionY, max: this.windowHeight })
      }

      Button('showOverlay Test')
        .onClick(() => this.showOverlay())
      Blank().height(8)
      Button('hideOverlay Test')
        .onClick(() => this.hideOverlay())
    }
    .justifyContent(FlexAlign.Center)
    // .offset({x:'25%',y:'25%'})
    // .width('50%')
    // .height('50%')
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Yellow)
    .onAreaChange((ov, nv) => {
      console.log('---> main nv.height:', nv.height)
      AppStorage.setOrCreate('indexPageWidth', nv.width as number)
      AppStorage.setOrCreate('indexPageHeight', nv.height as number)
      AppStorage.setOrCreate('indexPageGlobalOffsetX', nv.globalPosition.x as number)
      AppStorage.setOrCreate('indexPageGlobalOffsetY', nv.globalPosition.y as number)
    })
    .overlay(this.overlayNode)
  }
}

