@Entry
@Component
export  struct OverlayContentPage {
  @State message: string = 'Hello World';
  @State textWidth: number = 0
  private textHeight: number = 0

  build() {
    Text(this.message)
      .id('OverlayContentPageHelloWorld')
        // .fontSize($r('app.float.page_text_font_size'))
      .fontWeight(FontWeight.Bold)
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .onAreaChange((ov,nv) => {
        console.log(`---> nv.width:`, nv.width)
        this.textWidth = Number(nv.width)
        this.textHeight = Number(nv.height)
        console.log(`---> this.textWidth:`, this.textWidth)
      })
      .constraintSize({
        minWidth: 100,
        minHeight: 100,
        maxWidth: 200,
        maxHeight: 200
      })
      .width(this.textWidth)
      .height(this.textHeight)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        // this.message += 'Hello World\nHello World'
        this.textWidth += 10
        this.textHeight += 10
      })
  }
  onDidBuild(): void {
    console.log(`---> this.selfInitWidth:`, this.textWidth)
  }
}