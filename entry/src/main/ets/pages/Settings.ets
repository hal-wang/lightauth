import { fileUri, picker } from '@kit.CoreFileKit'
import { intl } from '@kit.LocalizationKit'
import { fileIo as fs } from '@kit.CoreFileKit';
import { aesDecrypt, aesEncrypt, stringToUint8Array, uint8ArrayToString } from '../utils/crypto';
import { storage } from '../utils/storage';
import { TOTP, URI } from "../utils/otpauth";
import { util } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';
import { auth } from '../utils/auth';
import { router } from '@kit.ArkUI';

@Component
export struct MainItem {
  @State title: string | Resource = '';
  @State isTouched: boolean = false;
  @BuilderParam right: (() => void) = this.rightIcon;

  @Builder
  rightIcon() {
    SymbolGlyph($r('sys.symbol.chevron_right'))
      .fontSize(20)
      .margin({ left: 4 })
      .fontColor([$r('sys.color.ohos_id_color_fourth')])
  }

  isActivated(): boolean {
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

      this.right()
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
  @BuilderParam noParam: () => void = this.DefaultParam;

  @Builder
  DefaultParam() {
  }

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
  @State isAuthOpen: boolean = false
  configPreference?: preferences.Preferences

  async onPageShow(): Promise<void> {
    this.configPreference = await preferences.getPreferences(getContext(this), {
      name: "config"
    })
    this.isAuthOpen = await this.configPreference.get("isAuthOpen", false) as boolean
  }

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
          Text('本地文件导入导出备份，文件会被安全加密，因此只能使用轻令牌导入')
            .fontSize(13)
            .fontColor($r('sys.color.font_secondary'))
        }.padding({
          top: 12
        })

        ListItem() {
          ItemGroup() {
            MainItem({
              title: '导出令牌文件',
            })
              .onClick(() => this.export())
            this.CustomDivider()
            MainItem({
              title: '导入令牌文件',
            })
              .onClick(() => this.import())
          }
        }

        ListItem() {
          Text('开启安全认证后，每次打开服务都需要通过人脸、指纹或密码验证身份（解锁设备1分钟内不会要求验证）')
            .fontSize(13)
            .fontColor($r('sys.color.font_secondary'))
        }.padding({
          top: 26
        })

        ListItem() {
          ItemGroup() {
            MainItem({
              title: '安全认证',
              right: this.AuthToggle,
            })
              .onClick(async () => {
                await this.toggleAuth()
              })
          }
        }

        ListItem() {
          ItemGroup() {
            MainItem({
              title: '功能介绍',
            })
              .onClick(() => {
                router.pushUrl({ url: 'pages/Functions' })
              })
            this.CustomDivider()
            MainItem({
              title: '帮助',
            })
              .onClick(() => {
                router.pushUrl({ url: 'pages/Help' })
              })
          }
        }.padding({
          top: 8,
        })
      }
      .padding(16)
      .width('100%')
      .height('100%')
    }
    .title('设置')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  @LocalBuilder
  AuthToggle() {
    Toggle({ type: ToggleType.Switch, isOn: this.isAuthOpen })
      .onClick(async () => {
        await this.toggleAuth()
      })
  }

  private async toggleAuth() {
    this.isAuthOpen = !this.isAuthOpen
    if (this.isAuthOpen && !await auth(this.getUIContext())) {
      this.isAuthOpen = false
      return;
    }

    await this.configPreference?.put('isAuthOpen', this.isAuthOpen)
    await this.configPreference?.flush()
  }

  private fileUrlPrefix = "file://docs/storage/Users/currentUser/";
  private bundleName = "com.atomicservice.6917570445314904193"

  async import() {
    const documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1;
    documentSelectOptions.fileSuffixFilters = ['轻令牌备份|.la'];
    documentSelectOptions.defaultFilePathUri =
      `${this.fileUrlPrefix}Download/${this.bundleName}/备份`
    const documentViewPicker = new picker.DocumentViewPicker(getContext(this));
    try {
      const documentSelectResult = await documentViewPicker.select(documentSelectOptions)
      const url = documentSelectResult[0]
      if (!url) {
        return
      }
      console.log('导入地址', url)
      const file = await fs.open(url, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(file.fd)
      const buffer = new ArrayBuffer(stat.size)
      await fs.read(file.fd, buffer)
      const data = await aesDecrypt(new Uint8Array(buffer))
      uint8ArrayToString(data)
        .split('\n')
        .forEach((url) => {
          try {
            if (!storage.appItems.some(x => x.toString() == url)) {
              const totp = URI.parse(url) as TOTP
              totp.id = util.generateRandomUUID(true)
              storage.appItems.splice(0, 0, totp)
            }
          } catch {
          }
        })
      await storage.save()
      this.getUIContext().getPromptAction().showToast({
        message: "导入完成"
      })
    } catch (err) {
      console.error('导入失败', err)
      this.getUIContext().getPromptAction().showToast({
        message: "导入失败"
      })
    }
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
    documentSaveOptions.defaultFilePathUri = `${this.fileUrlPrefix}Download/${this.bundleName}/备份`
    const documentViewPicker = new picker.DocumentViewPicker(getContext(this));
    try {
      {
        const tempOptions = new picker.DocumentSaveOptions();
        tempOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
        const tempUrls = await documentViewPicker.save(tempOptions);
        if (tempUrls.length) {
          const dirPath = new fileUri.FileUri(`${tempUrls[0]}/备份`).path
          if (!await fs.access(dirPath, fs.AccessModeType.EXIST)) {
            await fs.mkdir(dirPath)
          }
        }
      }

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

      console.log('导出地址', uri)
      let tipUrl = decodeURIComponent(uri)
      if (tipUrl.startsWith(this.fileUrlPrefix)) {
        tipUrl = '我的手机/' + tipUrl.substring(this.fileUrlPrefix.length, tipUrl.length)
      }
      tipUrl = tipUrl.replace(this.bundleName, '轻令牌')
      this.getUIContext().showAlertDialog({
        title: '导出成功',
        message: `为了令牌安全，导出的文件已加密，无法直接打开，请妥善保管。保存地址：${tipUrl}`,
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