import { TOTP, URI } from "./otpauth";
import { preferences } from '@kit.ArkData';

const key = "STORAGE_KEY_1";

class Storage {
  private preference: preferences.Preferences | null = null;
  private inited = false;
  public appItems: TOTP[] = []

  async load(context: Context) {
    if (this.inited) {
      return;
    }

    this.preference = await preferences.getPreferences(context, {
      name: "storage"
    })

    let urls = await this.preference.get(key, []) as string[]
    if (!urls) {
      urls = [];
    }
    this.appItems.splice(
      0,
      this.appItems.length,
      ...urls.map((x) => URI.parse(x) as TOTP),
    );

    this.inited = true
  }

  async save() {
    if (!this.preference) {
      return
    }
    await this.preference.put(key, this.appItems.map((x): string => x.toString()))
    await this.preference.flush()
  }
}

const storage = new Storage()

export { storage }
