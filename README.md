# HrioAPI SDK 连通测试

本仓库只保留 HrioAPI SDK 连通测试脚本。

`genius-programmer`（天才程序员）Skill 已拆分到独立仓库：

https://github.com/6ermu/genius-programmer

完整的 CC Switch、其他模型和视频模型中文教程已改为 WPS 文档分发，不存放在本 GitHub 仓库中。

仓库提供两个入口：

- `scripts/test_hrio.py`：无第三方依赖的 Python 测试脚本。
- `scripts/test-hrio.ps1`：Windows PowerShell 包装入口。

### 1. 配置 API Key

请把真实 Key 放入环境变量，不要写进代码或提交到 GitHub：

```powershell
$env:HRIO_API_KEY="你的真实 API Key"
```

### 2. 查询模型列表

```powershell
python .\scripts\test_hrio.py --list-models
```

或：

```powershell
.\scripts\test-hrio.ps1 -ListModels
```

### 3. 测试模型

Chat Completions：

```powershell
python .\scripts\test_hrio.py --model "MODEL_ID" --endpoint chat
```

Responses：

```powershell
python .\scripts\test_hrio.py --model "MODEL_ID" --endpoint responses
```

默认 OpenAI 兼容 API Base：

```text
https://hrioapi.hrio.site/api/v1
```

## 安全提醒

- 不要提交真实 API Key。
- Key 泄露后应立即在 HrioAPI 控制台吊销并重新创建。
- SDK 测试建议先请求模型列表，再进行小 token 文本测试。
