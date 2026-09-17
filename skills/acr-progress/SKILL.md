---
name: acr-progress
description: 实施层单一真相源。plan 产出初始态后由本 skill 接收对账，cycle 执行中实时写状态/游标/证据/需求回写，cycle 收尾时由本 skill 做 F2+F3 对账 + 同步回 prd/spec + 归档。不属于我：档位判定走 acr-plan，技术规格走 acr-spec，执行走 acr-cycle。
---

# 实施层进度

**落点**：`PROGRESS.md`，项目根或 `docs/`，**全项目一份**。

**定位**：单一真相源。prd/spec 里的状态后缀是镜像标记，本文件里的才是真的。

## 生命周期

```
plan 产出初始态 → progress 接收 + 计划侧对账 → 过 → 交给 cycle

cycle 执行中：cycle 写游标 / 写证据 / 写需求回写 / 写状态 → 实时更新

cycle 全部收点 → progress 收尾：
  ① F2 三方 diff（spec 验收 ↔ progress 证据 ↔ 代码测试）
  ② F3 代码↔设计（大漂移拦、小漂移记）
  ③ 同步回 prd/spec（先落回 → 再清空回写栏 → 最后标归档）
  完成
```

**进度生成时的事实预检查已经归 plan**（plan 内部步骤 ②），progress 不重复做。

## 结构

```markdown
# {项目名} 开发进度

## 当前循环 N  {prd §Mx + spec §Mx.y}  ⏳ 进行中
  覆盖子需求：M1.1 M1.2 M2.1
  依赖序：M1.1 → M1.2 → M2.1

  | 子需求 | 状态 | 内部步骤游标 | 证据 |
  |---|---|---|---|
  | M1.1 | ✅ | 7 步全绿 | pytest 全绿输出（2026-09-17 本轮） |
  | M1.2 | ⏳ | 定标准✅ 定接口✅ 失败测试⏳ | — |
  | M2.1 | ⬜ | 全 ⬜ | — |

  需求回写（cycle 执行中发现偏差时追加）
    - [prd] M1.2 "自动扫描 git 仓" → 实际无 git 仓 → prd 回写 §M1.2
    - [spec] M1.2 验收加 "projects.json 损坏时跳过并记 warning"

  待定
    - 错误码命名（我 / 循环结束前）

## 历史循环 ...
```

## 硬规矩

- **plan 产出初始态后必须过计划侧对账**才能交给 cycle：
  - prd Mx.y 集合 = spec Mx.y 集合
  - progress Mx.y 集合 ⊆ spec
  - 依赖图拓扑序无环
  - 每个 Mx.y 有验收标准
- **cycle 写 ✅ 必须有证据**（F1 内置）：验收命令的原始输出必须在**本轮对话内**
- **F2/F3 是 progress 收尾时的硬门槛**，cycle 不自己做
- **需求回写栏是 cycle 执行中唯一能改 prd/spec 计划的地方**——cycle 不直接改 prd/spec，先写回写栏，progress 收尾统一同步
- **同步顺序不能反**：先落回 prd/spec → 再清空回写栏 → 最后标 progress 归档

## 边界

- 不做档位判定 / 事实预检查 / 影响评估（→ acr-plan）
- 不写 prd/spec（→ acr-brainstorm / acr-spec）
- 不执行代码（→ acr-cycle）
