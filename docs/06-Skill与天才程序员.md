# 06：Skill 安装与“天才程序员”使用提醒

仓库包含两个 Skill：

- `skills/hrio-api-onboarding`：让 Codex 按固定流程配置、测试和排查 HrioAPI。
- `skills/genius-programmer`：用于带文件编号索引、重命名映射和可逆暂存构建契约的结构化项目。

## 方式一：用 CC Switch 安装

1. 打开 CC Switch。
2. 点击顶部 `Skills`。
3. 打开“仓库管理”。
4. 添加本教程 GitHub 仓库地址。
5. 刷新技能列表。
6. 找到 `hrio-api-onboarding` 或 `genius-programmer`。
7. 点击安装，并勾选要同步到 Codex/Claude/OpenCode 等应用。
8. 重启对应客户端。

CC Switch 的 Skill 源存储默认在 `~/.cc-switch/skills/`，也可切换到 `~/.agents/skills`；它会再通过软链接或复制同步到各客户端目录。

## 方式二：手动安装到 Codex

把整个 Skill 文件夹复制到 Codex Skills 目录。例如 Windows PowerShell：

```powershell
Copy-Item -Recurse -Force ".\skills\hrio-api-onboarding" "$env:USERPROFILE\.codex\skills\hrio-api-onboarding"
Copy-Item -Recurse -Force ".\skills\genius-programmer" "$env:USERPROFILE\.codex\skills\genius-programmer"
```

重新打开 Codex 后，可显式调用：

```text
Use $hrio-api-onboarding to connect my HrioAPI key to CC Switch and test MODEL_ID.
```

```text
Use $genius-programmer to audit this project, announce the indexed file plan, implement the change, and verify the staged build.
```

## 什么时候使用天才程序员 Skill

当项目里出现下面文件或规则时使用：

- `代码文件功能编号索引.md`
- `代码文件重命名映射.json`
- `正则替换.txt`
- 编号源文件和严格文件头说明
- 要求修改前宣布文件范围
- 构建前要在独立暂存目录恢复自然文件名或做临时替换

它会要求 Agent：

1. 修改前完整读取项目契约和候选文件。
2. 在 commentary 中告诉用户将改哪些现有文件、新文件、索引和测试。
3. 新功能按模块和编号拆分，不把所有逻辑堆进根入口。
4. 同步文件头、编号索引和重命名映射。
5. 只在独立暂存目录做构建期正则替换或恢复原名。
6. 最后报告验证结果和未执行项。

## 什么时候不要使用

- 只有一个普通 Markdown 的小修改。
- 项目没有编号索引/映射契约，也不要求这种结构。
- 只想问问题或读代码，不会修改文件。

不要为了“显得专业”强行给普通项目加编号体系；这会增加维护成本。

## 安全提醒

Skill 是给 AI Agent 的操作说明，也可能包含可执行脚本。安装第三方 Skill 前应阅读 `SKILL.md` 和 `scripts/`，确认没有上传密钥、删除目录或修改生产环境的行为。

