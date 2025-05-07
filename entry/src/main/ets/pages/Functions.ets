@Entry
@Component
struct Functions {
  build() {
    Navigation() {
      List({ space: 8 }) {
        ListItem() {
          Text('新增令牌')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.padding({
          top: 20
        })

        ListItem() {
          Text('可选择扫码📷添加，或手动输入⌨︎密钥。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('扫描的二维码需是常见的 HOTP 协议的密钥二维码。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('手动输入的密钥格式如 DQAFWJ***YCKQ，注意不是完整密钥地址，仅输入密钥部分即可，添加完成后可通过编辑令牌修改名称。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('编辑令牌')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.padding({
          top: 20
        })

        ListItem() {
          Text('左滑👈密钥列表中的密钥，右侧会出现编辑按钮，点击弹出编辑弹窗，账号名和提供商仅用于显示，不影响令牌实际功能。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('删除令牌')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.padding({
          top: 20
        })

        ListItem() {
          Text('左滑👈密钥列表中的一条密钥，右侧会出现删除按钮，点击并确认即删除，删除后无法恢复（除导出导入）。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('调整顺序')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.padding({
          top: 20
        })

        ListItem() {
          Text('右滑👉密钥列表中的一条密钥，左侧会出现上下排序按钮，点击即可调整顺序。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('导入导出')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.padding({
          top: 20
        })

        ListItem() {
          Text('在设置页面中，点击“导出令牌文件”并选择导出位置，即导出所有令牌。导出的文件会被安全加密，以防止文件泄漏。因此导出的文件只能使用轻令牌导入。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('在设置页面中，点击“导入令牌文件”并选择文件，即导入文件中的所有令牌。如果当前列表中存在应用名、提供商、密钥完全一致的令牌，就会忽略这个导入的令牌。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('安全认证')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.padding({
          top: 20
        })

        ListItem() {
          Text('安全认证使用鸿蒙系统的认证能力，根据手机设置选择人脸🫥、指纹☝️、密码🔑验证身份，确保密钥安全无泄漏，开启此功能至少需要手机已设置密码。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }

        ListItem() {
          Text('服务卡片')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }.padding({
          top: 20
        })

        ListItem() {
          Text('轻令牌提供一个 2x2 服务卡片，用于快捷打开元服务。卡片可添加在桌面、锁屏、负1屏等支持卡片的位置。')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }.padding({
          bottom: 20
        })
      }
      .padding(16)
      .width('100%')
      .height('100%')
    }
    .title('功能介绍')
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}