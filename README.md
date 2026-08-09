# HRIO API × CC Switch 零基础接入教程

这是一套面向零基础用户的中文教程，目标是把 [HrioAPI 控制台](https://hrioapi.hrio.site/dashboard) 的 API Key 接入 CC Switch、Codex、Claude Code，以及文本、图片、音频和视频模型调用流程。

> 安全提醒：不要把真实 API Key 写进截图、Markdown、Git 仓库、聊天记录或提交历史。教程中的 `YOUR_API_KEY`、`MODEL_ID` 都是占位符。

## 你最终会完成什么

1. 注册或登录 HrioAPI。
2. 在用户控制台创建 API Key。
3. 安装 CC Switch。
4. 在 CC Switch 创建名为 `HrioAPI` 的供应商。
5. 连接 Codex 或 Claude Code。
6. 使用脚本检查 Key、模型列表和一次最小文本请求。
7. 根据模型能力调用图片、音频、嵌入、重排和视频接口。
8. 安装并使用 `hrio-api-onboarding` 与“天才程序员”两个 Skill。

## 5 分钟快速路线

1. 打开 HrioAPI，登录后进入 `API Key` 页面并创建 Key。
2. 记住 API Base：`https://hrioapi.hrio.site/api`。
3. 安装 CC Switch，在顶部切换到 `Codex`，点击右上角 `+`。
4. 选择“自定义配置”，名称填 `HrioAPI`。
5. Responses 模式：Base URL 填 `https://hrioapi.hrio.site/api/v1`，协议选 `responses`。
6. Chat-only 模式：上游前缀填 `https://hrioapi.hrio.site/api`，开启“需要本地路由映射”，填写从 `/v1/models` 查到的模型 ID。
7. 保存、启用供应商并重启 Codex。
8. 运行：

```powershell
$env:HRIO_API_KEY="你的真实 Key"
python .\scripts\test_hrio.py --list-models
python .\scripts\test_hrio.py --model "从模型列表复制的模型 ID"
```

## 教程目录

- [01：注册、登录与创建 API Key](docs/01-注册登录与API-Key.md)
- [02：CC Switch 下载与安装](docs/02-安装CC-Switch.md)
- [03：把 HrioAPI 连接到 CC Switch](docs/03-HRIO连接CC-Switch.md)
- [04：官网 SDK 与连通测试](docs/04-SDK与连通测试.md)
- [05：其他文本、图片、音频和视频模型](docs/05-其他模型与视频模型.md)
- [06：Skill 安装与“天才程序员”使用提醒](docs/06-Skill与天才程序员.md)
- [07：常见错误排查](docs/07-常见问题.md)
- [08：发布到 GitHub](docs/08-发布到GitHub.md)

## 仓库结构

```text
assets/screenshots/              实测和上游官方截图
docs/                            零基础分章节教程
scripts/test_hrio.py             无第三方依赖的 Python 连通测试
scripts/test-hrio.ps1            Windows PowerShell 入口
templates/                       CC Switch/Codex/Claude 示例配置
skills/hrio-api-onboarding/      可安装的 HRIO 接入 Skill
skills/genius-programmer/        教程附带的天才程序员 Skill
```

## 已验证信息

- HrioAPI 前端声明的 API Base 为 `https://hrioapi.hrio.site/api`。
- `GET /api/v1/models`、`POST /api/v1/chat/completions` 在无效 Key 下返回 HTTP 401，说明鉴权入口在线。
- 前端调试器支持 Chat Completions、Responses、Anthropic Messages、Gemini、图片、视频、音频、Embedding 与 Rerank 等路径。
- CC Switch 上游最新 Release 检查时为 `v3.19.2`（2026-08-06）；请以 [Releases](https://github.com/farion1231/cc-switch/releases) 的实时版本为准。

## 截图来源

- `hrio-login.png`、`hrio-register.png`：本教程制作时从 HrioAPI 公开页面实测截取。
- `cc-switch-main-zh.png`、`cc-switch-add-zh.png`：来自 [farion1231/cc-switch](https://github.com/farion1231/cc-switch) 官方仓库，项目采用 MIT License。

## 官方链接

- [HrioAPI 控制台](https://hrioapi.hrio.site/dashboard)
- [CC Switch 官网](https://ccswitch.io)
- [CC Switch GitHub](https://github.com/farion1231/cc-switch)
- [CC Switch Releases](https://github.com/farion1231/cc-switch/releases)
- [OpenAI Codex 配置参考](https://developers.openai.com/codex/config-reference/)
- [OpenAI Codex Skills](https://developers.openai.com/codex/skills/)

> 当前环境访问 OpenAI Docs 时受到 403/Cloudflare 限制，因此保留官方链接，并用 CC Switch 官方用户手册交叉核对配置字段。长期维护前请再次打开官方文档确认变化。

## GitHub 发布状态

仓库已在本地初始化并提交。当前自动发布环境没有 GitHub 登录态、`gh` CLI 或 Token，因此无法替用户越过登录步骤创建远端仓库。登录后按 [08：发布到 GitHub](docs/08-发布到GitHub.md) 执行即可。

