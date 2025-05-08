@Entry
@Component
struct OpenSource {
  build() {
    Navigation() {
      Column({ space: 8 }) {
        Row() {
          Text('本程序是开源软件，无联网权限，可放心使用。')
            .fontSize(14)
        }.margin({
          top: 20
        })

        Row() {
          Text('GitHub')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.margin({
          top: 20
        })

        Text('https://github.com/hal-wang/lightauth')
          .fontSize(14)
          .margin({
            top: 4
          })
          .fontColor($r('sys.color.font_secondary'))

        Row() {
          Text('Gitee')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.margin({
          top: 20
        })

        Text('https://gitee.com/hal-wang/lightauth')
          .fontSize(14)
          .margin({
            top: 4
          })
          .fontColor($r('sys.color.font_secondary'))

        Row() {
          Text('GitCode')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.margin({
          top: 20
        })

        Text('https://gitcode.com/hal-wang/lightauth')
          .fontSize(14)
          .margin({
            top: 4
          })
          .fontColor($r('sys.color.font_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .padding(16)
      .width('100%')
      .height('100%')
    }
    .title('开源信息')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}