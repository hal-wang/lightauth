@Entry
@Component
struct Settings {
  build() {
    Navigation() {

    }
    .title('设置', {
      backgroundColor: $r('app.color.card_background')
    })
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('app.color.page_background'))
  }
}