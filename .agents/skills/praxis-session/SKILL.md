---
name: praxis-session
description: Manage Praxis session startup, observation, persistence, and recovery. Use when an agent starts, continues, summarizes, records, completes, or ends work in a Praxis knowledge base, and automatically when AGENTS.md identifies the repository as Praxis.
---

# Praxis Session Bridge

## 职责

管理通用 Agent 会话索引与 Praxis 知识库之间的适配：收到新会话首条用户指令时恢复上下文，会话中观察可沉淀内容，结束时保存状态。

会话身份、生命周期、并行语义和有界淘汰必须调用相邻的
`../track-agent-sessions/scripts/session_history.py`。项目内
`.agent-sessions/session-history.json` 是会话生命周期唯一事实源；
`core/agent-state.md` 的会话历史表只是供 Praxis 与人类阅读的同步投影。
MOC、Problem、Project、焦点和反馈提取仍由本 Skill 负责。

## 启动协议

每次新会话收到首条用户指令时，先完成以下登记，再处理用户任务。即使首条任务只是查询或审阅，也不得跳过写入；仓库所有者已通过 AGENTS.md 预先授权这项低风险状态维护，不需要用户再次提出“更新状态”。

1. 完整读取 `../track-agent-sessions/SKILL.md`、`core/agent-state.md` 和 `+.md`。
2. 取得当前运行环境和原生会话 ID：
   - Codex：读取环境变量 `CODEX_THREAD_ID`；非空时直接作为 `native_session_id`。
   - 其他 Agent：优先使用运行环境提供的原生会话标识。
   - 确实无法取得时写 `pending`，不得把状态文件中上一条 ID 当作本会话 ID。
3. 先调用通用脚本登记或恢复本会话：

       python3 .agents/skills/track-agent-sessions/scripts/session_history.py --project-root <Praxis 根目录> start --runtime <runtime> --native-id <id> --focus "<当前任务>"

4. 根据脚本返回的 `session` 和 `evicted` 同步 `core/agent-state.md`：把当前记录移到表格第一行，保留脚本给出的 `session_id` 作为 `praxis_id`，更新状态与焦点，并移除被淘汰的投影行。将 frontmatter `latest_session` 和 `session_history_limit` 同步为 JSON 返回值。
5. 允许多行同时为 `active`。其他 `active` 只表示“尚无终态记录”，可能仍在并行运行，也可能已意外关闭；只报告为未关闭会话，不得仅因新会话启动就改成 `interrupted`。
6. 不得在 Markdown 表中独立执行淘汰、生成 ID 或推断终态；这些动作必须来自通用脚本结果。
7. 如有未完成的焦点任务，简要告知用户上次在哪里中断。

如果通用索引写入失败，应明确报告失败；不得退回 Markdown 表继续写入，也不得回答一个看似有效但来自旧投影的“当前会话 ID”。若 JSON 与投影不一致，以 JSON 为准修复投影。

边界：Agent 在收到用户指令前不会自行执行 Skill，因此这里的“启动”不指进程启动后零输入自动运行。用户可以直接提出真实任务；无需专门发送“检查会话状态”，启动检查应作为首轮处理的一部分自动完成。

### 会话标识

会话历史使用双标识：

- `praxis_id`：由 Praxis 生成，用于跨 Agent 稳定引用。
- `native_session_id`：由当前运行环境生成，用于定位原始会话；与 `runtime` 组合使用。

`praxis_id` 直接使用通用索引返回的 `session_id`。ID 生成和同秒去重由通用脚本处理。

历史表固定字段为：

```text
praxis_id | runtime | native_session_id | started | focus | status
```

表格按 JSON 索引顺序投影。Agent 在会话中取得此前为 `pending` 的原生 ID 后，应先调用通用脚本 `bind-id`，再同步当前投影行。`unknown` 仅用于迁移后确实无法恢复的旧记录，不用于新会话。

`active` 的含义是“尚未记录 `ended` 或 `interrupted`”，不是操作系统级存活证明。并行会话分别维护自己的行；`latest_session` 只是最近一次登记指针。

## 观察协议

Agent 主动承担分类、格式、frontmatter、wikilink 和 MOC 维护。只有涉及用户的价值判断、事实认定、内容提炼或不可逆选择时，才请求一句话确认。

| 触发模式 | 确认语 | 动作 |
|----------|--------|------|
| 用户重复提到同一困惑 | “合并追踪？” | 新增调查到已有 Problem |
| 用户表达新的认知 | “提炼到 Knowledge？” | 创建 Knowledge 笔记 |
| 用户做出重要选择 | “记入 Problem 决策？” | 追加到所属 Problem 或 Project |
| 用户描述具体事件 | 无需确认 | 自动创建 Inbox 笔记 |
| 用户报告尝试结果 | “记录反馈？” | 追加反馈到对应文件 |

红线：Knowledge 和 Asset 的创建、实质修改、删除或归档必须确认。删除内容和其他不可逆操作必须单独确认。低风险结构维护由 Agent 自动执行。

## 终结协议

用户明确表示会话完成时：

1. 回写 `core/agent-state.md`：
   - 重新取得本会话的 `runtime + native_session_id`，先调用通用脚本 `end`，再把返回终态同步到自己的投影行；不得依赖可能被并行会话覆盖的 `latest_session`
   - 保存当前焦点项目
   - 保存未决事项和待确认观察
2. 对照 `core/agent-state.md` 的当前焦点、待确认事项和相关 Problem 的待验证项，识别本会话是否产生了验证结果、状态变化、决策或其他反馈。会话本身完成了某项协议测试时，该结果就是反馈，不能因对话内容简短而忽略。
3. 明确告诉用户识别到的候选内容，并询问是否提取。即使 Agent 初步判断没有候选内容，也必须询问，不得替用户回答或直接宣称“没有内容需要提取”。
4. 用户同意后执行提取并更新 MOC；用户拒绝则只保存状态。

## 中断恢复协议

Agent 无法在进程被直接关闭后执行清理，因此使用“启动时写 `active`、正常结束时写 `ended`”的状态约定：

- 新会话调用通用脚本 `list --status active`；发现其他 `active` 时，告知用户存在未关闭会话及其焦点，但不得自动断言已经中断。
- 只有运行环境提供可靠终止证据，或用户确认该会话已意外关闭时，才调用通用脚本 `interrupt` 并同步投影。
- 使用当前运行环境原生的会话恢复能力继续；不要依赖某个 Agent 的专属命令。
- 如果运行环境不能恢复对话，从 `core/agent-state.md` 和 MOC 重建最小上下文。

## MOC 维护

以对象自身 frontmatter status 为唯一事实源。创建、归档或更新笔记时，同步更新 `+.md` 中对应的 wikilink、显示状态和 `updated`。

Problem 的 MOC 投影规则：

- `inbox`、`investigating`、`experimenting` → 活跃问题
- `solved` → 已解决问题
- `converted` → 已转化问题
- `archived` → 从 MOC 移除

状态变化时，同时同步所属 Project README 的问题分区。进入或离开实际焦点时，同时同步 MOC 和 `core/agent-state.md` 的当前焦点。不得让 MOC 或 Project 中的状态覆盖对象 frontmatter。
