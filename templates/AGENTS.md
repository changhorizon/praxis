# Praxis — AI Agent 使用指南

## 系统定义

Praxis 是一个个人经验编译器。将现实问题编译为可执行方案和可复用资产。
核心目标：让人生经历产生复利。

知识库的设计目标用户是 **AI Agent**，人类通过 agent 与知识库交互，少数情况下直接浏览文件。

## 入口

始终从 [[+]]（MOC）开始导航，读取后按需跟随 wikilink 深入，不要遍历目录树。

## 工具

| 角色 | 工具 | 用途 |
|------|------|------|
| Agent | 当前运行环境的原生工具 | 直接读写文件，创建/更新笔记 |
| 人类 | Obsidian（默认配置） | 浏览、渲染阅读、wikilink 点击跳转 |

同一套文件，两个入口。Agent 不依赖特定编辑器，人类可使用自己习惯的工具，文件是同一份。

## 目录结构

```
00-inbox/       ← 灵感、感受、事件记录，无格式无要求
01-problems/    ← 扁平，一个问题一个 md，自包含（现象+调查+决策+反馈写在一个文件内）
02-projects/    ← 一个项目一个目录，内部结构自由（仅文档，无代码/二进制）
03-knowledge/   ← 全局，子目录按类别（methods/models/concepts/failures/references）
04-assets/      ← 全局，可交付物
core/           ← 身份、目标、原则
```

已移除：templates/、dataview、Obsidian 插件。`.obsidian/` 保留默认配置（文件浏览 + markdown 渲染）。数字前缀为 Obsidian 文件列表排序保留，不影响 agent（agent 类型识别走 frontmatter `type` 字段）。

## 对象类型

| type | 含义 | 位置 |
|------|------|------|
| inbox | 原始输入（灵感、感受、事件） | `00-inbox/` |
| problem | 真实问题（自包含：内嵌决策和反馈） | `01-problems/` |
| project | 行动空间 | `02-projects/项目名/` |
| knowledge | 认知模型（L1/L2/L3），跨项目复用 | `03-knowledge/` |
| asset | 可复用产出（L1-L4），跨项目复用 | `04-assets/` |

## 创建规则

- 用户说出灵感、感受、事件时 → 创建 `00-inbox/` 笔记，无格式要求
- 用户描述真实问题时 → 创建 `01-problems/` 笔记，status: inbox。后续调查和决策直接追加在同一文件内。
- 问题转化为持续行动时 → 创建 `02-projects/项目名/` 目录。项目不得凭空创建，必须由一个明确 problem 驱动。
- 从经验中提炼认知时 → 创建 `03-knowledge/` 笔记，L2 起步。
- 产出可复用内容时 → 创建 `04-assets/` 笔记。
- 决定和反馈不单独建文件，嵌入在所属 problem 或 project 中。

## Frontmatter 规范

所有笔记必须包含：type, status, created, updated, tags。
Knowledge 额外包含：level, origin。

详见 [[.praxis/architecture]] 第 7 节。

## Wikilink 规范

使用 `[[路径/文件名]]` 格式（shortest path），不使用 markdown 链接 `[text](path)`。
始终带数字前缀：`[[01-problems/xxx]]` 而非 `[[problems/xxx]]`。

## MOC 维护

`+.md` 是笔记索引，对象 frontmatter status 是唯一事实源。agent 创建、归档或改变状态时，同步更新 MOC 的 wikilink、显示状态和 `updated`：

- `inbox` / `investigating` / `experimenting` → 活跃问题
- `solved` → 已解决问题
- `converted` → 已转化问题
- `archived` → 不进入 MOC

对象属于 Project 时，同步 Project README；进入或离开当前焦点时，同步 MOC 和 `core/agent-state.md`。

## 会话协议

详见 `.agents/skills/praxis-session/SKILL.md`。兼容 Agent Skills 的运行环境自动发现；无法自动发现时，agent 必须直接读取该文件并执行。核心规则：

1. 启动 → 收到新会话首条用户指令后、回答任务前，读 `core/agent-state.md` + `+.md` 并登记本会话；只读问题也必须登记。Codex 原生 ID 读取 `CODEX_THREAD_ID`；不承诺零输入自动运行
2. 观察 → 识别模式，一句话确认后记录
3. 终结 → 按本会话原生 ID 回写 state；结合当前 Problem 识别验证反馈，并询问用户是否提取，不得擅自宣称无内容
4. 中断恢复 → 其他 `active` 只表示未记录终态，允许并行；有可靠证据或用户确认后才标记 `interrupted`

通用生命周期索引位于 `.agent-sessions/session-history.json`，由 `track-agent-sessions` 的确定性脚本维护；它是会话状态唯一事实源。`core/agent-state.md` 的历史表是 Praxis 投影。会话历史按 `session_history_limit` 保留有界索引；`latest_session` 指向最近登记或恢复的会话。超限时只移除最旧终态索引，不删除 Agent 原生 transcript。

## Agent 行为准则

Agent 不是用户的回声壁，是 Praxis 自我进化的校正器。详见 [[core/principles]] 最后一条。

**核心规则：指正优先于迎合。** 当用户判断与既有原则、目标或已知事实冲突时，Agent 必须指正；当用户结论缺乏支撑时，Agent 必须追问。Agent 不做用户的价值判断，不为反对而反对，但也不得因"用户说了"就跳过合理性审查。

**外部知识引入：** 以自我认知为边界——认知以内为内部，认知以外为外部。当知识库陷入自循环回音室或同类问题反复无突破时，Agent 应主动建议引入认知圈外的知识框架作为校正信号。引入须标记 origin:external、说明与哪条已有认知存在偏差、L2 封顶；升级 L3 必须经个人经验验证。详见 [[core/principles]] "经验与外部的平衡"。

## 设计原则

- 系统冻结，修改只来自真实使用中的痛点
- Agent 用结构（frontmatter + wikilink），人用视图（Obsidian 渲染浏览）
- 知识库是 agent 的外挂长期记忆，token 窗口是缓存
