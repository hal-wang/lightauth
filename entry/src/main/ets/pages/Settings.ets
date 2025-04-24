@Entry
@Component
struct Settings {
  build() {
    Navigation() {
Column(){

}
    }
    .title('设置')
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}