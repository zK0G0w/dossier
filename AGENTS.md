# dossier

日常小任务、调研、写作的工作区。代码相关的活不在这里做 —— 去对应的仓库目录。

这份文件是路由层，不含具体做法。**先判断任务类型，用 Read 读对应分册，再动手。**

## 路由表

| 任务特征 | 读这份 |
|---|---|
| 要查多个源、交叉验证、产出带引用的结论 | `.agents/playbooks/research.md` |
| 产出给人看的成品文档（方案、周报、邮件、评审意见） | `.agents/playbooks/writing.md` |
| 处理数据文件、对账、清洗、跑一次性脚本 | `.agents/playbooks/data.md` |
| 拿不定主意想被质问，或想学明白一个新东西 | `.agents/playbooks/thinking.md` |

一个任务跨两类（调研完要写方案）就按顺序读两份，不用纠结归哪类。四类都不沾的小事直接答，别硬套流程。

动手前先写一行路由判断：`任务类型：research → 读 .agents/playbooks/research.md`。这行是检查点 —— 没写，就说明分册多半没读。判断结果是「四类都不沾」也要把这行写出来（`任务类型：无 → 不读分册`），别跳过。

**「四类都不沾」只免掉读分册，不免掉硬约束 1 的三条建档触发条件。** 这两套判断互不相干：路由表决定读哪份分册，触发条件决定要不要落盘。前者为空时后者照样要逐条对照 —— 修脚本、改配置、排查报错这类活不在路由表里，但一样会抓资料、跑脚本、产出需要复查的依据。

## 目录约定

```
tasks/YYYY-MM/DD-任务名/      当月和上月的任务
inbox/                        还没开工的原始输入
archive/YYYY/MM/              两个月前的任务，自动归档
.agents/playbooks/            四份分册
.agents/templates/TASK.md     任务入口模板
```

任务目录命名：`tasks/2026-08/31-竞品计费模式调研/`。月份分桶，日期两位数前缀，后面跟中文描述性名字。同一天多个任务就是多个 `31-xxx` 目录，正常。

## 三条硬约束

**1. 懒建立，但触发了就必须建。** 默认在对话里答，不碰磁盘。纯问答、一句话能答完的事，不建目录。

出现下面任一情况，立刻建 `tasks/YYYY-MM/DD-slug/`，不再自行裁量：

- WebFetch / WebSearch 取回了正文
- 跑脚本产出了结果文件
- 给出的结论超过一屏，或包含日后需要复查的依据

这三条只看事实是否发生，不看任务属于哪类、也不看任务是否在路由表里。对照一遍，命中任一条就建。

这条的默认值和通用助手相反。通用助手倾向于「尽量不创建文件」，在这个工作区不适用 —— 抓回来的资料必须落盘，否则结论的依据没法复查。不要拿「尽量少建文件」当跳过建目录的理由，也不要拿「这活不属于四类」当理由。

**2. 不往任务目录外写文件。** 所有产出落在当前任务目录内。不往仓库根目录写，不往 `.agents/` 写，不往别人的任务目录写。唯一例外是用户明确指定了路径。

**3. TASK.md 必须有，且带 front-matter。** 建目录的同时就写 `TASK.md`，照 `.agents/templates/TASK.md`：

```markdown
---
type: research | writing | data | thinking
status: doing | done | dropped
tags: [2-4 个词]
---

# 标题

## 目标
一两句话说清要解决什么。

## 结论
一句话。写不出来说明还没做完，就先留空或写「进行中」。

## 产物
指向本目录内的文件，一行一个，附一句这是什么。
```

这是唯一的检索入口，没有别的索引文件。找旧任务用 grep：

```bash
grep -rl 'type: research' tasks/ archive/
grep -rl '计费' tasks/ archive/ --include=TASK.md
```

Windows（PowerShell）等价写法。`-Encoding utf8` 不能省 —— Windows PowerShell 5.1 按系统代码页读无 BOM 的 UTF-8 文件，中文关键词会搜不到：

```powershell
Get-ChildItem tasks,archive -Recurse -File | Select-String -Encoding utf8 -Pattern 'type: research' -List | ForEach-Object Path
Get-ChildItem tasks,archive -Recurse -Filter TASK.md | Select-String -Encoding utf8 -Pattern '计费' -List | ForEach-Object Path
```

所以 `tags` 和「结论」要写实词，避免「相关调研」「初步分析」等无区分度的表述。

## 文档风格

产出的文档（报告、方案、纪要、汇总）遵循 `.agents/style.md`。交付前按其中的自查清单过一遍。

## 收尾

任务做完：把 `status` 改成 `done`，补上「结论」和「产物」。中途放弃改 `dropped`，并在正文写一句为什么 —— 半年后能省一次重复劳动。

沉淀到 Obsidian 是用户手动触发的动作，不要主动做，也不要问要不要做。

## 归档

`tasks/` 只保留当月和上月。更早的在会话启动时自动搬到 `archive/YYYY/MM/`：mac/Linux 跑 `.agents/bin/archive.sh`，Windows 跑 `.agents/bin/archive.ps1`，由 hook 配置按平台分流。这事不用管，也不要手动调它。

## 跨平台

工作流要在 mac/Linux 和 Windows 上都能原生跑，不假设 Windows 上装了 Git Bash 或 WSL。

- `.agents/bin/` 下的脚本成对存在：`xxx.sh` + `xxx.ps1`，两边行为必须一致，改一个就要改另一个。
- **`.ps1` 文件必须存成带 BOM 的 UTF-8。** Windows PowerShell 5.1 按系统代码页（中文机器是 GBK）读无 BOM 的脚本，注释和字符串里的中文会被拆成半个字符，吞掉后面的引号，整个脚本解析失败。`.sh` 反过来不能加 BOM，会顶掉 shebang。
- hook 按平台分流：`.claude/settings.json` 用 `shell` 字段（`bash` / `powershell`）挂两个 handler，跑不上的那个平台是静默空操作；`.codex/hooks.json` 用 `command` / `commandWindows`。
- 文档里给命令时，如果 Windows 上没有等价的原生命令（`grep`、`head`、`file` 这些都没有），补一段 PowerShell 版本，别默认用户有 Git Bash。
- 临时文件用 `/tmp/`（mac/Linux）或 `$env:TEMP`（Windows），不要写死其中一个。
