import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { router } from '@kit.ArkUI';
import { SymbolGlyphModifier, CustomContentDialog } from '@kit.ArkUI';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { storage } from '../utils/storage'
import { TOTP, URI } from "../utils/otpauth";
import { util } from '@kit.ArkTS';

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
            if (!this.input) {
              this.getUIContext().showAlertDialog({
                title: '添加失败',
                message: '密钥不能为空',
                primaryButton: {
                  enabled: true,
                  action: () => undefined,
                  value: '关闭'
                }
              })
              return
            }
            try {
              this.success(new TOTP({
                label: '未命名',
                issuer: '',
                secret: this.input
              }))
            } catch {
              this.getUIContext().showAlertDialog({
                title: '添加失败',
                message: '未能解析密钥，请重新输入',
                primaryButton: {
                  enabled: true,
                  action: () => undefined,
                  value: '关闭'
                }
              })
            }
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
      Text('新增令牌').fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 10, bottom: 4 })
      Text('选择新增令牌的方式').fontSize(14).opacity(0.7)
      Menu() {
        MenuItem({
          content: "扫描二维码",
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.qrcode')).fontSize(24),
        }).onChange(() => {
          this.controller?.close()
          this.scanQR()
        })

        MenuItemGroup() {
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
        }
      }
      .align(Alignment.Center)
      .width('100%')
      .margin(10)
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
      Text('修改令牌').fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 10, bottom: 4 })
      Text('账号名和提供商仅用于显示，不影响令牌').fontSize(14).opacity(0.7)

      Column() {
        Text('账号名（必填）')
          .alignSelf(ItemAlign.Start)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, left: 16, bottom: 4 })
        TextInput({ placeholder: '请输入账号名', text: this.label }).onChange(val => {
          this.label = val
        })
        Text('提供商（可选）')
          .alignSelf(ItemAlign.Start)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, left: 16, bottom: 4 })
        TextInput({ placeholder: '请输入提供商', text: this.issuer }).onChange(val => {
          this.issuer = val
        })
        Row() {
          Button('确定')
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .onClick(() => {
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
                this.totp.id = util.generateRandomUUID(true)
                this.success()
                this.controller?.close()
              }
            })
            .flexGrow(1)
          Line()
            .height(24)
            .width(1)
            .backgroundColor($r('sys.color.ohos_fa_list_separator'))
          Button('取消')
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .fontColor(Color.Gray)
            .onClick(() => {
              this.controller?.close()
            })
            .flexGrow(1)
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
  @State isTouched: boolean = false;

  aboutToAppear(): void {
    this.interval = setInterval(() => {
      this.token = this.totp.generate();
      animateTo({ duration: 180 }, () => {
        this.remaining = this.totp.remaining();
      })
    }, 200);
  }

  aboutToDisappear(): void {
    this.interval && clearInterval(this.interval)
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.totp.issuer || this.totp.label)
            .fontWeight(FontWeight.Bold)
            .fontSize(18)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
          if (this.totp.issuer) {
            Text(this.totp.label)
              .fontSize(14)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .opacity(0.6)
              .margin({
                top: 6,
              })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)
        .width(0)

        Text(this.token).fontWeight(FontWeight.Bold).fontSize(26)
      }
      .width('100%')
      .backgroundColor(this.isTouched ? $r('sys.color.interactive_pressed') : $r('sys.color.ohos_fa_list_card_bg'))
      .padding(16)

      Row()
        .height(4)
        .margin({
          top: -4,
        })
        .width(`${this.remaining / 300}%`)
        .backgroundColor($r('sys.color.ohos_fa_activated'))
        .alignSelf(ItemAlign.Start)
        .borderRadius(2)
    }
    .borderRadius(20)
    .width('100%')
    .clip(true)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      } else if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
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

  private scroller: ListScroller = new ListScroller()
  addDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddDialog({
      success: async (val) => {
        val.id = util.generateRandomUUID(true)
        storage.appItems.splice(0, 0, val)
        await storage.save()
        this.appItems.splice(0, 0, val)
      },
    }),
    alignment: DialogAlignment.Center,
  })
  private editIndex?: number;
  editDialogController: CustomDialogController | null = new CustomDialogController({
    builder: EditDialog({
      success: async () => {
        await storage.save()
        this.updateList()
      },
      totp: this.appItems[this.editIndex!],
    }),
    alignment: DialogAlignment.Center,
  })
  @State menuItems: Array<NavigationMenuItem> = [
    {
      value: '新增令牌',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
      action: () => {
        if (!storage.loaded) {
          return;
        }

        this.addDialogController?.open()
      },
    },
    {
      value: '设置',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape')),
      action: () => {
        if (!storage.loaded) {
          return;
        }

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
            end: this.SwipeActions(index),
          })
          .onClick(async () => {
            try {
              const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, item.generate());
              let systemPasteboard = pasteboard.getSystemPasteboard();
              await systemPasteboard.setData(pasteData);
              this.getUIContext().getPromptAction().showToast({
                message: '已复制'
              })
            } catch {
              this.getUIContext().getPromptAction().showToast({
                message: '复制失败'
              })
            }

          })
        }, (item: TOTP) => item.id)
      }.padding({
        top: 10,
        bottom: 10,
      })
    }
    .title($r('app.string.app_name'))
    .menus(this.menuItems)
    .hideBackButton(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onClick(() => {
      this.scroller.closeAllSwipeActions()
    })
  }

  @Builder
  SwipeActions(index: number) {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.square_and_pencil'))
          .fontColor([$r('sys.color.font_on')])
          .fontSize(26)
      }
      .width(60)
      .height('100%')
      .type(ButtonType.Normal)
      .backgroundColor($r('sys.color.ohos_fa_activated'))
      .onClick(() => {
        this.scroller.closeAllSwipeActions()
        this.editIndex = index
        this.editDialogController?.open()
      })

      Button() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontColor([$r('sys.color.font_on')])
          .fontSize(26)
      }
      .width(60)
      .height('100%')
      .type(ButtonType.Normal)
      .backgroundColor($r('sys.color.warning'))
      .onClick(async () => {
        this.scroller.closeAllSwipeActions()
        const res = await this.getUIContext().getPromptAction().showDialog({
          title: '确认删除',
          message: `即将删除令牌“${this.appItems[index].label}”，该操作不可恢复，确认继续？`,
          buttons: [
            {
              text: "确认",
              color: $r('sys.color.warning'),
            },
            {
              text: "取消",
              color: $r('sys.color.font_secondary'),
            },
          ]
        })
        if (res.index != 0) {
          return
        }

        storage.appItems.splice(index, 1)
        await storage.save()
        this.scroller.closeAllSwipeActions()
        animateTo({ duration: 500 }, () => {
          this.appItems.splice(index, 1)
        })
      })
    }
  }

  async onDidBuild(): Promise<void> {
    await storage.load(this.getUIContext())
    this.updateList()
  }

  aboutToDisappear(): void {
    this.addDialogController = null
    this.editDialogController = null
  }

  onPageShow(): void {
    if (this.appItems.length != storage.appItems.length) {
      this.updateList()
    }
  }
}