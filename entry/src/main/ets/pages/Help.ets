import { intl } from '@kit.LocalizationKit';

@Entry
@Component
struct Help {
  @State time: string = ''
  interval?: number;

  onPageShow(): void {
    this.interval && clearInterval(this.interval)
    this.interval = setInterval(() => {
      let timeFormat = new intl.DateTimeFormat('zh-CN', {
        timeStyle: 'medium'
      });
      this.time = timeFormat.format(new Date());
    }, 200)
  }

  onPageHide(): void {
    this.interval && clearInterval(this.interval)
  }

  build() {
    Navigation() {
      Column({ space: 8 }) {
        Row() {
          Text('您的手机时间：')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
        }.margin({
          top: 20
        })

        Text(this.time)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Center)
          .margin({
            top: 6
          })

        Text('手机时间与标准时间相差需在1分钟以内，否则令牌将不能正常工作。')
          .fontSize(14)
          .margin({
            top: 12
          })
          .fontColor($r('sys.color.font_secondary'))

        Text('您可以打开系统->日期和时间->自动设置，以自动同步时间。如果已经打开并且时间仍然相差较大，可关闭后重新打开。')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))

        Text('标准时间可通过 time.is、北京时间网等网站查看。')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .padding(16)
      .width('100%')
      .height('100%')
    }
    .title('帮助')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}