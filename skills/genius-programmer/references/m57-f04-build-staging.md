<!--
文件：skills/workspace/genius-programmer/references/m57-f04-build-staging.md
编号：M57-F04
模块：M57 Workspace Skills
职责：定义临时正则替换、恢复自然文件名、裁剪非编译文件和构建暂存目录的安全边界。
主要规则：源码只读、暂存变换、清单审计、禁止反向覆盖。
版权：狐一狐版权声明占位符
-->

# 可逆暂存构建规范

## 不变量

- 源码工作区永远保留编号文件名、完整索引、文件头和版权占位符。
- 临时替换、恢复自然名和裁剪只发生在新建暂存目录。
- 暂存目录不得是项目根目录、其父目录或已有目录。
- 不执行从暂存目录到源码目录的反向同步。
- 删除只允许作用于经过路径校验的暂存目录内容。

## 正则规则格式

`正则替换.txt` 每个非空、非注释行是一条规则：

```text
'''狐一狐版权声明占位符'''="""狐一狐临时占位符"""
```

- 三个单引号之间是 .NET 正则表达式。
- 三个双引号之间是替换文本。
- 规则按文件顺序、行顺序执行。
- 规则无效时终止，不得跳过后继续构建。
- 只处理已知文本扩展名，不读取图片、字体、压缩包或二进制模型。

## 恢复自然文件名

读取 `代码文件重命名映射.json`，在暂存目录中执行 `newPath -> oldPath`：

1. 先替换源码、配置和脚本中的完整路径及文件名引用。
2. 再把编号文件移动到自然路径。
3. 目标自然路径已存在薄入口时，只在暂存目录删除薄入口后替换。
4. 缺少 `newPath` 时记录为跳过；路径逃逸时立即终止。
5. 输出每次移动、覆盖和跳过的清单。

## 默认裁剪

暂存副本默认排除：

- `.git/`、`node_modules/`、`dist/`、`release/`、`target/`、`coverage/`；
- `legacy/`、`reference/`、`docs/`、`skills/`；
- `代码文件功能编号索引.md`、`项目主文件夹索引.md`、`代码文件重命名映射.json`、`正则替换.txt`。

项目构建需要其中某项时，显式覆盖排除参数并在变更通知中说明。不要凭感觉删除源码、包清单、锁文件、Schema、测试夹具或构建配置。

## 推荐流程

```powershell
# 1. 只预览
powershell -NoProfile -ExecutionPolicy Bypass -File <skill>/scripts/m57-f02-prepare-build-staging.ps1 -ProjectRoot <root>

# 2. 创建暂存副本并执行变换
powershell -NoProfile -ExecutionPolicy Bypass -File <skill>/scripts/m57-f02-prepare-build-staging.ps1 -ProjectRoot <root> -Execute

# 3. 在输出目录中安装依赖并运行项目自己的构建命令
Set-Location <staging-path>
pnpm install --frozen-lockfile
pnpm build
```

构建后只交付构建产物和变换清单。暂存目录可直接丢弃；源码目录不需要“还原”。
