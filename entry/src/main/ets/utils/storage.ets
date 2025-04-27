import { TOTP, URI } from "./otpauth";
import { preferences } from '@kit.ArkData';
import { util } from '@kit.ArkTS';
import { UIContext } from "@kit.ArkUI";
import { auth } from "./auth";
import router from '@ohos.router'

const key = "STORAGE_KEY_1";

class Storage {
  private preference: preferences.Preferences | null = null;
  public loaded = false;
  public appItems: TOTP[] = []

  async load(context: UIContext) {
    if (this.loaded) {
      return;
    }

    const configPreference = await preferences.getPreferences(getContext(this), {
      name: "config"
    })
    if (await configPreference.get("isAuthOpen", false) as boolean) {
      await this.auth(context)
    }

    this.preference = await preferences.getPreferences(context.getHostContext()!, {
      name: "storage"
    })

    let urls = await this.preference.get(key, []) as string[]
    if (!urls) {
      urls = [];
    }
    this.appItems.splice(
      0,
      this.appItems.length,
      ...urls.map((x) => {
        const result = URI.parse(x) as TOTP
        result.id = util.generateRandomUUID(true)
        return result;
      }),
    );

    this.loaded = true
  }

  async save() {
    if (!this.preference) {
      return
    }
    await this.preference.put(key, this.appItems.map((x): string => x.toString()))
    await this.preference.flush()
  }

  private auth(context: UIContext) {
    return new Promise<void>(async (resolve) => {
      if (await auth(context)) {
        resolve()
      } else {
        this.onAuthFailed(context, resolve)
      }
    })
  }

  private onAuthFailed(context: UIContext, resolve: () => void) {
    context.getPromptAction().showDialog({
      title: '认证失败',
      message: `已开启安全认证，需通过人脸、指纹或密码认证通过才可使用。`,
      isModal: true,
      maskRect: {
        x: 0,
        y: 0,
        width: '100%',
        height: '100%',
      },
      buttons: [
        {
          text: "开始认证",
          color: $r('sys.color.ohos_fa_activated'),
        },
        {
          text: "退出程序",
          color: $r('sys.color.warning'),
        },
      ]
    })
      .then(async res => {
        if (res.index == 1) {
          router.clear()
          router.back()
          this.onAuthFailed(context, resolve)
        } else {
          await this.auth(context)
          resolve()
        }
      })
      .catch(async () => {
        await this.auth(context)
        resolve()
      })
  }
}

const storage = new Storage()

export { storage }
