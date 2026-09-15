---
name: acr-init
description: 新项目初始化：固化开发规范、生成项目骨架。首次进入空仓、或用户要求'初始化项目规范'时调用。不属于我：存量项目文档重整走 acr-retrofit，需求/设计/进度各有对应 skill。
---

# 项目初始化

**输入**：一个空仓或刚创建的项目。
**输出**：项目级规则文件 + Agent 指引 + docs/ 文档骨架。

## 定位

acr 体系的入口。其他 acr-* skill 管的是**已经有项目**后的流程（写 spec / 写设计 / 开发循环 / 存量重整），本 skill 管的是**还没有规范**的时候——把流程骨架注入项目，让后续开发开箱即走 acr。

**只管规范骨架，不管代码脚手架**。项目的技术栈、依赖、目录结构由各技术栈自有工具（npm create / cargo init / 手动 git init）建，本 skill 不碰。

## 三份产物

### 1. 项目级规则文件

注入位置由当前 agent 决定（Trae → `.trae/rules/project_rules.md` / **CC → `.claude/CLAUDE.md`** / Cursor → `.cursorrules`）。
CC 这个路径**必须与全局 bootstrap 的检查路径一致**，否则下次进项目会判定「无规则文件」再跑一遍。内容分四段：

```markdown
# 项目开发规则 (acr-init 生成)

> 本文件只放**项目内动手前必须看到的拦截线摘要**。档位判定、硬规矩、skill 路由的**完整定义**
> 在全局 skill `acr-cycle`，冲突时以那边为准 —— 不在此重述完整内容，避免造第二真相源。

## 功能开发标准流程

每个功能/需求必须走完六阶段,不得跳步:
设计 → 评审(确认前不写代码) → 计划 → 开发(一次一个功能点) → 测试(证据门槛) → 收尾

## 档位判定

改动落在哪层文档决定档位 —— 可判、单调、只能往上升:
快道(F 编号集合与验收判据都不变) → 可就地改 spec 表述 + 记调整日志,免评审
标准档(F 集合或验收判据变/概要不变) → spec 修订 + 详细设计 + 完整循环
完整档(概要/架构变) → spec→概要→架构→详细 + 完整循环

自检两问:① F 编号集合或某条验收判据要改吗?② 模块划分要改吗?

## 硬规矩

- 设计未经用户确认,改实现代码一律拦下
- 没在本轮对话里跑过验证命令,不许声称通过/修好/完成
- 一次一个功能点,不攒到最后一起验证
- 实现偏离设计时只有两个出口:改文档 or 改代码,不许"先这样吧"
- 快道中发现上层文档要改,就地升级档位,不硬推

## Skill 触发提示

开发流程走 acr-*:
- 需求讨论 → acr-spec
- 概要/架构/详细设计 → acr-design-docs
- 新需求/功能点实现前 → acr-cycle
- 进度维护 → acr-progress
- 存量文档重整 → acr-retrofit
- 发散方案 → acr-brainstorm

## 项目特定 (acr-init 时填写)

### 技术栈          <!-- 后端/前端/存储 -->
### 架构约定        <!-- core 单点/薄壳/CSS 变量/契约位置 -->
### 常用命令        <!-- 测试/构建/服务启动 -->
### 文档地图        <!-- docs/ 各文件职责 + 进度权威源 -->
```

**注意**：档位判定、硬规矩、skill 路由的**完整定义**在 acr-cycle SKILL.md。本文件只放**项目内必须看到的拦截线摘要**，让 agent 在动手前就知道流程约束——不重述完整内容，避免造第二真相源。

### 2. Agent 指引（CC 下是根目录 `CLAUDE.md`，与产物 1 是两份文件）

```markdown
# <项目名> — Agent 指引

<一句话描述,帮助 agent 理解上下文>

## 常用命令
- 服务: <启动命令>
- 测试: <测试命令>
- 前端构建: <构建命令>

## 文档地图
- 文档约定(权威口径): docs/DOC-CONVENTIONS.md —— §0 文档归属 / §4 功能点编号 F1…Fn / §9 快道调整日志
- 接口契约: docs/api-contract.md
- 架构: docs/ARCHITECTURE.md
- 进度: docs/PROGRESS.md (唯一进度权威源; 由 acr-progress 在首个循环建立, 届时才存在)
- 开发约束: docs/README.md

根 README = 用户/部署侧说明; 开发约束一律放 docs/ (见 docs/DOC-CONVENTIONS.md)。

## 流程遵循

本仓遵循 acr (Agent Coding Rules) 流程方法论。档位判定、硬规矩见项目级规则文件。
```

### 3. docs/ 骨架

生成四个文件，**只写文档约定**（确保后续文档不跑偏），其余为空模板。**模板一律以归属 skill 为准，本表只是副本。**

| 文件 | 内容 | 归属 skill（真相源） |
|---|---|---|
| `docs/DOC-CONVENTIONS.md` | 文档归属 + 九节结构索引 | acr-spec（功能点在 **§4**、调整日志在 **§9** —— 以它的 `reference/spec-template.md` 为准） |
| `docs/api-contract.md` | 契约版本表 + 端点预留 | 项目特定 |
| `docs/ARCHITECTURE.md` | 技术底座 / 目录与模块边界 / 存储通信 / 部署 / 约定 / 选型记录 | acr-design-docs（六节结构以它的 `reference/architecture.md` 为准） |
| `docs/README.md` | 测试现状 / 踩坑 / 部署备忘 | 项目特定 |

**注意**：`ARCHITECTURE.md` 是**项目级 · 一份 · 增量修订**，归属 acr-design-docs。本 skill 只建空模板占位，
**不定义它的内容结构**，也**不另造第二份项目级架构文档**（曾有个 `docs/architecture.md`，已并掉）。
`<slug>.hld.md` / `<slug>.lld.md` 是**有需求域之后**的产物，本 skill 不建。

## 执行步骤

1. 读取项目名与技术栈（目录名 + package.json/pyproject.toml 推断）
2. 填入"项目特定"章节
3. 按当前 agent 的注入机制写入规则文件（CC → `.claude/CLAUDE.md`）
4. 写入指引文件（CC → 根 `CLAUDE.md`）与 docs/ 骨架
5. 提示用户补全"项目特定"占位（`<!-- -->` 标记的项）
6. **自检**：把「文档地图」与「docs/ 骨架表」里的每个文件名 / 章节号，逐个与归属 skill 对一遍
   （acr-spec 的九节、acr-progress 的落点、acr-design-docs 的三层）—— 这两处是副本，漂移了就造第二真相源

## 边界

- **不重述 acr-cycle 的完整内容**——档位判定、硬规矩在项目级规则里只放拦截线摘要，完整定义是 acr-cycle SKILL.md 的真相源
- **不做存量项目文档重整**——那是 acr-retrofit（逆向，原文档不动，产出 docs-rebuilt/ + GAPS.md）
- **不写需求/设计文档**——acr-spec / acr-design-docs 管，本 skill 只管空骨架
- **本 skill 的模板是副本，不是真相源**——模板里凡引用兄弟 skill 的产物名 / 路径 / 章节编号，**归属方是那个 skill**；
  改那些 skill 的落点时，必须回来同步本表（执行步骤 6 就是这个自检）。曾经因为少了这道自检，模板漂出四处错名
