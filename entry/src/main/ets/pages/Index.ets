import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';
import { SymbolGlyphModifier, CustomContentDialog } from '@kit.ArkUI';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { storage } from '../utils/storage'
import { TOTP, URI } from "../utils/otpauth";

const DOMAIN = 0x0000;

@CustomDialog
@Component
struct AddDialog {
  controller?: CustomDialogController
  success: (val: TOTP) => void = (val: TOTP) => {
  }
  @State input: string = ''
  inputDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '手动输入密钥',
      secondaryTitle: '格式如 DQAFWJ***YCKQ',
      contentBuilder: () => {
        this.buildInputContent()
      },
      buttons: [
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.success(new TOTP({
              label: '未命名',
              secret: this.input
            }))
          }
        },
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR
        }
      ],
    }),
  });

  aboutToDisappear(): void {
    this.inputDialogController = null
  }

  @Builder
  buildInputContent(): void {
    TextInput({ placeholder: '请输入密钥' })
      .id('input')
      .onChange((val) => {
        this.input = val
      })
      .width('100%')
  }

  build() {
    Column() {
      Text('新增令牌').fontSize(20).margin({ top: 10, bottom: 10 })
      Text('选择新增令牌的方式').fontSize(16)
      Menu() {
        MenuItem({
          content: "扫描二维码",
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.qrcode')).fontSize(24),
        }).onChange(() => {
          this.controller?.close()
          this.scanQR()
        })
        MenuItem({
          content: "手动输入密钥",
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.selector')).fontSize(24)
        }).onChange(() => {
          this.controller?.close()
          this.inputDialogController?.open()
          setTimeout(() => {
            try {
              this.getUIContext().getFocusController().requestFocus('input')
            } catch {
            }
          }, 200)
        })
      }.align(Alignment.Center).width('100%').margin(10)
    }.borderRadius(10)
  }

  scanQR() {
    let options: scanBarcode.ScanOptions =
      { scanTypes: [scanCore.ScanType.QR_CODE], enableMultiMode: true, enableAlbum: true };
    scanBarcode.startScanForResult(getContext(this), options)
      .then((result: scanBarcode.ScanResult) => {
        const url = result.originalValue
        if (!url.startsWith('otpauth://totp/')) {
          this.getUIContext().showAlertDialog({
            title: '添加失败',
            message: '当前扫描的不是令牌二维码：' + url,
            primaryButton: {
              enabled: true,
              action: () => undefined,
              value: '关闭'
            }
          })
          return;
        }

        this.success(URI.parse(url) as TOTP)
      })
      .catch((error: BusinessError) => {
        if (error.code == 1000500001) {
          this.getUIContext().showAlertDialog({
            title: '添加失败',
            message: error.message,
            primaryButton: {
              enabled: true,
              action: () => undefined,
              value: '关闭'
            }
          })
        }
      });
  }
}


@CustomDialog
@Component
struct EditDialog {
  controller?: CustomDialogController
  success: () => void = () => {
  }
  totp: TOTP | null = null;
  @State label: string = ''
  @State issuer: string = ''

  async onDidBuild() {
    this.label = this.totp?.label ?? ''
    this.issuer = this.totp?.issuer ?? ''
  }

  build() {
    Column() {
      Text('修改令牌').fontSize(20).margin({ top: 10, bottom: 10 })
      Text('账号名和提供商仅用于显示，不影响令牌').fontSize(16).opacity(0.7)

      Column() {
        Text('账号名').alignSelf(ItemAlign.Start).margin({ top: 20, left: 16, bottom: 4 })
        TextInput({ placeholder: '请输入账号名', text: this.label }).onChange(val => {
          this.label = val
        })
        Text('提供商').alignSelf(ItemAlign.Start).margin({ top: 20, left: 16, bottom: 4 })
        TextInput({ placeholder: '请输入提供商', text: this.issuer }).onChange(val => {
          this.issuer = val
        })
        Row() {
          Button('确定').buttonStyle(ButtonStyleMode.TEXTUAL).width('50%').onClick(() => {
            if (!this.label) {
              this.getUIContext().getPromptAction().showToast({
                message: '请输入账号名',
                alignment: Alignment.Center,
              })
              return
            }

            if (this.totp) {
              this.totp.label = this.label
              this.totp.issuer = this.issuer
              this.success()
              this.controller?.close()
            }
          })
          Button('取消').buttonStyle(ButtonStyleMode.TEXTUAL).fontColor(Color.Gray).width('50%').onClick(() => {
            this.controller?.close()
          })
        }.width('100%')
        .padding({
          bottom: 14,
          top: 14,
        })
      }.padding({
        left: 14,
        right: 14
      })

    }.borderRadius(10)
  }
}


@Component
struct TotpComponent {
  @State totp: TOTP = null!
  @State token: string = ''
  @State remaining: number = 1
  interval: number | null = null

  aboutToAppear(): void {
    this.interval = setInterval(() => {
      this.token = this.totp.generate();
      this.remaining = this.totp.remaining();
    }, 200);
  }

  aboutToDisappear(): void {
    this.interval && clearInterval(this.interval)
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.totp.label).fontWeight(FontWeight.Bold).fontSize(18)
          if (this.totp.issuer) {
            Text(this.totp.issuer).fontSize(14).opacity(0.6).margin({
              top: 6,
            })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)

        Text(this.token).fontWeight(FontWeight.Bold).fontSize(26)
      }
      .width('100%')
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(10)
      .padding({
        left: 10,
        right: 10,
        top: 14,
        bottom: 14,
      })

      Row()
        .height(4)
        .margin({
          top: -4,
        })
        .width(`${this.remaining / 300}%`)
        .backgroundColor($r('app.color.primary'))
        .alignSelf(ItemAlign.Start)
        .borderRadius({
          bottomLeft: 10,
          bottomRight: 10,
        })
    }
    .width('100%')
  }
}

@Entry
@Component
struct Index {
  @State appItems: TOTP[] = []

  private updateList() {
    animateTo({ duration: 500 }, () => {
      this.appItems = [...storage.appItems]
    })
  }

  addDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddDialog({
      success: async (val) => {
        storage.appItems.splice(0, 0, val)
        await storage.save()
        this.updateList()
      },
    }),
    alignment: DialogAlignment.Center,
  })
  private editTotp: TOTP | null = null
  editDialogController: CustomDialogController | null = new CustomDialogController({
    builder: EditDialog({
      success: async () => {
        await storage.save()
        this.updateList()
      },
      totp: this.editTotp,
    }),
    alignment: DialogAlignment.Center,
  })
  @State menuItems: Array<NavigationMenuItem> = [
    {
      value: '新增令牌',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
      action: () => {
        this.addDialogController?.open()
      },
    },
    {
      value: '设置',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape')),
      action: () => {
        router.pushUrl({ url: 'pages/Settings' })
      },
    }
  ]

  build() {
    Navigation() {
      List({ space: 10, scroller: this.scroller }) {
        ForEach(this.appItems, (item: TOTP, index) => {
          ListItem() {
            TotpComponent({ totp: item })
              .margin({
                left: 10,
                right: 10,
              })
          }
          .swipeAction({
            end: this.DeleteButton(index),
          })
          .onClick(() => {
            this.editTotp = item
            this.editDialogController?.open()
          })
        })
      }.padding({
        top: 10,
        bottom: 10,
      })
    }
    .title($r('app.string.EntryAbility_label'), {
      backgroundColor: $r('app.color.card_background')
    })
    .titleMode(NavigationTitleMode.Mini)
    .menus(this.menuItems)
    .hideBackButton(true)
    .backgroundColor($r('app.color.page_background'))
  }

  private scroller: ListScroller = new ListScroller()

  @Builder
  DeleteButton(index: number) {
    Button() {
      SymbolGlyph($r('sys.symbol.trash'))
        .fontColor([Color.White])
        .fontSize(26)
    }
    .width(60)
    .height('100%')
    .type(ButtonType.Normal)
    .backgroundColor(Color.Red)
    .onClick(async () => {
      storage.appItems.splice(index, 1)
      await storage.save()
      animateTo({ duration: 500 }, () => {
        this.scroller.closeAllSwipeActions()
        this.updateList()
      })
    })
  }

  async onDidBuild(): Promise<void> {
    await storage.load(getContext(this))
    this.updateList()
  }

  aboutToDisappear(): void {
    this.addDialogController = null
    this.editDialogController = null
  }
}