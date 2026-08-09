---
name: genius-programmer
description: Index-driven, auditable project modification and reversible staged-build workflow. Use whenever Codex changes, adds, splits, renames, refactors, tests, or builds files in a structured project—especially when the project contains 代码文件功能编号索引.md, 代码文件重命名映射.json, 正则替换.txt, numbered source files, per-file descriptions, or requires announcing the exact file/index plan before editing.
---

# 天才程序员 Skill

> 文件：`skills/workspace/genius-programmer/SKILL.md`  
> 职责：约束 Agent 以索引驱动、模块拆分、文件头同步和可逆暂存构建的方式修改项目。  
> 版权：狐一狐版权声明占位符

## 1. 先建立项目上下文

1. 解析项目根目录，不要假定当前目录就是根目录。
2. 先完整读取仓库级指令文件，再读取以下项目契约；文件缺失时先报告并在变更计划中创建：
   - `代码文件功能编号索引.md`
   - `代码文件重命名映射.json`
   - `正则替换.txt`
   - `README.md`
3. 运行只读审计：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File <skill>/scripts/m57-f01-project-index-audit.ps1 -ProjectRoot <root> -Query <关键词> -Json
   ```

4. 根据功能编号、模块名、路径、文件名和功能描述定位候选文件。
5. 修改前完整读取每个候选文件，不得只读局部片段。重点核对顶部描述、导入、导出、公开类型、主要函数、测试和调用边界。

详细契约见 [项目索引与文件头规范](references/m57-f03-project-contract.md)。

## 2. 修改前必须通知用户

在 commentary 中列出并继续工作：

| 内容 | 要求 |
|---|---|
| 现有文件 | 功能编号、仓库相对路径、修改原因 |
| 新文件/目录 | 拟分配编号、路径、拆分职责 |
| 契约文件 | 将更新的索引、映射、README、测试或配置 |
| 验证 | 计划执行的类型检查、测试、构建命令 |

不得在未通知文件范围的情况下直接实施。发现范围扩大时，先补充通知再继续。

## 3. 按文件夹和子文件拆分功能

- 一个子文件只承担一个可描述的领域职责、运行时边界或测试职责。
- 新功能优先放入所属模块文件夹的子文件；不要继续向根入口、巨型组件或公共桶文件堆叠实现。
- 当逻辑具有独立状态、独立测试、独立平台边界或可复用 API 时，拆成独立子文件。
- 框架要求的固定文件名（如 `SKILL.md`、`vite.config.ts`、`lib.rs`、`main.rs`）保留为薄入口；真实实现使用编号文件。
- 新文件必须先分配模块编号与文件编号，再写代码。编号不得与索引重复。
- 不为了形式拆出无意义的一行包装；拆分必须形成清晰依赖方向。

## 4. 实施修改并刷新文件头

1. 使用最小范围补丁，保留用户已有改动。
2. 同步修改调用方、测试、类型和配置。
3. 修改完成后重新通读整个文件，基于最终代码重写顶部描述，不能保留过时的函数列表。
4. 文件头至少包含：文件路径、编号、模块、类型、职责、主要函数/类型/入口、Agent 阅读提示、`狐一狐版权声明占位符`。
5. 测试文件列出主要 `describe`/`it`/`test` 场景；样式文件列出主要选择器；公共 API 列出重导出；薄入口列出委托实现。
6. 严格 JSON、JSON Schema、Manifest 不插入注释；在索引中记录职责和统一版权占位规则。

## 5. 同步索引与重命名映射

新增、删除、拆分或重命名文件时必须同时更新：

- `代码文件功能编号索引.md`：记录编号、单一 `[打开](仓库相对路径)` 链接、文件类型和具体功能。
- `代码文件重命名映射.json`：同时保留自然/非索引名 `oldPath` 与实际编号名 `newPath`。
- 项目已有的目录索引、模块清单或迁移文档。

映射规则：

- `oldPath` 表示未编号、框架原名或面向构建的自然名称。
- `newPath` 表示源码工作区中的编号名称。
- 框架固定入口本身不强制改名；其编号使用 `E`，实现文件使用 `F`。
- 更新 `generatedAt`，保持 JSON 有效，拒绝重复 `oldPath`、`newPath` 或编号。

## 6. 最后审阅 README

全部代码和索引修改完成后，完整读取根 `README.md`：

- 架构边界、目录职责、运行入口或依赖发生变化时更新架构说明。
- 新增或改变开发、测试、构建、打包命令时更新快速命令。
- 纯内部实现且用户使用方式不变时不做无意义改写。

## 7. 验证源码工作区

1. 再运行索引审计并启用严格模式。
2. 检查所有链接存在、编号唯一、映射有效、文件头完整。
3. 运行与风险相称的类型检查、测试和构建。
4. 构建失败时先修复源码工作区，不得用暂存替换掩盖真实错误。

## 8. 仅在暂存目录执行编译替换

禁止在源码工作区执行版权替换、批量恢复原名或删除编译无关文件。

1. 先预览：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File <skill>/scripts/m57-f02-prepare-build-staging.ps1 -ProjectRoot <root>
   ```

2. 用户要求正式编译或工作流明确需要时，创建独立暂存副本：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File <skill>/scripts/m57-f02-prepare-build-staging.ps1 -ProjectRoot <root> -Execute
   ```

3. 脚本只在暂存目录中：
   - 按 `正则替换.txt` 每行规则执行临时正则替换；
   - 按映射把 `newPath` 恢复为 `oldPath` 并同步文本引用；
   - 排除索引、Skill、文档、旧工程、参考源码和生成目录；
   - 生成变换清单。
4. 在脚本输出的暂存目录运行项目构建命令。
5. 不把暂存结果反向覆盖源码；只交付明确的构建产物。

详细安全边界见 [可逆暂存构建规范](references/m57-f04-build-staging.md)。

## 9. 完成汇报

最终说明：

- 修改、新增、拆分和删除的文件及编号；
- 更新的索引、映射与 README；
- 文件头刷新数量；
- 验证和构建结果；
- 暂存目录、临时替换和恢复原名是否执行；
- 未执行项及原因。
