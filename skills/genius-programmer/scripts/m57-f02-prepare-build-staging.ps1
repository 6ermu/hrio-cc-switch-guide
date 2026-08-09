<#
文件：skills/workspace/genius-programmer/scripts/m57-f02-prepare-build-staging.ps1
编号：M57-F02
模块：M57 Workspace Skills
类型：可逆构建暂存脚本
职责：复制源码到全新临时目录，应用正则规则、恢复自然文件名并裁剪非编译文件。
主要函数/入口：Resolve-SafeChildPath、Get-RegexRules、Get-TextFiles、主暂存流程
Agent 阅读提示：默认仅预览；只有显式 Execute 才创建暂存副本，绝不回写源码工作区。
版权：狐一狐版权声明占位符
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectRoot,

  [string]$StagingRoot,
  [string]$MappingFile = '代码文件重命名映射.json',
  [string]$RegexFile = '正则替换.txt',
  [string[]]$ExcludeDirectories = @(
    '.git', 'node_modules', 'dist', 'release', 'target', 'coverage',
    '.nx', '.turbo', 'legacy', 'reference', 'docs', 'skills', '.codex'
  ),
  [string[]]$ExcludeFiles = @(
    '代码文件功能编号索引.md', '项目主文件夹索引.md',
    '代码文件重命名映射.json', '正则替换.txt'
  ),
  [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-SafeChildPath {
  param([string]$Root, [string]$RelativePath)

  $rootFull = [IO.Path]::GetFullPath($Root)
  $candidate = [IO.Path]::GetFullPath((Join-Path $rootFull $RelativePath))
  $prefix = $rootFull.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
  if (-not $candidate.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "路径逃逸暂存目录：$RelativePath"
  }
  return $candidate
}

function Get-StageRelativePath {
  param([string]$Root, [string]$FullPath)
  $rootUri = New-Object Uri (($Root.TrimEnd('\', '/') + '\'))
  $fullUri = New-Object Uri ($FullPath)
  return [Uri]::UnescapeDataString($rootUri.MakeRelativeUri($fullUri).ToString()).Replace('\', '/')
}

function Get-RegexRules {
  param([string]$Path)

  $rules = [Collections.Generic.List[object]]::new()
  $singleTriple = "'''"
  $doubleTriple = '"""'
  $separator = $singleTriple + '=' + $doubleTriple
  $lineNumber = 0
  foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
    $lineNumber++
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith('#')) { continue }
    $separatorIndex = $trimmed.IndexOf($separator, $singleTriple.Length, [StringComparison]::Ordinal)
    if (-not $trimmed.StartsWith($singleTriple, [StringComparison]::Ordinal) -or
        -not $trimmed.EndsWith($doubleTriple, [StringComparison]::Ordinal) -or
        $separatorIndex -lt $singleTriple.Length) {
      throw "正则替换规则第 $lineNumber 行格式无效"
    }
    $pattern = $trimmed.Substring($singleTriple.Length, $separatorIndex - $singleTriple.Length)
    $replacementStart = $separatorIndex + $separator.Length
    $replacementLength = $trimmed.Length - $replacementStart - $doubleTriple.Length
    $replacement = $trimmed.Substring($replacementStart, $replacementLength)
    $compiled = [regex]::new($pattern, [Text.RegularExpressions.RegexOptions]::Multiline)
    $rules.Add([pscustomobject]@{ line = $lineNumber; regex = $compiled; replacement = $replacement })
  }
  return @($rules)
}

function Get-TextFiles {
  param([string]$Root)

  $extensions = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
  foreach ($extension in @(
    '.ts', '.tsx', '.js', '.jsx', '.cjs', '.mjs', '.css', '.scss', '.less',
    '.rs', '.ps1', '.py', '.sh', '.md', '.txt', '.json', '.jsonc', '.yaml', '.yml',
    '.toml', '.xml', '.html', '.htm', '.svg', '.env', '.properties'
  )) { [void]$extensions.Add($extension) }

  return @(Get-ChildItem -LiteralPath $Root -Recurse -File -Force | Where-Object {
    $extensions.Contains([IO.Path]::GetExtension($_.Name)) -or $_.Name -in @('Dockerfile', 'Makefile')
  })
}

$sourceRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$mappingPath = Resolve-SafeChildPath $sourceRoot $MappingFile
$regexPath = Resolve-SafeChildPath $sourceRoot $RegexFile
if (-not (Test-Path -LiteralPath $mappingPath -PathType Leaf)) { throw "缺少映射文件：$MappingFile" }
if (-not (Test-Path -LiteralPath $regexPath -PathType Leaf)) { throw "缺少正则文件：$RegexFile" }

$mapping = Get-Content -LiteralPath $mappingPath -Encoding UTF8 -Raw | ConvertFrom-Json
$renames = @($mapping.renames)
$rules = @(Get-RegexRules $regexPath)

if ([string]::IsNullOrWhiteSpace($StagingRoot)) {
  $safeProjectName = ([IO.Path]::GetFileName($sourceRoot) -replace '[^A-Za-z0-9._-]', '_')
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
  $StagingRoot = Join-Path ([IO.Path]::GetTempPath()) "genius-programmer-builds\$safeProjectName-$stamp"
}
$stage = [IO.Path]::GetFullPath($StagingRoot)
$sourcePrefix = $sourceRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$stagePrefix = $stage.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
if ($stage -eq $sourceRoot -or $sourceRoot.StartsWith($stagePrefix, [StringComparison]::OrdinalIgnoreCase) -or $stage.StartsWith($sourcePrefix, [StringComparison]::OrdinalIgnoreCase)) {
  throw '暂存目录不得等于源码目录、位于源码目录内部或包含源码目录'
}
if (Test-Path -LiteralPath $stage) { throw "暂存目录已存在，拒绝覆盖：$stage" }

$preview = [pscustomobject]@{
  projectRoot = $sourceRoot
  stagingRoot = $stage
  execute = [bool]$Execute
  regexRules = $rules.Count
  renameMappings = $renames.Count
  excludeDirectories = $ExcludeDirectories
  excludeFiles = $ExcludeFiles
}
if (-not $Execute) {
  $preview | ConvertTo-Json -Depth 5
  return
}

$robocopy = Get-Command robocopy -ErrorAction SilentlyContinue
if (-not $robocopy) { throw '当前系统缺少 robocopy，无法安全创建带排除规则的暂存副本' }

$copyArgs = @($sourceRoot, $stage, '/E', '/COPY:DAT', '/DCOPY:DAT', '/R:1', '/W:1', '/NFL', '/NDL', '/NJH', '/NJS', '/NP')
if ($ExcludeDirectories.Count -gt 0) {
  $copyArgs += '/XD'
  foreach ($directory in $ExcludeDirectories) {
    $copyArgs += $directory
  }
}
if ($ExcludeFiles.Count -gt 0) {
  $copyArgs += '/XF'
  foreach ($file in $ExcludeFiles) {
    $copyArgs += $file
  }
}

& $robocopy.Source @copyArgs | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy 失败，退出码：$LASTEXITCODE" }
if (-not (Test-Path -LiteralPath $stage -PathType Container)) { throw '暂存目录创建失败' }

$utf8 = [Text.UTF8Encoding]::new($false)
$regexChanges = [Collections.Generic.List[object]]::new()
$textFiles = Get-TextFiles $stage
foreach ($file in $textFiles) {
  $content = [IO.File]::ReadAllText($file.FullName)
  $updated = $content
  foreach ($rule in $rules) {
    $updated = $rule.regex.Replace($updated, $rule.replacement)
  }
  if ($updated -cne $content) {
    [IO.File]::WriteAllText($file.FullName, $updated, $utf8)
    $regexChanges.Add([pscustomobject]@{ path = Get-StageRelativePath $stage $file.FullName; kind = 'regex' })
  }
}

$referenceChanges = [Collections.Generic.List[object]]::new()
$replacementPairs = [Collections.Generic.List[object]]::new()
foreach ($rename in $renames) {
  $newPath = ([string]$rename.newPath).Replace('\', '/')
  $oldPath = ([string]$rename.oldPath).Replace('\', '/')
  $newName = [IO.Path]::GetFileName($newPath)
  $oldName = [IO.Path]::GetFileName($oldPath)
  $newStem = [IO.Path]::GetFileNameWithoutExtension($newName)
  $oldStem = [IO.Path]::GetFileNameWithoutExtension($oldName)
  foreach ($pair in @(
    [pscustomobject]@{ from = $newPath; to = $oldPath },
    [pscustomobject]@{ from = $newPath.Replace('/', '\'); to = $oldPath.Replace('/', '\') },
    [pscustomobject]@{ from = $newName; to = $oldName },
    [pscustomobject]@{ from = $newStem; to = $oldStem }
  )) {
    if ($pair.from -and $pair.from -ne $pair.to) { $replacementPairs.Add($pair) }
  }
}
$replacementPairs = @($replacementPairs | Sort-Object { $_.from.Length } -Descending)

$textFiles = Get-TextFiles $stage
foreach ($file in $textFiles) {
  $content = [IO.File]::ReadAllText($file.FullName)
  $updated = $content
  foreach ($pair in $replacementPairs) {
    $updated = $updated.Replace($pair.from, $pair.to)
  }
  if ($updated -cne $content) {
    [IO.File]::WriteAllText($file.FullName, $updated, $utf8)
    $referenceChanges.Add([pscustomobject]@{ path = Get-StageRelativePath $stage $file.FullName; kind = 'reference' })
  }
}

$moves = [Collections.Generic.List[object]]::new()
foreach ($rename in $renames | Sort-Object { ([string]$_.newPath).Length } -Descending) {
  $normalizedNewPath = ([string]$rename.newPath).Replace('\', '/')
  $topDirectory = ($normalizedNewPath -split '/')[0]
  if ($ExcludeDirectories -contains $topDirectory) {
    $moves.Add([pscustomobject]@{ id = $rename.id; from = $rename.newPath; to = $rename.oldPath; status = 'excluded-directory' })
    continue
  }
  $source = Resolve-SafeChildPath $stage $rename.newPath
  $destination = Resolve-SafeChildPath $stage $rename.oldPath
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    $moves.Add([pscustomobject]@{ id = $rename.id; from = $rename.newPath; to = $rename.oldPath; status = 'source-missing' })
    continue
  }
  $destinationDirectory = Split-Path -Parent $destination
  [void](New-Item -ItemType Directory -Path $destinationDirectory -Force)
  $status = 'moved'
  if (Test-Path -LiteralPath $destination) {
    Remove-Item -LiteralPath $destination -Force
    $status = 'replaced-staging-entry'
  }
  Move-Item -LiteralPath $source -Destination $destination
  $moves.Add([pscustomobject]@{ id = $rename.id; from = $rename.newPath; to = $rename.oldPath; status = $status })
}

Get-ChildItem -LiteralPath $stage -Recurse -Directory -Force |
  Sort-Object FullName -Descending |
  Where-Object { @(Get-ChildItem -LiteralPath $_.FullName -Force).Count -eq 0 } |
  Remove-Item -Force

$manifest = [pscustomobject]@{
  schemaVersion = 'genius-programmer.build-staging.v1'
  createdAt = (Get-Date).ToString('o')
  sourceRoot = $sourceRoot
  stagingRoot = $stage
  regexRuleCount = $rules.Count
  regexChanges = @($regexChanges)
  referenceChanges = @($referenceChanges)
  moves = @($moves)
  exclusions = [pscustomobject]@{ directories = $ExcludeDirectories; files = $ExcludeFiles }
}
$manifestPath = "$stage.manifest.json"
[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8), $utf8)

[pscustomobject]@{
  stagingRoot = $stage
  manifest = $manifestPath
  regexChangedFiles = $regexChanges.Count
  referenceChangedFiles = $referenceChanges.Count
  movedFiles = @($moves | Where-Object { $_.status -in @('moved', 'replaced-staging-entry') }).Count
  skippedMappings = @($moves | Where-Object status -eq 'source-missing').Count
  excludedMappings = @($moves | Where-Object status -eq 'excluded-directory').Count
} | ConvertTo-Json -Depth 5

