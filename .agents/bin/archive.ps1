# 归档 tasks/ 下过期的月目录到 archive/YYYY/MM/
# 保留当月和上月，更早的整月搬走。幂等，随时可跑。

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath (Join-Path (Join-Path $PSScriptRoot '..') '..')).Path
$tasks = Join-Path $root 'tasks'
$archive = Join-Path $root 'archive'
$log = Join-Path (Join-Path $root '.agents') 'archive.log'

function Write-ArchiveLog {
    param([string]$Message)

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -LiteralPath $log -Value "$timestamp $Message" -Encoding UTF8
}

if (-not (Test-Path -LiteralPath $tasks -PathType Container)) {
    Write-ArchiveLog '跳过：tasks/ 不存在'
    exit 0
}

# 保留下界：上月的 YYYYMM。小于它的月目录搬走。
$keepFrom = [int]((Get-Date).AddMonths(-1).ToString('yyyyMM'))
$moved = 0

foreach ($directory in Get-ChildItem -LiteralPath $tasks -Directory -Force) {
    if ($directory.Name -notmatch '^(?<year>[0-9]{4})-(?<month>[0-9]{2})$') {
        continue
    }

    $year = $Matches['year']
    $month = $Matches['month']
    $monthKey = [int]"$year$month"
    if ($monthKey -ge $keepFrom) {
        continue
    }

    # 空目录直接删，不值得归档。
    if (@(Get-ChildItem -LiteralPath $directory.FullName -Force).Count -eq 0) {
        Remove-Item -LiteralPath $directory.FullName
        continue
    }

    $targetParent = Join-Path $archive $year
    $target = Join-Path $targetParent $month
    if (Test-Path -LiteralPath $target) {
        Write-ArchiveLog "冲突：archive/$year/$month 已存在，跳过 $($directory.Name)（需手动处理）"
        [Console]::Error.WriteLine("archive.ps1: $target 已存在，跳过 $($directory.Name)（需手动处理）")
        continue
    }

    New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    Move-Item -LiteralPath $directory.FullName -Destination $target
    Write-ArchiveLog "归档：$($directory.Name) -> archive/$year/$month"
    Write-Output "archive.ps1: $($directory.Name) -> archive/$year/$month"
    $moved++
}

if ($moved -eq 0) {
    Write-ArchiveLog "运行：无过期月目录（保留下界 $keepFrom）"
}

exit 0
