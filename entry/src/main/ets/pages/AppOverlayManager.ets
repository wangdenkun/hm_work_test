import { MoveAbleWrapperParams } from './MoveAbleWrapper'

export class AppOverlayManager {
  private static feedBackNode?: ComponentContent<MoveAbleWrapperParams>

  static registerFeedBackOverlay(node: ComponentContent<MoveAbleWrapperParams>) {
    AppOverlayManager.feedBackNode = node
  }

  static showFeedBackOverlay(params: MoveAbleWrapperParams) {
    AppOverlayManager.feedBackNode?.update(params)
  }

  static hideFeedBackOverlay() {
    AppOverlayManager.feedBackNode?.update(new MoveAbleWrapperParams(null, false))
  }
}