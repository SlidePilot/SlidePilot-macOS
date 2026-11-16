# SlidePilot 简体中文（zh-Hans）语言包

本目录中的改动为 SlidePilot for macOS 增加了简体中文界面支持。

## 结论：可行，且无需改动任何 Swift 业务代码

项目原本已经是一套完整的 macOS 标准本地化（Base Internationalization）结构：

- `Base.lproj/Main.storyboard` 与各 `Views/*/Base.lproj/*.xib` 为基准界面；
- 各 `*.lproj/*.strings` 为对应语言的翻译（已有 en / de / fr）；
- Swift 代码里所有面向用户的文案都通过 `NSLocalizedString(...)` 读取 `Localizable.strings`，
  没有硬编码的英文 UI 字符串（仅页码等纯数字是动态生成）。

因此"增加中文"只需**新增一套 `zh-Hans.lproj` 资源 + 在 Xcode 工程里注册该语言**，
不需要重写界面、不需要引入第三方库、不需要改代码逻辑。

## 改动清单

### 1. 新增 8 个中文 `.strings` 文件

| 文件 | 对应 | 键数 |
|---|---|---|
| `SlidePilot/zh-Hans.lproj/Localizable.strings` | 代码中 `NSLocalizedString` 的 53 个键 | 53 |
| `SlidePilot/zh-Hans.lproj/Main.strings` | `Base.lproj/Main.storyboard`（菜单、窗口标题） | 107 |
| `SlidePilot/Views/Preferences/zh-Hans.lproj/GeneralPreferences.strings` | 通用偏好设置 | 6 |
| `SlidePilot/Views/Preferences/zh-Hans.lproj/RemotePreferences.strings` | 遥控偏好设置 | 8 |
| `SlidePilot/Views/Preferences/zh-Hans.lproj/RemoteVerificationViewController.strings` | 设备配对验证 | 5 |
| `SlidePilot/Views/Preferences/zh-Hans.lproj/TrustedDevicesViewController.strings` | 受信任设备 | 4 |
| `SlidePilot/Views/LayoutEditor/zh-Hans.lproj/LayoutEditor.strings` | 布局编辑器 | 18 |
| `SlidePilot/Views/Presentation/zh-Hans.lproj/PointerEditor.strings` | 指针外观编辑器 | 7 |

说明：
- `Localizable.strings` 沿用项目现有的 **UTF-16LE + BOM 纯文本 `.strings`** 格式（与 en/de/fr 完全一致）。
  注意：必须是纯文本而非 Apple binary plist（`bplist00`）——Xcode 的 `CopyStringsFile`
  构建步骤无法自动识别二进制 plist 的编码，会报
  `no --inputencoding specified and could not detect encoding from input file`。
  其余界面 `.strings` 为 UTF-8 纯文本（与 de/fr 一致）。
- 界面 `.strings` 的键是 Xcode 的 **ObjectID**（如 `"0Gn-3s-ITh.title"`），
  由 `ibtool --export-strings-file` 从当前 `Base` 导出后逐条翻译，
  保证与当前 storyboard/xib 一一对应。
- 产品名 `SlidePilot`、品牌相关词不做翻译。
- 带 `%@` 占位符的字符串（如 `"Unsupported Platform Text"`、
  `"Remote Verification Title"`）保留了占位符与顺序。

### 2. 修改 `SlidePilot.xcodeproj/project.pbxproj`

- `knownRegions` 增加 `"zh-Hans"`；
- 新增 8 条 `PBXFileReference`（`text.plist.strings`，name = `zh-Hans`）；
- 把上述引用分别加入 8 个已有的 `PBXVariantGroup`
  （Main.storyboard、Localizable.strings 及 6 个 xib），
  使 Xcode 把它们识别为同一资源的另一种语言。

### 3. 修改 `SlidePilot/Info.plist`

新增 `CFBundleLocalizations` 数组，显式声明 `en / de / fr / zh-Hans`，
让 macOS 在系统语言匹配、App Store 语言列表、以及"显示简介"里正确识别中文。
（`CFBundleDevelopmentRegion` 保持 `$(DEVELOPMENT_LANGUAGE)` = en 不变。）

## 如何生效 / 如何测试

1. 用 Xcode 打开 `SlidePilot.xcodeproj`，选择 SlidePilot target → Info → Localizations，
   应能看到 Chinese (Simplified)。
2. 运行 App。macOS 按"系统设置 → 通用 → 语言与地区"的首选语言顺序选资源：
   - 把 **简体中文** 拖到列表最前 → 界面为中文；
   - 不改系统设置也可以在运行前临时指定，例如：
     ```
     defaults write com.slidepilot.SlidePilot AppleLanguages '("zh-Hans")'
     ```
     或在 Xcode Scheme → Run → Arguments 里加 `-AppleLanguages "(zh-Hans)"`。
3. 检查主菜单、偏好设置四个面板、布局编辑器、指针编辑器、以及所有弹窗/提示
   （保存失败、未保存更改、移除受信任设备等）。
4. 本项目**没有应用内语言切换 UI**，语言完全跟随系统；若需要"App 内单独切换中文"，
   那是另一项功能（需自行实现 `Bundle` 交换 + 刷新所有已加载界面），
   不属于"语言包"范畴。

## 验证记录

- `plutil -lint`：全部 8 个 `.strings`、`Info.plist`、`project.pbxproj` 均 OK；
- 键一致性：中文 `Localizable.strings` 与 `en` 的 53 个键完全一致；
  6 个 xib 的键数与 de/fr 参考完全一致；
- `ibtool --import-strings-file`：把中文 `.strings` 反向导入 Base storyboard/xib 成功，
  产物中确实出现中文（主菜单、偏好设置、布局、指针编辑器），证明整条本地化链路可用；
- **完整 Release 构建 `BUILD SUCCEEDED`**（Xcode 27.2 / macOS 27.2 SDK / Apple Silicon arm64）：
  8 个中文 `.strings` 全部被打包进 `SlidePilot.app/Contents/Resources/zh-Hans.lproj/`，
  `CFBundleLocalizations` 含 `zh-Hans`，产物为 x86_64 + arm64 通用二进制；
- **运行时验证**：通过 `NSBundle.localizedStringForKey:value:table:` 在强制 `zh-Hans` 时
  解析到 `Cancel → 取消`、`Presenter Display → 演讲者显示`；
  `preferredLocalizations` 返回 `zh-Hans`。App 已实际启动运行（无崩溃）。

## 本地构建说明（Xcode 27 上的两个必需覆盖）

本项目最后一次提交是 2022 年，用现代 Xcode 构建需要两个命令行覆盖，**无需改动仓库文件**：

```
xcodebuild -project SlidePilot.xcodeproj -scheme SlidePilot \
  -configuration Release \
  MACOSX_DEPLOYMENT_TARGET=12.0 \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  build
```

1. `MACOSX_DEPLOYMENT_TARGET=12.0`：工程里有一处配置写死 `10.11`，
   而 Xcode 27 只支持 `12.0 ~ 27.2` 的 deployment target，不覆盖会直接报错。
   （另两处 `10.15` 本身合法。）
2. `CODE_SIGNING_ALLOWED=NO`：工程配置了原作者的 `DEVELOPMENT_TEAM`，
   本机没有对应证书。禁用签名后可用 `codesign --force --deep --sign -` 做 ad-hoc 重签，
   配合 `xattr -cr` 清除隔离属性即可在本机运行。
3. 若在受限沙盒环境（如本会话）构建，SwiftPM 需要写 `~/Library/Caches/org.swift.swiftpm`
   才能解析 `Preferences` 依赖；`HOME` 覆盖、`-clonedSourcePackagesDirPath` 等绕行均无效，
   需放行该目录的写权限。
4. 内置 `Sparkle.framework` 是 x86_64 + arm64 双架构，Apple Silicon 可直接使用。

## 已知情况（上游遗留，非本次引入）

`de.lproj/Main.strings` / `fr.lproj/Main.strings` 各有 135/136 个键，
而当前 `Base.lproj/Main.storyboard` 只导出 107 个键（德语/法语版是旧版界面遗留，
其中约 29 个 ObjectID 已不存在，且缺少 `dMs-cI-mzQ.title` 等新键）；
`PointerEditor.strings` 的 de/fr 也多出 2 个失效键。
中文包基于**当前** Base 生成，因此不存在这些陈旧键。建议后续用
`ibtool --export-strings-file` 重新生成 de/fr 以保持一致。

## 复现 / 维护脚本要点

新增界面控件后，重新导出并合并翻译即可：

```
ibtool --export-strings-file /tmp/Main.strings SlidePilot/Base.lproj/Main.storyboard
# 对比新键，把中文补进 zh-Hans.lproj/Main.strings
```

`Localizable.strings` 新增键时，从 `en.lproj/Localizable.strings` 取键并翻译，
**注意保持 UTF-16LE + BOM 纯文本格式**（不要用二进制 plist，会导致构建失败）；
若统一改成 UTF-8 也可以，但需同时把 en/de/fr 一起改，保持工程内一致。

## 提交状态

- 分支 `feature/zh-Hans-localization` 已基于 `origin/develop`（遵循仓库 git flow）；
- 已推送到 fork `zlizpro/SlidePilot-macOS`，并向上游 `develop` 提交
  [PR #90](https://github.com/SlidePilot/SlidePilot-macOS/pull/90)（OPEN）。
