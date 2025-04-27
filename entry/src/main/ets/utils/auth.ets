import { userAuth } from "@kit.UserAuthenticationKit";
import { cryptoFramework } from "@kit.CryptoArchitectureKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { UIContext } from "@kit.ArkUI";

export function auth(context: UIContext) {
  return new Promise<boolean>(async (resolve) => {
    try {
      const authParam: userAuth.AuthParam = {
        challenge: cryptoFramework.createRandom().generateRandomSync(16)?.data,
        authType: [userAuth.UserAuthType.PIN, userAuth.UserAuthType.FACE, userAuth.UserAuthType.FINGERPRINT],
        authTrustLevel: userAuth.AuthTrustLevel.ATL3,
        reuseUnlockResult: {
          reuseMode: userAuth.ReuseMode.AUTH_TYPE_IRRELEVANT,
          reuseDuration: 60000,
        },
      };
      // 获取认证对象
      const userAuthInstance = userAuth.getUserAuthInstance(authParam, {
        title: '请进行身份认证',
      });
      console.info('get userAuth instance success');
      // 订阅认证结果
      userAuthInstance.on('result', {
        onResult(result) {
          // 可在认证结束或其他业务需要场景，取消订阅认证结果
          userAuthInstance.off('result');
          console.info(`userAuthInstance callback result: ${result.result ==
          userAuth.UserAuthResultCode.SUCCESS}, ${JSON.stringify(result)}`);
          resolve(result.result == userAuth.UserAuthResultCode.SUCCESS)
        }
      });
      userAuthInstance.start();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(`auth catch error. Code is ${err?.code}, message is ${err?.message}`);
      context.getPromptAction().showToast({
        message: "发起认证失败"
      })
      resolve(false)
    }
  })
}