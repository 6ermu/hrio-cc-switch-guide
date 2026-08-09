# HrioAPI SDK 与天才程序员 Skill

本仓库只保留两类可执行内容：

1. HrioAPI SDK 连通测试脚本。
2. `genius-programmer`（天才程序员）Skill。

完整的 CC Switch、SDK、其他模型和视频模型中文教程已改为 WPS 文档分发，不存放在本 GitHub 仓库中。

## HrioAPI SDK 连通测试

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

## 天才程序员 Skill

Skill 位于：

```text
skills/genius-programmer/
```

主要文件：

- `SKILL.md`：Skill 的触发条件和完整操作规范。
- `agents/openai.yaml`：Codex 展示信息和默认提示。
- `references/`：项目索引与可逆暂存构建规范。

安装前请完整阅读 `SKILL.md`。手动安装到 Codex 的示例：

```powershell
Copy-Item -Recurse -Force ".\skills\genius-programmer" "$env:USERPROFILE\.codex\skills\genius-programmer"
```

重新启动 Codex 后可以显式调用：

```text
Use $genius-programmer to audit this project, announce the indexed file plan, implement the change, and verify the staged build.
```

## 安全提醒

- 不要提交真实 API Key。
- Key 泄露后应立即在 HrioAPI 控制台吊销并重新创建。
- 安装 Skill 前应检查其中的说明和可执行脚本。
- SDK 测试建议先请求模型列表，再进行小 token 文本测试。

