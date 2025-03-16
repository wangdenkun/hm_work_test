import { ComponentContent, display, OverlayManager, promptAction } from '@kit.ArkUI';
import { appOverlayManager } from '../overlay/AppOverlayManager';
import { AppOverlayWrapper, MoveAbleWrapperParams } from '../overlay/AppOverlayWrapper';
import { OverlayContentPage } from './OverlayContentPage';
import { Tmp } from './tmp';

enum  OverlayType {
  Feedback = 'Feedback',
  Test = 'Test'
}

@Builder
function builderOverlay(params: MoveAbleWrapperParams) {
  Stack() {
    AppOverlayWrapper(
      {
        show: params.show,
        edges: params.edges,
      }
    ) {
      OverlayContentPage()
        .width(100)
        .height(100)
    }
  }
  .hitTestBehavior(HitTestMode.Transparent)
  .position({ x: 0, y: 0 }) //

  // Tmp()
}

@Builder
function builderFeedbackOverlay() {
  OverlayContentPage()
}

@Entry
@Component
export  struct AppOverlayTestPage {
  private uiContext: UIContext = this.getUIContext()
  private overlayManager: OverlayManager = this.uiContext.getOverlayManager()
  private overlayContent: ComponentContent<MoveAbleWrapperParams>[] = []
  controller: TextInputController = new TextInputController()
  private overlayNode: ComponentContent<MoveAbleWrapperParams> =
    new ComponentContent(
      this.uiContext, wrapBuilder(builderOverlay),
      new MoveAbleWrapperParams({ right: 0, bottom: 0 }, true),
    )
  @Watch('updateOverlayContent')
  @State showPositionX: number = 0
  @Watch('updateOverlayContent')
  @State showPositionY: number = 0
  @State windowWidth: number = 0
  @State windowHeight: number = 0
  @Watch('updateOverlayContent')
  @State showOverlay: boolean = true

  // 是否使用新Api
  @State useNewApi: boolean = true

  test(vt: OverlayType) {
    console.log(`---> typeof  vt:`, typeof  vt)
  }
  async aboutToAppear() {
    let windowSize = display.getDefaultDisplaySync()
    this.windowWidth = px2vp(windowSize.width)
    this.windowHeight = px2vp(windowSize.height)
    this.test(OverlayType.Feedback)
  }

  aboutToDisappear(): void {
  }

  addFeedBackOverlay() {
    let setting = new MoveAbleWrapperParams({ right: 100, bottom: 10 }, this.showOverlay);

    if (!this.useNewApi) {
      this.overlayNode = new ComponentContent(this.uiContext, wrapBuilder(builderOverlay), new MoveAbleWrapperParams({ right: 100, bottom: 10 }, this.showOverlay),)
      appOverlayManager.addComponentContentForKey(this.overlayNode, undefined, OverlayType.Feedback)
    }
    if (this.useNewApi) {
      appOverlayManager.addOverlay(
        this.getUIContext(),
        wrapBuilder(builderFeedbackOverlay),
        setting,
        OverlayType.Feedback
      )
    }
  }

  showFeedBackOverlay() {
    if (!this.useNewApi) {
      // appOverlayManager.showComponentContent(this.overlayNode)
      appOverlayManager.showComponentContent(OverlayType.Feedback)
    }
    if (this.useNewApi) {
      appOverlayManager.showOverlay(OverlayType.Feedback)
      // appOverlayManager.showOverlay(OverlayType.Feedback, new MoveAbleWrapperParams(
      //   {
      //     left: 100,
      //     top: 100
      //   },
      //   true
      // ))
    }
  }

  hideFeedBackOverlay() {
    if (!this.useNewApi) {
      // appOverlayManager.hideComponentContent(this.overlayNode)
      appOverlayManager.hideComponentContent(OverlayType.Feedback)

    }
    if (this.useNewApi) {
      appOverlayManager.hideOverlay(OverlayType.Feedback)
    }
  }

  updateOverlayContent() {
    if (!this.useNewApi) {
      this.overlayNode.update(new MoveAbleWrapperParams({ left: this.showPositionX, top: this.showPositionY }, this.showOverlay))
    }
    if (this.useNewApi) {
      let setting = new MoveAbleWrapperParams({ left: this.showPositionX, top: this.showPositionY }, this.showOverlay)
      appOverlayManager.updateSettingForOverlay(setting,OverlayType.Feedback)
    }
  }
  removeOverlay() {
    if (!this.useNewApi) {
      // appOverlayManager.removeComponentContent(this.overlayNode)
      appOverlayManager.removeComponentContent(OverlayType.Feedback)
    }
    if (this.useNewApi) {
      appOverlayManager.removeOverlay(OverlayType.Feedback)
    }
  }

  checkIsShowing() {
    let res = appOverlayManager.getOverlayIsShowing(OverlayType.Feedback)
    promptAction.showToast({
      message: `${OverlayType.Feedback} isShowing: ${res}`
    })
  }

  getOverlayInfo() {
    let info = appOverlayManager.getInfoOfOverlay(OverlayType.Feedback)
    if (info) {
      promptAction.showToast({
        message: `info: ${JSON.stringify(info)}`
      })
    }else {
      promptAction.showToast({
        message: `info: null`
      })
    }
  }

  build() {
    Column() {
      Button('TestTestTestTest')
        .onClick(() => {
          console.log('---> click Index Test Button')
        }).alignSelf(ItemAlign.Start)
      Blank()
      Row() {
        Text('showPositionX')
        Slider({ value: $$this.showPositionX, max: this.windowWidth })
      }

      Row() {
        Text('showPositionY')
        Slider({ value: $$this.showPositionY, max: this.windowHeight })
      }
      Row() {
        Text('是否显示:')
        Toggle({type: ToggleType.Switch,isOn: $$this.showOverlay})
      }
      Blank().height(8)
      Button('addFeedBackOverlay').onClick(() => this.addFeedBackOverlay())
      Blank().height(8)
      Button('showFeedBackOverlay').onClick(() => this.showFeedBackOverlay())
      Blank().height(8)
      Button('hideFeedBackOverlay').onClick(() => this.hideFeedBackOverlay())
      Blank().height(8)
      Button('updateOverlayContent').onClick(() => this.updateOverlayContent())
      Blank().height(8)
      Button('removeOverlay').onClick(() => this.removeOverlay())
      Blank().height(8)
      Button('checkIsShowing').onClick(() => this.checkIsShowing())
      Blank().height(8)
      Button('getOverlayInfo').onClick(() => this.getOverlayInfo())
      Blank().height(8)
      Row() {
        Text('使用新Api:')
        Toggle({type: ToggleType.Switch,isOn: $$this.useNewApi})
      }
      Blank()
    }
    .justifyContent(FlexAlign.Center)
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
    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

