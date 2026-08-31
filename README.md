# dossier

每个任务一份卷宗：`TASK.md` 是封面页，收集的材料和产物在同一个目录里，用 grep 检索。

一套供 Claude Code 和 Codex 使用的本地工作区模板。它把临时对话、正式任务、写作规范和历史归档分开管理，让 Agent 知道什么时候只回答、什么时候创建文件，以及任务完成后该留下什么。

这是工作区模板，不是应用。它不需要 Python、Node.js 或其他运行时；macOS 和 Linux 使用 Bash，Windows 使用 PowerShell。

## 适合什么场景

- 日常调研、写作、数据处理和学习讨论需要统一的存放规则。
- 希望多个 Agent 遵守同一套任务目录、文档风格和收尾要求。
- 不想让临时任务、原始输入和运行日志进入公共仓库。
- 希望旧任务按月份自动归档，而不是长期堆在工作区里。

代码项目应放在独立仓库中。本仓库只管理日常任务和知识工作。

## 快速开始

```bash
git clone https://github.com/zK0G0w/dossier.git
cd dossier
```

从仓库根目录启动 Claude Code 或 Codex，然后直接描述任务。Agent 会先读取 [AGENTS.md](AGENTS.md)，再按任务类型选择对应规则。

需要写文件时，Agent 会创建以下结构：

```text
tasks/
└── YYYY-MM/
    └── DD-任务名/
        ├── TASK.md
        └── 任务产物
```

只在对话中回答的问题不会创建目录。

## 工作方式

1. `AGENTS.md` 判断任务属于调研、写作、数据处理还是学习讨论。
2. `.agents/playbooks/` 提供各类任务的具体执行规则。
3. `.agents/templates/TASK.md` 规定任务的目标、状态、结论和产物。
4. `.agents/style.md` 约束交付文档的语言风格。
5. 会话启动 hook 将两个月前的任务移动到 `archive/YYYY/MM/`。

`tasks/` 只保留当前月和上月。归档脚本可以重复运行，遇到目标目录冲突时会跳过并写入日志，不会覆盖已有内容。

## 目录结构

| 路径 | 用途 | 是否提交个人内容 |
|---|---|---|
| `tasks/` | 当前月和上月的正式任务 | 否 |
| `archive/` | 按年份、月份保存的历史任务 | 否 |
| `inbox/` | 尚未整理成任务的原始输入 | 否 |
| `.agents/playbooks/` | 四类任务的执行规则 | 是 |
| `.agents/templates/` | 任务入口模板 | 是 |
| `.agents/bin/` | macOS、Linux 和 Windows 归档脚本 | 是 |
| `.claude/settings.json` | Claude Code 会话启动 hook | 是 |
| `.codex/hooks.json` | Codex 会话启动 hook | 是 |

## 跨平台支持

| 平台 | 归档脚本 | 运行环境 |
|---|---|---|
| macOS | `.agents/bin/archive.sh` | Bash |
| Linux | `.agents/bin/archive.sh` | Bash |
| Windows | `.agents/bin/archive.ps1` | Windows PowerShell 5.1 或 PowerShell 7 |

两套脚本行为一致。修改归档规则时，应同时更新 `.sh` 和 `.ps1` 文件。

## 数据边界

[.gitignore](.gitignore) 默认忽略以下内容：

- `tasks/` 中的任务和产物；
- `archive/` 中的历史任务；
- `inbox/` 中的原始输入；
- `.agents/archive.log` 运行日志；
- 本机私有配置、环境变量文件和常见临时文件。

三个数据目录只提交各自的 `README.md`。如果你希望用 Git 管理个人任务，可以按自己的仓库权限和数据敏感程度调整忽略规则。

## 自定义

- 修改 `AGENTS.md`，调整任务路由、目录规则和 Agent 约束。
- 修改 `.agents/playbooks/`，改变某类任务的执行方式。
- 修改 `.agents/style.md`，定义团队实际使用的文档风格。
- 修改 `.agents/templates/TASK.md`，增减任务元数据或收尾字段。

公共规则应放在仓库中。本机路径、账号信息、密钥和个人任务应留在已忽略的文件或目录中。

## 反馈与贡献

可以通过 GitHub Issue 报告问题或提出建议，也可以提交 Pull Request。涉及归档逻辑的改动需要同时验证 Bash 和 PowerShell 版本，提交内容不得包含个人任务或敏感信息。

## 许可证

本项目采用 [MIT License](LICENSE)。你可以使用、修改和分发本项目，但需要保留原始版权与许可证声明。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=zK0G0w/dossier&type=Date)](https://star-history.com/#zK0G0w/dossier&Date)
