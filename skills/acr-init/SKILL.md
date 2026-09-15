---
name: acr-init
description: 新项目初始化：固化开发规范、生成项目骨架。首次进入空仓、或用户要求'初始化项目规范'时调用。不属于我：存量项目文档重整走 acr-retrofit，需求/设计/进度各有对应 skill。
---

# 项目初始化

**输入**：一个空仓或刚创建的项目。
**输出**：项目级规则文件 + Agent 指引 + docs/ 文档骨架。

## 定位

acr 体系的入口。其他 acr-* skill 管的是**已经有项目**后的流程（写 spec / 写设计 / 开发循环 / 存量重整），本 skill 管的是**还没有规范**的时候——把流程骨架注入项目，让后续开发开箱即走 acr。

## 与 create-project 的分工

`create-project` 是 mattpocock 时代的"应该有但未落地"的全局 skill 占位（从未有过实际文件）。acr-init 是 acr 体系内正式取代那个空位的 skill。两者职责根本不同：

| 维度 | acr-init | create-project（如存在） |
|---|---|---|
| **目的** | 给空仓注入开发规范 | 创建项目代码骨架（目录/依赖/脚手架） |
| **产物** | 规则文件 + CLAUDE.md + docs/ 骨架 | package.json / pyproject.toml / src/ 目录 |
| **管什么** | 流程约束 + 文档结构 | 代码技术栈 + 构建配置 |
| **谁管** | acr 体系唯一入口 | 各技术栈各有（npm create / cargo init / ...） |

**一句话**：acr-init 管的是"你在这个仓里应该怎么干活"，create-project 管的是"这个仓用什么技术搭起来"。两者互补不重叠——先 create-project（或手动 git init）建代码骨架，再 acr-init 注入规范。

## 三份产物

### 1. 项目级规则文件

注入位置由当前 agent 决定（Trae → `.trae/rules/project_rules.md` / CC → `CLAUDE.md` / Cursor → `.cursorrules`）。内容分四段：

```markdown
# 项目开发规则 (acr-init 生成)

## 功能开发标准流程

每个功能/需求必须走完六阶段,不得跳步:
设计 → 评审(确认前不写代码) → 计划 → 开发(一次一个功能点) → 测试(证据门槛) → 收尾

## 档位判定

改动落在哪层文档决定档位 —— 可判、单调、只能往上升:
快道(spec 不变) → 记调整日志,免评审
标准档(spec 变/概要不变) → spec 修订 + 详细设计 + 完整循环
完整档(概要/架构变) → spec→概要→架构→详细 + 完整循环

自检两问:① spec 里那句需求描述要改吗?② 模块划分要改吗?

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

### 2. CLAUDE.md / Agent 指引

```markdown
# <项目名> — Agent 指引

<一句话描述,帮助 agent 理解上下文>

## 常用命令
- 服务: <启动命令>
- 测试: <测试命令>
- 前端构建: <构建命令>

## 文档地图
- 规约(权威口径): docs/spec.md —— §0 文档约定 / §7 功能点编号 F1…Fn / §8 快道调整日志
- 接口契约: docs/api-contract.md
- 架构: docs/architecture.md
- 进度: docs/ROADMAP.md (唯一进度权威源)
- 开发约束: docs/README.md

根 README = 用户/部署侧说明; 开发约束一律放 docs/ (规约 §0)。

## 流程遵循

本仓遵循 acr (Agent Coding Rules) 流程方法论。档位判定、硬规矩见项目级规则文件。
```

### 3. docs/ 骨架

生成四个文件，**只写规约 §0 的文档约定**（确保后续文档不跑偏），其余为空模板。模板内容对齐 acr-spec / acr-design-docs 的模板，不另造格式。

| 文件 | 内容 | 对齐的 acr skill |
|---|---|---|
| `docs/spec.md` | §0 文档归属 + §7/§8 占位 | acr-spec（它的 spec-template.md 九节结构） |
| `docs/api-contract.md` | 契约版本表 + 端点预留 | 项目特定 |
| `docs/architecture.md` | 技术栈 / 模块划分 / 核心约定 | acr-design-docs（它的 architecture.md 模板） |
| `docs/README.md` | 测试现状 / 踩坑 / 部署备忘 | 项目特定 |

**注意**：acr-design-docs 建议的产物是 `<slug>.hld.md` / `ARCHITECTURE.md` / `<slug>.lld.md` 三层设计——那是**有需求域之后**的产物。本 skill 生成的 `docs/architecture.md` 是**项目级架构总览**，在任何需求域之前，与 acr-design-docs 的三层设计不冲突。

## 执行步骤

1. 读取项目名与技术栈（目录名 + package.json/pyproject.toml 推断）
2. 填入"项目特定"章节
3. 按当前 agent 的注入机制写入规则文件
4. 写入 CLAUDE.md 与 docs/ 骨架
5. 提示用户补全"项目特定"占位（`<!-- -->` 标记的项）

## 边界

- **不重述 acr-cycle 的完整内容**——档位判定、硬规矩在项目级规则里只放拦截线摘要，完整定义是 acr-cycle SKILL.md 的真相源
- **不做存量项目文档重整**——那是 acr-retrofit（逆向，原文档不动，产出 docs-rebuilt/ + GAPS.md）
- **不写需求/设计文档**——acr-spec / acr-design-docs 管，本 skill 只管空骨架
