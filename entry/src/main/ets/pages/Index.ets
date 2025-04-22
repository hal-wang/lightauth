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
      Text('选择新增令牌的方式').fontSize(16).margin({ bottom: 10 })
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
      }.align(Alignment.Center).width('100%')
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
      .margin({
        top: 10,
      })
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
    .width('94%')
  }
}

@Entry
@Component
struct Index {
  @State appItems: TOTP[] = [...storage.appItems]
  addDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddDialog({
      success: async (val) => {
        storage.appItems.splice(0, 0, val)
        await storage.save()
        this.appItems = [...storage.appItems]
      },
    }),
    alignment: DialogAlignment.Center,
  })

  aboutToDisappear(): void {
    this.addDialogController = null
  }

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
      Scroll() {
        Column() {
          ForEach(this.appItems, (item: TOTP) => {
            TotpComponent({ totp: item })
          })
        }
      }
    }
    .title($r('app.string.EntryAbility_label'), {
      backgroundColor: $r('app.color.card_background')
    })
    .titleMode(NavigationTitleMode.Mini)
    .menus(this.menuItems)
    .hideBackButton(true)
    .backgroundColor($r('app.color.page_background'))
  }

  aboutToAppear() {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    this.loginWithHuaweiID();
  }

  /**
   * Sample code for using HUAWEI ID to log in to atomic service.
   * According to the Atomic Service Review Guide, when a atomic service has an account system,
   * the option to log in with a HUAWEI ID must be provided.
   * The following presets the atomic service to use the HUAWEI ID silent login function.
   * To enable the atomic service to log in successfully using the HUAWEI ID, please refer
   * to the HarmonyOS HUAWEI ID Access Guide to configure the client ID and fingerprint certificate.
   */
  private loginWithHuaweiID() {
    // Create a login request and set parameters
    const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    // Whether to forcibly launch the HUAWEI ID login page when the user is not logged in with the HUAWEI ID
    loginRequest.forceLogin = false;
    // Execute login request
    const controller = new authentication.AuthenticationController();
    controller.executeRequest(loginRequest).then((data) => {
      const loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
      const authCode = loginWithHuaweiIDResponse.data?.authorizationCode;
      // Send authCode to the backend in exchange for unionID, session

    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, 'testTag', 'error: %{public}s', JSON.stringify(error));
      if (error.code === authentication.AuthenticationErrorCode.ACCOUNT_NOT_LOGGED_IN) {
        // HUAWEI ID is not logged in, it is recommended to jump to the login guide page

      }
    });
  }
}