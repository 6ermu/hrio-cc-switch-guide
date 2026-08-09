<#
文件：skills/workspace/genius-programmer/scripts/m57-f01-project-index-audit.ps1
编号：M57-F01
模块：M57 Workspace Skills
类型：只读审计脚本
职责：校验项目代码索引、重命名映射、正则规则、文件头和目标关键词匹配结果。
主要函数/入口：Resolve-ProjectPath、Get-RelativePath、Add-Issue、主审计流程
Agent 阅读提示：脚本只读项目文件；修改前用 Query 定位候选文件，修改后用 Strict 验收。
版权：狐一狐版权声明占位符
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectRoot,

  [string]$IndexFile = '代码文件功能编号索引.md',
  [string]$MappingFile = '代码文件重命名映射.json',
  [string]$RegexFile = '正则替换.txt',
  [string[]]$Query = @(),
  [switch]$Json,
  [switch]$Strict
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ProjectPath {
  param([string]$Root, [string]$RelativePath)

  $rootFull = [IO.Path]::GetFullPath($Root)
  $candidate = [IO.Path]::GetFullPath((Join-Path $rootFull $RelativePath))
  $prefix = $rootFull.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
  if (-not $candidate.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -and $candidate -ne $rootFull) {
    throw "路径逃逸项目根目录：$RelativePath"
  }
  return $candidate
}

function Get-RelativePath {
  param([string]$Root, [string]$FullPath)
  $rootUri = New-Object Uri (($Root.TrimEnd('\', '/') + '\'))
  $fullUri = New-Object Uri ($FullPath)
  return [Uri]::UnescapeDataString($rootUri.MakeRelativeUri($fullUri).ToString()).Replace('\', '/')
}

$root = (Resolve-Path -LiteralPath $ProjectRoot).Path
$issues = [Collections.Generic.List[object]]::new()

function Add-Issue {
  param([string]$Category, [string]$Message, [string]$Path = '')
  $issues.Add([pscustomobject]@{ category = $Category; message = $Message; path = $Path })
}

$indexPath = Resolve-ProjectPath $root $IndexFile
$mappingPath = Resolve-ProjectPath $root $MappingFile
$regexPath = Resolve-ProjectPath $root $RegexFile

foreach ($required in @(
  [pscustomobject]@{ name = 'index'; path = $indexPath },
  [pscustomobject]@{ name = 'mapping'; path = $mappingPath },
  [pscustomobject]@{ name = 'regex'; path = $regexPath }
)) {
  if (-not (Test-Path -LiteralPath $required.path -PathType Leaf)) {
    Add-Issue 'missing-contract' "缺少 $($required.name) 文件" (Get-RelativePath $root $required.path)
  }
}

$entries = [Collections.Generic.List[object]]::new()
if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
  $module = ''
  foreach ($line in Get-Content -LiteralPath $indexPath -Encoding UTF8) {
    if ($line -match '^## ((?:M|T)\d{2}.*)$') {
      $module = $Matches[1]
      continue
    }
    if ($line -match '^\| ((?:M|T)\d{2}-[A-Z]\d{2}) \| \[[^\]]+\]\(([^)]+)\) \| ([^|]+) \| ([^|]+) \|$') {
      $entries.Add([pscustomobject]@{
        code = $Matches[1]
        path = $Matches[2].Replace('\', '/')
        type = $Matches[3].Trim()
        function = $Matches[4].Trim()
        module = $module
      })
    }
  }
}

foreach ($duplicate in $entries | Group-Object code | Where-Object Count -gt 1) {
  Add-Issue 'duplicate-code' "重复功能编号：$($duplicate.Name)"
}
foreach ($duplicate in $entries | Group-Object path | Where-Object Count -gt 1) {
  Add-Issue 'duplicate-index-path' "索引路径重复：$($duplicate.Name)" $duplicate.Name
}

$commentableExtensions = @('.go', '.ts', '.tsx', '.js', '.jsx', '.cjs', '.mjs', '.css', '.rs', '.ps1', '.py', '.sh')
foreach ($entry in $entries) {
  $fullPath = Resolve-ProjectPath $root $entry.path
  if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
    Add-Issue 'missing-index-target' "索引目标不存在：$($entry.code)" $entry.path
    continue
  }

  $extension = [IO.Path]::GetExtension($fullPath).ToLowerInvariant()
  if ($commentableExtensions -contains $extension) {
    $head = (Get-Content -LiteralPath $fullPath -Encoding UTF8 -TotalCount 24) -join "`n"
    foreach ($token in @("编号：$($entry.code)", '职责：', '版权：狐一狐版权声明占位符')) {
      if ($head -notlike "*$token*") {
        Add-Issue 'incomplete-file-header' "文件头缺少：$token" $entry.path
      }
    }
    if ($head -notmatch '(主要|委托)(函数|测试|样式|导出|入口|规则)') {
      Add-Issue 'incomplete-file-header' '文件头缺少主要函数/测试/样式/导出说明' $entry.path
    }
  }
}

$mappingSummary = [pscustomobject]@{ schemaVersion = $null; count = 0 }
if (Test-Path -LiteralPath $mappingPath -PathType Leaf) {
  try {
    $mapping = Get-Content -LiteralPath $mappingPath -Encoding UTF8 -Raw | ConvertFrom-Json
    $renames = @($mapping.renames)
    $mappingSummary = [pscustomobject]@{ schemaVersion = $mapping.schemaVersion; count = $renames.Count }

    foreach ($duplicate in $renames | Group-Object oldPath | Where-Object Count -gt 1) {
      Add-Issue 'duplicate-old-path' "oldPath 重复：$($duplicate.Name)" $duplicate.Name
    }
    foreach ($duplicate in $renames | Group-Object newPath | Where-Object Count -gt 1) {
      Add-Issue 'duplicate-new-path' "newPath 重复：$($duplicate.Name)" $duplicate.Name
    }
    foreach ($rename in $renames) {
      if ([string]::IsNullOrWhiteSpace($rename.id) -or [string]::IsNullOrWhiteSpace($rename.oldPath) -or [string]::IsNullOrWhiteSpace($rename.newPath)) {
        Add-Issue 'invalid-mapping-row' '映射项缺少 id、oldPath 或 newPath'
        continue
      }
      $newFull = Resolve-ProjectPath $root $rename.newPath
      if (-not (Test-Path -LiteralPath $newFull -PathType Leaf)) {
        Add-Issue 'missing-mapped-source' '映射 newPath 不存在' $rename.newPath
      }
    }
  } catch {
    Add-Issue 'invalid-mapping-json' $_.Exception.Message (Get-RelativePath $root $mappingPath)
  }
}

$regexRuleCount = 0
if (Test-Path -LiteralPath $regexPath -PathType Leaf) {
  $singleTriple = "'''"
  $doubleTriple = '"""'
  $separator = $singleTriple + '=' + $doubleTriple
  $lineNumber = 0
  foreach ($line in Get-Content -LiteralPath $regexPath -Encoding UTF8) {
    $lineNumber++
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith('#')) { continue }
    $separatorIndex = $trimmed.IndexOf($separator, $singleTriple.Length, [StringComparison]::Ordinal)
    if (-not $trimmed.StartsWith($singleTriple, [StringComparison]::Ordinal) -or
        -not $trimmed.EndsWith($doubleTriple, [StringComparison]::Ordinal) -or
        $separatorIndex -lt $singleTriple.Length) {
      Add-Issue 'invalid-regex-rule' "第 $lineNumber 行格式无效" (Get-RelativePath $root $regexPath)
      continue
    }
    $pattern = $trimmed.Substring($singleTriple.Length, $separatorIndex - $singleTriple.Length)
    try {
      [void][regex]::new($pattern)
      $regexRuleCount++
    } catch {
      Add-Issue 'invalid-regex-pattern' "第 $lineNumber 行正则无效：$($_.Exception.Message)" (Get-RelativePath $root $regexPath)
    }
  }
}

$matches = @()
if ($Query.Count -gt 0) {
  $matches = @($entries | Where-Object {
    $entry = $_
    foreach ($term in $Query) {
      $haystack = "$($entry.code) $($entry.module) $($entry.path) $($entry.type) $($entry.function)"
      if ($haystack.IndexOf($term, [StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
    }
    return $false
  })
}

$result = [pscustomobject]@{
  projectRoot = $root
  contracts = [pscustomobject]@{
    index = Get-RelativePath $root $indexPath
    mapping = Get-RelativePath $root $mappingPath
    regex = Get-RelativePath $root $regexPath
  }
  indexedFiles = $entries.Count
  mapping = $mappingSummary
  regexRules = $regexRuleCount
  query = $Query
  matches = $matches
  issueCount = $issues.Count
  issues = @($issues)
}

if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  $result | Select-Object projectRoot, indexedFiles, regexRules, issueCount | Format-List
  if ($matches.Count -gt 0) {
    '匹配的索引文件：'
    $matches | Format-Table code, module, path, type, function -AutoSize
  }
  if ($issues.Count -gt 0) {
    '发现的问题：'
    $issues | Format-Table category, path, message -AutoSize
  }
}

if ($Strict -and $issues.Count -gt 0) { exit 1 }

