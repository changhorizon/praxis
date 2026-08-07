---
type: knowledge
status: active
level: 3
origin: experience
tags: [architecture, system]
created: 2026-07-29
updated: 2026-08-08
---

# Praxis v1.0.0
## 个人经验编译器

> **Framework initial release.** Extracted from personal instance v2.4.1. Architecture frozen; changes come only from real usage pain points.

> 输入现实问题，输出可执行方案和可复用资产。知识库设计目标用户为 AI agent。

---

# 1. 本质定义

Praxis 不是知识库。

Praxis 是一个**个人经验编译器**：

```
现实问题 → 人的判断 + AI 增强 → 可执行方案 + 可复用资产
```

**为什么需要 Praxis？**

不是为了记笔记。是为了**让人生经历产生复利**——
每次经验不只解决当下问题，还固化为未来可调用的能力。

它和笔记系统的根本区别：

| 笔记系统 | Praxis |
|----------|--------|
| 我知道什么 | 我遇到过什么问题、做了什么选择、结果如何 |
| 收集信息 | 编译经验 |
| 静态文档 | 运行中的认知系统 |
| AI 作为搜索工具 | AI 作为推理伙伴 |

---

# 2. 核心三角

Praxis 的最小认知单元不是单个概念，而是一个三角形：

```
         Problem
        /       \
   Decision —— Knowledge
        |
        |
      Asset
```

- **Problem**：真实世界发生了什么
- **Decision**：在那个具体上下文中我选择了什么、放弃了什么、为什么
- **Knowledge**：从这次经验中提炼出的认知模型

Decision 是三角的中枢——**知识记录"我知道什么"，决策记录"为什么在那个情况下这么做"**。后者才是个人经验不可替代的价值。

---

# 3. 五类核心对象

```
Problem     → 现实问题
Decision    → 关键选择（核心价值载体）
Knowledge   → 认知模型
Project     → 行动空间
Asset       → 价值产物

辅助对象：
Feedback    → 反馈事件（进化引擎）
MOC         → 导航
Template    → 生产规范
```

---

# 4. 系统闭环

```
              Reality
                 ↓
              Problem
                 ↓
             Decision
                 ↓
              Project ──→ Feedback ──→ New Problem
                 ↓                        ↓
            Knowledge               Better Decision
                 ↓
              Asset
                 ↓
          New Capability
```

闭环由三条回路驱动：

1. **执行回路**：Problem → Decision → Project → Asset
2. **反馈回路**：Project → Feedback → New Problem → Better Decision
3. **沉淀回路**：Decision + Feedback → Knowledge → New Capability

---

# 5. 目录结构

```
/praxis/
├── +                    ← MOC（唯一入口）
├── core/                ← 人格、原则、目标
├── 00-inbox/            ← 灵感、感受、事件（无格式要求）
├── 01-problems/         ← 真实问题（扁平，一个文件自包含）
├── 02-projects/         ← 行动空间（一个项目一个目录）
├── 03-knowledge/        ← 认知模型（全局，概念/方法/模型/失败库/参考）
└── 04-assets/           ← 可复用产出（全局）
```

v2.0 移除 `archive/`，v2.3 移除 `decisions/` 和 `feedback/` 顶级目录，v2.4 移除 templates/、dataview、Obsidian 插件。数字前缀为 Obsidian 文件列表排序保留。

---

# 6. 对象规范

## 6.1 Problem — 现实问题（自包含）

Problem 是最基本单元，一个文件包含完整链条：现象 → 调查 → 决策 → 反馈。

### 生命周期

```
inbox → investigating → experimenting → solved → converted
  ↓         ↓              ↓             ↓         ↓
(捕获)   (调查分析)    (行动验证)    (已解决)  (已抽象为资产)
  ↓
archived（不再追踪）
```

### 模板

```yaml
---
type: problem
status: inbox | investigating | experimenting | solved | converted | archived
created: {{date}}
updated: {{date}}
tags: []
---
```

```markdown
# {{title}}

## 环境
- 项目：[[02-projects/xxx]]

## 现象
（客观描述）

## 影响
（量化）

## 调查
- 假设A：→ 验证结果：
- 假设B：→ 验证结果：

## 决策
（可选：如果问题过程中做出了选择，直接写在这里）

| 方案 | 优势 | 劣势 |
|------|------|------|
| A | | |
| B | | |

选择：**方案 X**
理由：1. 2. 3.

## 尝试记录
| 方案 | 日期 | 结果 | 结论 |
|------|------|------|------|
| | | | |

## 反馈
（可选：行动后的实际结果 vs 预期）

## 关联
- 项目：[[02-projects/xxx]]
```

### 状态流转规则

```
inbox        → 刚捕获，还未分析
investigating → 正在理解根因
experimenting → 有假设，正在通过行动验证
solved       → 问题已解决（但尚未抽象）
converted    → 已从中提取了 knowledge/asset
archived     → 不再追踪（过时/无关/重复）
```

## 6.2 Decision — 嵌入在 Problem 或 Project 中

Decision 不作为独立文件。它嵌入在 problem 文件内（见 6.1 模板的「决策」节）或 project 目录内（需要多方案对比时）。

价值不在于记录"选了什么"，而在于保留**完整的决策上下文**——为什么在这个时刻选了这条路、放弃了什么。

## 6.3 Knowledge — 认知模型

### 分层标准（渐进式）

| 级别 | 内容要求 | 何时升级 |
|------|----------|----------|
| L1 | 标题 + 链接 + 标签 | 读完/想完即记 |
| L2 | L1 + 用自己的话写一段摘要 | 确认理解了 |
| L3 | L2 + 输入/输出/条件/流程/指标 | 经过 ≥2 次实际验证 |

### Origin 来源标识

```yaml
origin: experience | external | hybrid
```

- experience：来自自己的实践和反馈
- external：来自阅读/学习/他人经验，未亲身验证
- hybrid：外部输入 + 自己验证

**经验知识（experience）权重 > 外部知识（external）。** 外部知识不能直接升级到 L3，必须经过亲身验证。

### 目录

```
knowledge/
├── concepts/       ← 概念（Sharpe Ratio 是什么）
├── models/         ← 心智模型（二阶思维、反脆弱、复利）
├── methods/        ← 可执行方法（L3 规格）
├── references/     ← 外部资料笔记
└── failures/       ← 失败库（什么情况下会失效）
```

子目录仅用于浏览便利，分类职责由 frontmatter `tags` 和 `[[wikilink]]` 承担。

### L3 规格模板

```yaml
---
type: knowledge
status: active
level: 3
origin: experience
confidence: validated
created: {{date}}
tags: [method]
---
```

```markdown
# {{title}}

## 来源
- 决策：见所属 problem 或 project 文件（决策嵌入在问题或项目中）
- 反馈：见所属 problem 或 project 文件（反馈嵌入在问题或项目中）

## 适用场景
（什么时候用）

## 不适用场景
（什么时候不要用——和适用场景同等重要）

## 前置条件

## 执行流程

## 输出

## 验证指标

## 已知陷阱
- [[03-knowledge/failures/xxx]]

## 版本历史
- v1: {{date}} — 首次从 problem 决策抽象
- v2: {{date}} — 根据 problem 反馈修正
```

## 6.4 Project — 行动空间

项目是问题和产出的连接器。项目本身不产生知识——项目产生**决策和反馈**，由这两者产生知识。

```yaml
---
type: project
status: active | paused | completed
created: {{date}}
tags: [project]
---
```

```
projects/
├── example-project/
│   ├── README.md         ← 项目 MOC
│   ├── current-state.md  ← 当前状态（每周更新一段）
│   └── metrics.md        ← 核心指标
```

项目 README：

```markdown
# {{title}}

## 要解决的问题
- [[01-problems/xxx]]

## 当前状态
→ [[current-state]]

## 关键决策
- 见所属 [[01-problems/xxx]] 中的决策章节

## 反馈
- 见所属 [[01-problems/xxx]] 中的反馈章节

## 产出
- [[04-assets/xxx]]
```

## 6.5 Feedback — 嵌入在 Problem 或 Project 中

Feedback 不作为独立文件。它嵌入在 problem 文件的「反馈」节或 project 目录内。

**置信度规则：**
- low：单次事件、小样本、环境不稳定 → 只能产出 Problem
- medium：多次观察、一定样本 → 可产出 Decision
- high：大量验证、可复现 → 可修改 Knowledge

## 6.6 Asset — 价值产物

### 等级

| 等级 | 定义 | 示例 |
|------|------|------|
| L1 | 个人复用 | 个人用的一段配置/脚本 |
| L2 | 团队复用 | 团队新人用的 OAuth 接入文档 |
| L3 | 公开发布 | 博客文章、开源工具 |
| L4 | 商业产品 | 付费模板、SaaS、课程 |

资产成长路径：

```
L1 个人备忘 → L2 整理给团队 → L3 公开发布 → L4 商业化
```

### 模板

```yaml
---
type: asset
status: active
level: 1 | 2 | 3 | 4
created: {{date}}
tags: []
---
```

```markdown
# {{title}}

## 来源
- 问题：[[01-problems/xxx]]
- 决策：见所属 problem 中的决策章节

## 内容

## 使用场景

## 演化记录
- L1 → L2: {{date}} — 团队开始使用
- L2 → L3: {{date}} — 发布为博客文章
```

---

# 7. 统一 Frontmatter

```yaml
---
type: problem | decision | knowledge | project | asset | feedback | moc | state
status:   (根据 type 不同，可选值不同)
created:  YYYY-MM-DD
updated:  YYYY-MM-DD
level:    1 | 2 | 3 | 4   (knowledge/asset 专用)
tags:     []
---
```

---

# 8. MOC 入口

`+` 是 AI agent 的主要导航入口，人类偶尔浏览。纯 wikilink 列表，由 agent 维护：

```markdown
# Praxis

## 当前焦点
- [[02-projects/xxx]] `[active]`

## 活跃问题
- [[01-problems/xxx]] `[investigating]`

## 已解决问题
- [[01-problems/xxx]] `[solved]`

## 已转化问题
- [[01-problems/xxx]] `[converted]`

## 活跃项目
- [[02-projects/xxx]]

## 知识
- [[03-knowledge/models/xxx]]
- [[03-knowledge/methods/xxx]]

## 产出
- [[04-assets/xxx]]
```

对象 frontmatter status 是唯一事实源。Agent 创建、归档或改变状态时，同步更新此列表及 MOC 的 `updated`：

- `inbox` / `investigating` / `experimenting` → 活跃问题
- `solved` → 已解决问题
- `converted` → 已转化问题
- `archived` → 不进入 MOC

对象属于 Project 时，同步 Project README；进入或离开当前焦点时，同步 MOC 和 agent-state。

---

# 9. AI 工作流

```
用户提问
    ↓
AI 读 [[+]] → 了解当前焦点
    ↓
跟随 [[wikilink]] 深入（最多 3-5 篇笔记）
    ↓
按 type/status/level 过滤
    ↓
生成决策建议
    ↓
AI 按对象生命周期创建笔记：Problem 从 inbox 开始；Knowledge/Asset 经用户确认后创建为 active
```

> 未来方向：Praxis Query Layer — AI 不直接读 markdown，而是通过对象查询层理解 type/status/关系，实现真正的认知推理而非文本搜索。现阶段先不做分层，但设计上为此预留空间。

---

# 10. Git 工作流

```bash
# 每日提交
git add -A && git commit -m "$(date +%Y-%m-%d)"

# 决策提交
git commit -m "decision: Use SQLite for data pipeline"

# 反馈提交
git commit -m "feedback: API latency spike root cause confirmed"

# 资产发布
git commit -m "asset: deployment checklist L2->L3"
```

- **不做分支**，main 直推
- `.gitignore`：`.obsidian/workspace*`、`.obsidian/plugins/`、`.trash/`
- 远程：GitHub private repo
- 价值：时间轴 / 回滚 / 备份 / 可视化认知演化

---

# 11. 启动清单

```
/praxis/
├── +
├── core/
│   ├── identity.md
│   ├── goals.md
│   └── principles.md
├── 00-inbox/
├── 01-problems/
├── 02-projects/
├── 03-knowledge/
│   ├── concepts/
│   ├── models/
│   ├── methods/
│   ├── references/
│   └── failures/
└── 04-assets/
```

**从第一个真实问题开始。用 [[wikilink]] 生长，不预分类。**

---

# Version

> The architecture below evolved through a personal Praxis instance over multiple iterations.
> The framework release starts at v1.0.0, extracted from instance v2.4.1.
> Instance version history is preserved for context on how the methodology evolved.

## v1.0.0 — 2026-08-08 · Framework initial release

- Extracted from personal instance v2.4.1
- Instance is now init-able via `install.sh` and updatable via `update.sh`
- Templates extracted from personal files, stripped of instance-specific content

---

## Instance evolution (pre-framework)

**v2.4.1 — 2026-08-01** · Instance freeze

v2.4 → v2.4.1 变更：
- 恢复目录数字前缀（00-, 01-, 02-, 03-, 04-）：Obsidian 文件列表排序需要

v2.3 → v2.4 变更：
- 移除 templates/（frontmatter 规范在 AGENTS.md 中）
- 移除 Obsidian 社区插件和 dataview（仅保留默认配置）
- MOC 中的 dataview 查询块替换为纯 wikilink 列表
- 认知基础：知识库主要受众从人类变为 AI agent

v2.2 → v2.3 变更：
- 顶级目录添加数字前缀（00-inbox, 01-problems, ...）
- 新增 00-inbox/ — 灵感、感受、事件记录，无格式要求
- 移除 decisions/ 和 feedback/ 顶级目录（痛点：按类型分目录导致故事被切碎）
- Problem 改为自包含文件：现象、调查、决策、反馈写在一个文件内
- Project 一个项目一个目录，内部结构自由（仅文档，无代码/二进制）
- Decision 和 Feedback 不再作为独立对象类型，嵌入在 Problem 或 Project 中
- 新增原则：真实 > 正确（来源：搭建 Praxis 过程中的认知）

v2.1 → v2.2 变更：
- Decision 模板新增 `confidence` 字段 + Action Plan 区域
- Feedback 模板新增 `confidence` 字段（low/medium/high），含置信度规则
- Knowledge 模板新增 `origin` 字段（experience/external/hybrid），经验知识权重 > 外部知识
- L3 Knowledge 新增 `confidence` 字段（validated/proven）
- 原则中增加"反馈需要可信度"和"经验 > 外部"两条

v2.0 → v2.1 变更：
- 新增 Feedback 对象类型
- Problem 生命周期状态机
- Decision 提升为核心三角中枢
- Asset L1-L4 价值等级
- 移除 archive/ 目录
- 重新定义为"个人经验编译器"
