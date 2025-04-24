import { picker } from '@kit.CoreFileKit'
import { intl } from '@kit.LocalizationKit'
import { fileIo as fs } from '@kit.CoreFileKit';
import { aesEncrypt, stringToUint8Array } from '../utils/crypto';
import { storage } from '../utils/storage';

@Component
export struct MainItem {
  @State title: string | Resource = '';
  @State tag: string | Resource = '';
  @State label: string = '';
  @State isTouched: boolean = false;
  @LocalStorageLink('selectedLabel') selectedLabel: string = '';
  @LocalStorageProp('isSplitMode') isSplitMode: boolean = false;

  isActivated(): boolean {
    if (this.isSplitMode) {
      return this.label !== '' && this.label === this.selectedLabel;
    }
    return this.isTouched;
  }

  build() {
    Row() {
      Text(this.title)
        .fontSize(16)
        .lineHeight(22)
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .align(Alignment.Start)
        .margin({ left: 6 })

      Blank()

      Text(this.tag)
        .fontSize(14)
        .lineHeight(19)
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .fontColor($r('sys.color.ohos_id_color_text_primary'))

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(20)
        .margin({ left: 4 })
        .fontColor([$r('sys.color.ohos_id_color_fourth')])
    }
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(46)
    .borderRadius(20)
    .padding({ left: 8, right: 8 })
    .backgroundColor(this.isActivated() ? $r('sys.color.interactive_pressed') :
      '#0000')
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      } else if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
  }
}

@Component
export struct ItemGroup {
  @BuilderParam noParam: () => void;

  build() {
    Column() {
      this.noParam()
    }
    .width('100%')
    .borderRadius(24)
    .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
    .padding(4)
  }
}

@Entry
@Component
struct Settings {
  @Builder
  CustomDivider() {
    Divider()
      .strokeWidth('1')
      .color($r('sys.color.ohos_fa_list_separator'))
      .opacity(0.8)
      .margin({ left: 8, right: 8 })
  }

  build() {
    Navigation() {
      List({ space: 12 }) {
        ListItem() {
          ItemGroup() {
            MainItem({
              title: '导出令牌',
            }).onClick(() => this.export())
            this.CustomDivider()
            MainItem({
              title: '导入令牌',
            })
          }
        }
      }
      .padding(16)
      .width('100%')
      .height('100%')
    }
    .title('设置')
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  async export() {
    if (!storage.appItems.length) {
      this.getUIContext().getPromptAction().showToast({
        message: "没有令牌无法导出"
      })
      return
    }

    const documentSaveOptions = new picker.DocumentSaveOptions();
    const timeFormat = new intl.DateTimeFormat('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
    const time = timeFormat.format(new Date()).replaceAll('/', '-').replaceAll(':', '-').replaceAll(' ', '-')
    documentSaveOptions.newFileNames =
      [`轻令牌备份 ${time}.la`];
    documentSaveOptions.fileSuffixChoices = ['轻令牌|.la', '.la'];
    const documentViewPicker = new picker.DocumentViewPicker(getContext(this));
    try {
      const documentSaveResult = await documentViewPicker.save(documentSaveOptions);
      const uris = documentSaveResult;
      const uri = uris[0]
      if (!uri) {
        return;
      }

      const file = await fs.open(uri, fs.OpenMode.READ_WRITE);
      const data = await aesEncrypt(stringToUint8Array(storage.appItems.join('\n')))
      await fs.write(file.fd, data.buffer, {})
      await fs.close(file)

      this.getUIContext().showAlertDialog({
        title: '导出完成',
        message: '导出成功。为了令牌安全，导出的文件已加密，无法直接打开，请妥善保管。',
        primaryButton: {
          enabled: true,
          action: () => undefined,
          value: '确定'
        }
      })
    } catch (err) {
      console.error('导出失败', err)
      this.getUIContext().getPromptAction().showToast({
        message: "导出失败"
      })
    }
  }
}