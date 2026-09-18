---
name: acr-progress
description: "实施层单一真相源。plan 已下发 / cycle 执行完要对账 / 要维护 PROGRESS.md 状态时必须调我。接收 plan 下发声明做计划侧对账并创建 PROGRESS.md、cycle 执行中收集证据/需求回写、cycle 收尾做 F2+F3 三方 diff + 同步回 prd/spec。不是我：档位判定走 acr-plan，技术规格走 acr-spec，执行走 acr-cycle。"
---

# 实施层进度

**落点**：`docs/PROGRESS.md`，**全项目一份**。

**定位**：实施层**唯一真相源**。prd/spec 里的 🟢⬜ 是本文件状态的**镜像标记**，只有本 skill 能改 PROGRESS.md，也只有本 skill 能回写 prd/spec 的状态后缀。全局真相源体系（六层六源 + 禁止事项）见 `docs/SSOT.md`。

## 生命周期

```
plan 交出下发声明 → progress 接收 + 计划侧对账 → 过 → progress 写 PROGRESS.md → 交给 cycle

cycle 执行中：cycle 写证据 / 写需求回写 → 实时更新

cycle 全部收点 → progress 收尾（F2+F3 清单见 [reference/quality-checklist.md](reference/quality-checklist.md) §6）：
  ① F2 三方 diff（spec 验收 ↔ progress 证据 ↔ 代码测试）
  ② F3 代码↔设计（大漂移拦、小漂移记）
  ③ 同步回 prd/spec（先落回 → 再清空回写栏 → 最后标归档）
  完成
```

**plan 做档位判定 + 事实预检查，progress 做计划侧对账。不重复。**

## 结构（硬约束，不许偏离）

PROGRESS.md 必须**按批次分块**，每块 6 个要素。**模块级不单独成行**，只作为分块的上下文说明。⏳ 只在子需求行，不在模块级行。

```markdown
# {项目名} 开发进度

## 当前批次 N  {覆盖范围：prd §Mx1+Mx2 / spec §Mx1.1-Mx2.3}  ⏳ 进行中
  ① 批次号 + 覆盖范围（引用 prd/spec 编号）
  ② 依赖序（M1.1 → M1.2 → M2.1，画成一行或 mermaid flowchart）

  | 子需求 | 状态 | 证据 |
  |---|---|---|
  | M1.1 | ✅ | pytest 全绿输出（2026-09-17 本轮） |
  | M1.2 | ⏳ | — |
  | M2.1 | ⬜ | — |
  ③ 子需求表（只列 Mx.y，不单独出现模块级行；cycle 要么跑完 → ✅，要么塌方 → 写回写栏，没有中间状态）

  ④ 需求回写（cycle 执行中发现偏差时追加）
    - [prd] M1.2 "自动扫描 git 仓" → 实际无 git 仓 → prd 回写 §M1.2
    - [spec] M1.2 验收加 "projects.json 损坏时跳过并记 warning"

  ⑤ 待定（本批次内必须解决的阻塞）
    - 错误码命名（我 / 批次结束前）

## 历史批次（每个已完成批次的归档副本）
## 全览（可选：覆盖所有批次的一张表，供快速查阅）
```

### 关键约束

| 约束 | 说明 |
|---|---|
| **表只列 Mx.y 子需求** | 模块级 Mx 不单独成行。子需求表的上下文由「覆盖范围」那一行说明 |
| **子需求表按编号自然序** | 按 M1.1, M1.2, M1.3... 排，方便人眼定位。依赖序已在批次块 ② 字段单独列出 |
| **⏳ 只在子需求行** | 标记当前 cycle 正在执行的那个子需求。模块级/批次级没有游标 |
| **证据列 = 命令 + 输出片段** | 不许只写命令名（`pytest tests/test_db.py`），必须加关键输出片段（`4 passed in 0.03s`）。F1 对账的核心是「输出在本轮对话里」，光写命令名等于没有证据 |
| **每批次一块** | 一个批次覆盖的子需求数由 plan 定，但结构固定：批次号 + 覆盖范围 + 依赖序 + 子需求表 + 需求回写 + 待定 |
| **cycle 要么 ✅ 要么塌方** | cycle 一次性跑完一个 Mx.y（七步一口气）。中间断 = 塌方，写需求回写栏，不搞"内部步骤游标" |

## 硬规矩

- **plan 交出下发声明后必须过计划侧对账**才能交给 cycle（对账清单见 [reference/quality-checklist.md](reference/quality-checklist.md) §4）——只查 spec 三步不覆盖的项：
  - 依赖图拓扑序无环
  - 每个本批次内的待定项有主有期
  - PROGRESS.md 结构正确（按批次分块 + 6 要素 + 无模块级行）
  - spec 的 MX 集合 / 验收完整性已经由 spec 三步对账保证，progress 不重复查
- **cycle 写 ✅ 必须有证据**（F1 内置）：验收命令的原始输出必须在**本轮对话内**
- **F2/F3 是 progress 收尾时的硬门槛**，cycle 不自己做
- **需求回写栏是 cycle 执行中唯一能改 prd/spec 计划的地方**——cycle 不直接改 prd/spec，先写回写栏，progress 收尾统一同步
- **同步顺序不能反**：先落回 prd/spec → 再清空回写栏 → 最后标 progress 归档

## 边界

- 不做档位判定 / 事实预检查 / 影响评估（→ acr-plan）
- 不写 prd/spec（→ acr-brainstorm / acr-spec）
- 不执行代码（→ acr-cycle）
