import { AppOverlayTestPage } from '../overlay/AppOverlayTestPage'

@Entry
@Component
struct Index {
  build() {
    Column(){
      AppOverlayTestPage()
    }
  }
}