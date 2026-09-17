---
name: acr-init
description: "新项目初始化。空仓 / 刚创建的项目 / 用户说'初始化项目规范'时必须调我。固化 acr 开发规范、生成三份注入文件（项目规则 / Agent 指引 / 文档骨架）。不是我：存量项目审计走 acr-plan(审计模式)，需求发散走 acr-brainstorm。"
---

# 项目初始化

**输入**：一个空仓或刚创建的项目。
**输出**：项目级规则文件 + Agent 指引 + docs/ 文档骨架。

## 定位

acr 体系的入口。其他 acr-* skill 管的是**已经有项目**后的流程（发散 / 写 prd / 写 spec / 计划 / 开发循环），本 skill 管的是**还没有规范**的时候——把流程骨架注入项目，让后续开发开箱即走 acr。

**只管规范骨架，不管代码脚手架**。项目的技术栈、依赖、目录结构由各技术栈自有工具（npm create / cargo init / 手动 git init）建，本 skill 不碰。

## 三份产物

### 1. 项目级规则文件

注入位置由当前 agent 决定（Trae → `.trae/rules/project_rules.md` / **CC → `.claude/CLAUDE.md`** / Cursor → `.cursorrules`）。
内容分四段：

```markdown
# 项目开发规则 (acr-init 生成)

> 本文件只放**项目内动手前必须看到的拦截线摘要**。档位判定、对账点、skill 路由的**完整定义**
> 在全局 skill（acr-plan / acr-progress / acr-cycle），冲突时以那边为准 —— 不在此重述完整内容。

## 功能开发标准流程

每个功能/需求必须走完六阶段,不得跳步:
发散 → prd → spec → plan → progress → cycle
（快道除外：plan 判快道 → 直接改 → 写快道日志）

## 档位判定（acr-plan 内置）

改动落在哪层文档决定档位 —— 可判、单调、只能往上升:
快道(Mx.y 集合不变 + 验收判据不变) → 就地改代码 + spec 快道调整日志
标准档(Mx.y 集合或验收判据变 / 模块边界不变) → prd+spec 修订 + 完整流程
完整档(架构要变) → prd+spec 全链修订 + 完整流程

自检两问:① Mx.y 集合或某条验收判据要改吗?② 模块边界要改吗?

## 硬规矩

- plan 事实预检查不过,不许下发 progress
- 设计未经用户确认,改实现代码一律拦下
- 没在本轮对话里跑过验证命令,不许声称通过/修好/完成
- 一次一个子需求,不攒到最后一起验证
- 实现偏离设计时只有两个出口:改文档 or 改代码,不许"先这样吧"
- 快道中发现上层文档要改,就地升级档位,不硬推

## 对账点（agent 不许跳过）

| 位置 | 做什么 |
|---|---|
| plan 事实预检查 | spec 详细设计 ↔ 代码现状（已有实现 / 技术底座 / 大漂移） |
| cycle 收点 F1 | ✅ 必须有本轮新鲜证据（命令 + 原始输出在本轮对话里） |
| progress 收尾 F2+F3 | spec 验收 ↔ progress 证据 ↔ 代码测试 三方 diff；代码结构 ↔ spec 详细设计 |

## Skill 触发提示

开发流程走 acr-*:
- 发散 + prd → acr-brainstorm
- 技术规格 → acr-spec
- 档位判定 + 事实预检查 + 下发 → acr-plan
- 计划侧对账 + F2+F3 + 状态 + 游标 + 回写栏 → acr-progress
- 执行 + F1 收点 → acr-cycle

存量项目审计/整改 → acr-plan(审计模式)
有代码无文档重建 → acr-plan(rebuild 模式)

## 项目特定 (acr-init 时填写，从代码推断 + 问用户确认)

### 技术栈          Python 3.12 / FastAPI 0.115 / SQLite 3 / httpx 0.27
### 架构约定        app/main.py 入口（薄壳）；app/core.py 业务逻辑（单入口）；app/db.py 数据层
### 常用命令        开发: uvicorn app.main:app --reload --port 8000 ; 测试: pytest tests/ -v
### 文档地图        docs/prd.md（业务层）· docs/spec.md（技术层）· PROGRESS.md（进度，项目根）
```

**填写规则**：
- **技术栈**：精确到版本号（和 spec §3.1 写死版本的约束对齐）。多栈用 `/` 分隔，测试框架单独列出
- **架构约定**：一句话描述模块边界（如"core 单点 + cli 薄壳"），具体边界约定在 spec §3.2 详细写
- **常用命令**：开发启动 + 测试 + 构建（如果有），多命令用 `;` 分隔
- **文档地图**：acr 三份固定文档，加上项目可能有的其他文档（如 API.md 指技术栈自动产物）

**推断来源**：package.json / pyproject.toml / Cargo.toml / go.mod / requirements.txt 等 → 自动提取依赖和版本。命令从 Makefile / scripts/ / docker-compose.yml 推断。推断不出来 → 问用户。

**注意**：本文件只放**项目内必须看到的拦截线摘要**，完整定义以对应 skill 为真相源。

### 2. Agent 指引（CC 下是根目录 `CLAUDE.md`）

```markdown
# <项目名> — Agent 指引

<一句话描述,帮助 agent 理解上下文>

## 常用命令
- 服务: <启动命令>
- 测试: <测试命令>
- 前端构建: <构建命令>

## 文档地图
- 业务需求: docs/prd.md （acr-brainstorm 产出；模块 Mx · 功能描述 · 非目标 · 状态后缀）
- 技术规格: docs/spec.md （acr-spec 产出；Mx.y · 需求树 · 验收 · 详细设计 · 状态后缀）
- 开发进度: PROGRESS.md （acr-progress 维护；单一真相源，项目根）

**PROGRESS.md 在项目根**，docs/ 只有 prd.md 和 spec.md。
根 README = 用户/部署侧说明; 开发侧一律放 docs/。

## 流程遵循

本仓遵循 acr (Agent Coding Rules) 流程方法论。skill 清单见全局。
```

### 3. 文档骨架

只生成 acr 流程必需的三个文件，**只写标题 + 双向关联指向**，其余为空。**模板以归属 skill 为准**。

| 文件 | 落点 | 初始内容 | 归属 skill |
|---|---|---|---|
| `PROGRESS.md` | **项目根** | `# {项目名} 开发进度`（空标题，cycle 第一次收点后由 progress 填充） | acr-progress |
| `docs/prd.md` | docs/ | 标题 + `> 技术规格 → [spec.md](./spec.md)` | acr-brainstorm |
| `docs/spec.md` | docs/ | 标题 + `> 业务层 → [prd.md](./prd.md)` | acr-spec |

**就这三个**。不生成 api-contract.md / ARCHITECTURE.md / hld.md / lld.md / 踩坑备忘等——那些要么是技术栈自动产物，要么是运行时才有的内容，要么是 acr 流程外的东西。

**PROGRESS.md 要不要进版本库？** 进。它是单一真相源，和 prd/spec 一样随项目演进。

## 执行步骤

1. 读取项目名与技术栈（目录名 + package.json/pyproject.toml 推断）
2. 填入「项目特定」章节
3. 按当前 agent 的注入机制写入规则文件（CC → `.claude/CLAUDE.md`）
4. 写入指引文件 + docs/ 骨架
5. 提示用户补全「项目特定」占位（`<!-- -->` 标记的项）
6. **自检**：把规则文件里的 skill 路由 / 档位描述，与 flow.md + glossary.md 对一遍

## 边界

- **不重述 skill 完整内容**——项目级规则只放拦截线摘要，完整定义是各 skill SKILL.md 的真相源
- **不做存量项目审计 / 文档重整**——那是 acr-plan 的审计 / rebuild 模式
- **不写 prd/spec**——acr-brainstorm / acr-spec 管，本 skill 只管空骨架
- **本 skill 的模板是副本，不是真相源**——改兄弟 skill 的落点时，必须回来同步本表
