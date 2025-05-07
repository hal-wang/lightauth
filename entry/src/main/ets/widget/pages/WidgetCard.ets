@Entry
@Component
struct WidgetCard {
  build() {
    Column() {
      Image($r("app.media.widget_2x2")).width('100%').height('100%').objectFit(ImageFit.Cover)
    }
    .onClick(async () => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {}
      });
    })
  }
}

