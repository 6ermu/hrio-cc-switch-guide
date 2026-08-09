# 连接矩阵

| 客户端/模式 | Base URL | 协议/开关 | 备注 |
|---|---|---|---|
| CC Switch → Codex 原生 Responses | `https://hrioapi.hrio.site/api/v1` | `wire_api = "responses"` | 模型必须支持 `/v1/responses` |
| CC Switch → Codex Chat-only 模型 | `https://hrioapi.hrio.site/api` | 开启“需要本地路由映射” | 开启本地路由和 Codex 接管；映射真实模型 ID |
| CC Switch → Claude Code Anthropic | `https://hrioapi.hrio.site/api` | Anthropic Messages | 最终请求为 `/v1/messages` |
| OpenAI SDK | `https://hrioapi.hrio.site/api/v1` | OpenAI compatible | Chat 使用 `chat.completions`，Responses 使用 `responses` |
| 原始 HTTP 调试 | `https://hrioapi.hrio.site/api` | Bearer Key | 路径自行追加 `/v1/...` |

不要把 `https://hrioapi.hrio.site/dashboard` 当作 API Base；它是网页控制台地址。

