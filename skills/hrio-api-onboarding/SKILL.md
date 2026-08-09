---
name: hrio-api-onboarding
description: Configure, test, document, or troubleshoot HrioAPI connections for CC Switch, Codex, Claude Code, OpenAI-compatible SDKs, and text/image/audio/video model endpoints. Use when a user mentions hrioapi.hrio.site, HrioAPI API Key/Base URL, CC Switch supplier setup, model listing, Responses versus Chat Completions routing, SDK connectivity tests, or HrioAPI multimodal integration.
---

# HrioAPI 接入助手

## 核心流程

1. 确认用户没有把真实 API Key 写入仓库、截图或回复。
2. 使用固定 API Base `https://hrioapi.hrio.site/api`，除非用户提供公司内部独立域名。
3. 先请求 `GET /v1/models` 验证 Key 并获取真实模型 ID。
4. 根据目标客户端和模型能力选择协议：
   - Codex 原生 Responses：使用 `https://hrioapi.hrio.site/api/v1` 和 `wire_api = "responses"`。
   - Codex 对接 Chat-only 模型：在 CC Switch 开启“需要本地路由映射”，保持本地路由与 Codex 接管开启。
   - Claude Code 原生 Anthropic：使用 `ANTHROPIC_BASE_URL=https://hrioapi.hrio.site/api`。
   - 图片、音频、Embedding、Rerank、视频：不要假设都能在 Codex/Claude CLI 里直接使用；按模型 contract 调用对应 HTTP 端点。
5. 运行 `scripts/test_hrio.py` 做只读模型列表检查和一次低 token 文本请求。
6. 对 401/403、404/405、模型不存在、协议不匹配和超时分别给出结论，不要笼统归因于“网络问题”。

## 使用脚本

```powershell
$env:HRIO_API_KEY="真实 Key"
python scripts/test_hrio.py --list-models
python scripts/test_hrio.py --model "MODEL_ID" --endpoint chat
python scripts/test_hrio.py --model "MODEL_ID" --endpoint responses
```

脚本不得打印完整 Key。若需要记录诊断信息，只记录 HTTP 状态、端点、模型 ID 和响应摘要。

## 参考资料路由

- 配置 CC Switch、Codex 或 Claude Code 时，读取 [references/connection-matrix.md](references/connection-matrix.md)。
- 处理图片、音频、Embedding、Rerank、视频或异步任务时，读取 [references/api-endpoints.md](references/api-endpoints.md)。
- 排查错误时，读取 [references/troubleshooting.md](references/troubleshooting.md)。

## 输出要求

- 明确区分“API Base”“完整请求 URL”“API Key”“模型 ID”。
- 所有示例使用 `YOUR_API_KEY` 和 `MODEL_ID` 占位符。
- 先验证 `/v1/models`，再建议用户填写模型映射。
- 说明视频等异步接口可能先返回任务 ID，需按平台 contract 查询状态和下载 HTTPS 结果。
- 若当前没有真实 Key，只做无效 Key 的鉴权入口测试，不声称已完成真实模型调用。

