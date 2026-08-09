# 01：注册、登录与创建 API Key

## 先认识 4 个名词

| 名词 | 本教程中的值 | 用途 |
|---|---|---|
| 控制台网址 | `https://hrioapi.hrio.site/dashboard` | 登录、创建 Key、看余额与日志 |
| API Base | `https://hrioapi.hrio.site/api` | 程序请求的基础地址 |
| API Key | 类似 `sk-...` | 证明“你是谁”，必须保密 |
| 模型 ID | 从 `/v1/models` 返回 | 告诉平台要调用哪个模型 |

最常见错误是把控制台网址填进 CC Switch。请记住：`/dashboard` 是网页，不是 API Base。

## 注册账号

打开 [HrioAPI Dashboard](https://hrioapi.hrio.site/dashboard)。未登录时会自动跳到登录页。

![HrioAPI 登录页](../assets/screenshots/hrio-login.png)

没有账号就点击“注册账号”，填写：

1. 用户名：至少 3 个字符。
2. 邮箱：用于账号识别或通知。
3. 密码：至少 8 个字符，建议使用密码管理器生成。
4. 邀请码：页面标注为可选；若公司要求邀请码，请向管理员获取。
5. 点击“创建账号”，然后按页面提示登录。

![HrioAPI 注册页](../assets/screenshots/hrio-register.png)

## 创建 API Key

登录后，在左侧或底部导航找到 `API Key`；当前前端路由是 `/api-tokens`，旧链接 `/keys` 会跳转到这里。

1. 点击“新增”或“创建 API Key”。
2. 名称建议写用途，例如 `cc-switch-codex-laptop`。
3. 如果有额度、到期时间、允许模型或 IP 白名单选项：
   - 初次测试先给最低够用额度。
   - 只允许需要的模型。
   - 固定服务器可加 IP 白名单；个人电脑公网 IP 经常变化时先不加。
4. 创建后立即复制 Key，保存在密码管理器或系统安全凭据中。
5. 不要把 Key 发给别人，不要提交到 GitHub。

> 控制台登录后界面需要真实账号态。本教程没有擅自注册账号或创建生产 Key，因此后台按钮名称请以当前页面为准。前端已确认用户 Key 接口为 `/api/users/keys`，用户导航名称为 `API Key`。

## 先验证 Key，不急着配置 CC Switch

在本仓库根目录打开 PowerShell：

```powershell
$env:HRIO_API_KEY="粘贴真实 Key"
python .\scripts\test_hrio.py --list-models
```

看到 HTTP 200 和模型 ID 列表，说明 Key 与 API Base 正确。看到 401/403，先修复 Key 或权限，再进入下一章。

## 用完如何清理

如果 Key 曾经出现在公开仓库、截图、直播、录屏或聊天里：

1. 立即在 HrioAPI 控制台禁用或删除旧 Key。
2. 创建新 Key。
3. 更新 CC Switch。
4. 清理 Git 历史不能代替吊销；旧 Key 必须作废。

