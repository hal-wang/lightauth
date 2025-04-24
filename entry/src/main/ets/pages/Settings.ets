import { picker } from '@kit.CoreFileKit'
import { intl } from '@kit.LocalizationKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@Component
struct Settings {
  build() {
    Navigation() {
      Column() {
        Button() {
          SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
            .fontColor([$r('sys.color.font_on')])
            .fontSize(26)
        }
        .width(60)
        .height('100%')
        .type(ButtonType.Normal)
        .backgroundColor($r('sys.color.ohos_fa_activated'))
        .onClick(async () => {
          const documentSaveOptions = new picker.DocumentSaveOptions();
          const timeFormat = new intl.DateTimeFormat('zh-CN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
          });
          const time = timeFormat.format(new Date()).replaceAll('/', '-')
          documentSaveOptions.newFileNames =
            [`轻令牌备份 ${time}.la`];
          documentSaveOptions.fileSuffixChoices = ['轻令牌|.la', '.la'];
          const documentViewPicker = new picker.DocumentViewPicker(getContext(this));
          documentViewPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
            const uris = documentSaveResult;
            if (!uris.length) {
              return;
            }
          }).catch((err: BusinessError) => {
            this.getUIContext().getPromptAction().showToast({
              message: "导出失败"
            })
          })
        })
      }
    }
    .title('设置')
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}