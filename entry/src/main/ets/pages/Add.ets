@Entry
@Component
struct Add {
  build() {
    Navigation() {

    }
    .title('新增令牌', {
      backgroundColor: $r('app.color.card_background')
    })
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('app.color.page_background'))
  }
}