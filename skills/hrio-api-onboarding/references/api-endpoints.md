# HrioAPI 公开调用端点

前端调试器当前声明以下标准路径，真实可用性由模型 contract、账号权限和平台路由决定：

| 能力 | 路径 |
|---|---|
| 模型列表 | `GET /v1/models` |
| OpenAI Chat | `POST /v1/chat/completions` |
| OpenAI Responses | `POST /v1/responses` |
| Anthropic Messages | `POST /v1/messages` |
| Gemini | `POST /v1beta/models/{model}:generateContent` |
| 图片生成 | `POST /v1/images/generations` |
| 图片编辑 | `POST /v1/images/edits` |
| 视频生成 | `POST /v1/videos` |
| Embedding | `POST /v1/embeddings` |
| 语音合成 | `POST /v1/audio/speech` |
| 音频转写 | `POST /v1/audio/transcriptions` |
| 音频翻译 | `POST /v1/audio/translations` |
| Rerank | `POST /v1/rerank` |

视频和部分图片/音频模型可能是异步任务。先读取返回的任务 ID 或状态 URL，再按模型 contract 查询；不要假设第一次响应一定包含最终媒体文件。

