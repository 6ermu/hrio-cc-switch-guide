# 03：把 HrioAPI 连接到 CC Switch

## 先选哪种模式

HrioAPI 是统一网关，不同模型可能使用不同协议。先运行：

```powershell
$env:HRIO_API_KEY="真实 Key"
python .\scripts\test_hrio.py --list-models
```

然后在 HrioAPI 的“在线调试/模型 Contract”查看目标模型默认端点。

| 目标 | 选择 |
|---|---|
| 模型支持 `/v1/responses`，主要给 Codex 使用 | 方案 A：Codex 原生 Responses |
| 模型只支持 `/v1/chat/completions` 或模型名不是 GPT 系列 | 方案 B：Codex 本地路由映射 |
| 给 Claude Code 使用且支持 `/v1/messages` | 方案 C：Claude Anthropic Messages |

## 打开“添加供应商”

1. 启动 CC Switch。
2. 顶部选择 `Codex` 或 `Claude`。
3. 点击右上角橙色 `+`。
4. 选择“自定义配置”。

![CC Switch 添加供应商](../assets/screenshots/cc-switch-add-zh.png)

截图是 Claude Code 添加页，Codex 页字段会不同，但入口和“自定义配置”位置相同。

## 方案 A：Codex 原生 Responses

适合模型 Contract 明确写着 `/v1/responses` 的模型。

建议填写：

| 字段 | 值 |
|---|---|
| 供应商名称 | `HrioAPI Responses` |
| 官网链接 | `https://hrioapi.hrio.site/dashboard` |
| API Key | HrioAPI 创建的 Key |
| Base URL | `https://hrioapi.hrio.site/api/v1` |
| Wire API / 协议 | `responses` |
| 模型 | `/v1/models` 返回的真实模型 ID |
| 需要本地路由映射 | 关闭 |

对应 Codex 配置可参考 [codex-config.toml.example](../templates/codex-config.toml.example)。

为什么这里是 `/api/v1`？因为 Codex/CC Switch 会继续拼接 `/responses`，最终请求应为：

```text
https://hrioapi.hrio.site/api/v1/responses
```

## 方案 B：Codex 接入 Chat Completions 模型

适合 `/v1/chat/completions`、DeepSeek/Kimi/GLM/MiniMax 等非 GPT 模型名，或 Responses 测试失败但 Chat 测试成功的模型。

1. 供应商名称填 `HrioAPI Chat Routing`。
2. 上游/Base URL 前缀填 `https://hrioapi.hrio.site/api`。
3. 填写 Key。
4. 开启“需要本地路由映射”。
5. 在模型映射表新增真实模型 ID；不要自己猜模型名。
6. 保存供应商。
7. 打开 CC Switch 本地路由服务。
8. 在“应用接管”中启用 Codex。
9. 保持 CC Switch/本地路由运行。
10. 完全退出 Codex 和原终端，重新打开。

CC Switch 会把 Codex 发出的 Responses 请求转换成上游 Chat Completions，并把响应转换回来。若关闭本地路由，方案 B 不会工作。

## 方案 C：Claude Code

当模型支持 Anthropic Messages：

| 字段 | 值 |
|---|---|
| 供应商名称 | `HrioAPI Claude` |
| API Key | HrioAPI Key |
| Base URL | `https://hrioapi.hrio.site/api` |
| API 格式 | `Anthropic Messages` |

最终请求为：

```text
https://hrioapi.hrio.site/api/v1/messages
```

如果 HrioAPI 中的目标模型只有 OpenAI Chat/Responses 协议，可在 Claude 供应商高级选项选择对应 API 格式，并开启 CC Switch 代理和 Claude 接管做转换。

## 保存、启用和验证

1. 点击“添加/保存”。
2. 回到供应商列表，悬停卡片并点击“启用”。
3. Codex：关闭所有 Codex 进程与原终端，再打开新终端运行 `codex`。
4. Claude Code：通常可热重载；若异常也建议重启。
5. 输入：`只回复：连接成功`。

## 不要混淆的地址

| 地址 | 对不对 | 说明 |
|---|---|---|
| `https://hrioapi.hrio.site/dashboard` | 错 | 网页控制台 |
| `https://hrioapi.hrio.site/api` | 对 | 原始 API Base，适合自行追加 `/v1/...` |
| `https://hrioapi.hrio.site/api/v1` | 对 | OpenAI SDK/Codex Responses 常用 Base |
| `https://hrioapi.hrio.site/api/v1/chat/completions` | 完整 URL | 仅在工具要求完整端点时填写 |

