---
name: acr-plan
description: "档位判定 + 事实预检查 + 下发。spec.md 已审过 / 用户说'做计划' / 存量项目要审计 / 有代码无文档要 rebuild 时必须调我。内置三档判定（快道/标准档/完整档）+ 审计模式 + rebuild 模式。不是我：写 spec 走 acr-spec，执行走 acr-cycle。"
---

# 规划与对账

## 定位

唯一能**独立调用**的 skill。其他 skill 都是流程里的一环，plan 既能嵌在流程里也能独立跑。

**三种模式**：
- **正常模式**：嵌在流程里（brainstorm → prd → spec → plan → progress → cycle）
- **审计模式**：直接调用，读 prd/spec/code 出 diff 报告 + 自动生成整改清单
- **rebuild 模式**：有代码无文档时扫描产出事实快照 → 回 brainstorm 反推 prd

---

## 正常模式

```
输入：prd.md + spec.md + 变更请求（新需求 / 增量 / 调档）
步骤：
  ① 档位判定 + 影响评估
  ② 事实预检查（spec ↔ 代码现状）
     → 过 → 继续
     → 不过 → 下发整改 → progress 整改 → 回到 ②
  ③ 决定下发范围 → 产出 PROGRESS.md 初始态
输出：PROGRESS.md 初始态 → progress 接收
```

### ① 档位判定

内置规则，单调（只能往上升），可判：

| 档位 | 判据 | 后续 |
|---|---|---|
| **快道** | Mx.y 集合不变 + 验收判据不变 | prd/spec 不动 → 直接进 cycle → spec 快道日志加一条。**免 progress** |
| **标准档** | Mx.y 集合或验收判据变 / 模块边界不变 | prd 可能加新 Mx / spec 加新 Mx.y + 详细设计 |
| **完整档** | 架构要变（技术底座 / 模块边界 / 存储/通信方式） | prd 改定位/非目标 / spec 改 §3 架构概览 + 全链详细设计 |

**升级规则**：快道中发现上层文档要改 → 就地升级档位，不硬推。

### ① 影响评估

档位判定后，列出**所有受影响的 Mx.y**：
- 要新增的（新需求里没有对应）
- 要修改验收标准的
- 要废弃的
- 已有的、不受影响的（但需要在 progress 里标记状态）

### ② 事实预检查

**plan 的核心动作**——spec 写完后、下发 progress 前，先扫一遍代码现状，确认 plan 自己的影响评估有没有漏东西。

```bash
# 1. spec 详细设计里提到的函数/类名
grep -oP '(def |class |function )\w+' docs/spec.md | sort -u

# 2. 代码里实际有的函数/类
rg -l 'def \w+|class \w+|function \w+' src/ | sort -u

# 3. diff
diff <(set 1) <(set 2)

# 4. 技术底座核对
grep -oP 'Python \d+\.\d+|Node \d+|PostgreSQL|SQLite|Redis' docs/spec.md
cat requirements.txt package.json pyproject.toml 等
```

**检查结果分类**：

| 发现 | 处置 |
|---|---|
| 大漂移（spec 写了但代码不存在 / 代码有 spec 完全没提的大模块） | 下发整改 → progress 整改（回填 spec） |
| 已有实现（spec 要写的东西代码里有了，只是参数不同） | plan 自动降档（从标准档 → 快道），spec 只需补验收标准 |
| 技术底座不一致 | 下发整改 → progress 整改（回填 spec §3 架构概览） |
| 无差异 | 过 |

**新项目代码为空时，此步天然过**。

### ③ 决定下发范围

产出 PROGRESS.md 初始态：

```markdown
# PROGRESS.md

## 当前循环 N  {prd §Mx + spec §Mx.y}  ⏳ 待执行
  覆盖子需求：M1.1 M1.2 M2.1
  依赖序：M1.1 → M1.2 → M2.1
  初始状态：全 ⬜

  | 子需求 | 状态 | 内部步骤游标 | 证据 |
  |---|---|---|---|
  | M1.1 | ⬜ | 全 ⬜ | — |
  | M1.2 | ⬜ | 全 ⬜ | — |
  | M2.1 | ⬜ | 全 ⬜ | — |

  需求回写（cycle 执行中发现偏差时追加，不是现在填）

  待定
    - ...

## 历史循环 ...
```

---

## 审计模式

**触发**：用户说「审一下 spec 和代码对齐吗」或「给现有项目做文档重整」。

```
输入：prd.md / spec.md（可能有、可能不完整） + 代码
步骤：
  ① 读 prd/spec（如果存在） + 扫代码
  ② 跑事实预检查（同正常模式步骤 ②）
  ③ 差异自动归类：文档类 / 实现类 / 降级类
  ④ 控制台打印 diff 报告
     → 无差异 → 完
     → 有差异 → 自动生成 PROGRESS.md 整改清单 → 交给 progress + cycle
输出：控制台报告 / PROGRESS.md 整改清单
```

**差异自动归类**：

| 类型 | 例子 | progress 生成什么 |
|---|---|---|
| 文档类 | spec 编号瞎写 / prd 模块缺状态后缀 / 验收标准空 | 整改任务：改 prd / 改 spec |
| 实现类 | 代码函数签名和 spec 详细设计对不上 / 缺少测试 | 整改任务：改代码 / 补测试 |
| 降级类 | spec 写了新功能但代码已有相似实现 | 整改任务：spec 回填验收标准 + 改 progress 状态 |

---

## rebuild 模式

**触发**：有代码无文档（全新仓或存量仓从没写过 prd/spec）。

```
输入：代码（prd/spec 不存在或不完整）
步骤：
  ① 扫描代码结构 → 产出事实快照
     - 模块列表（按目录/包结构 + 代码 import 关系自动归组）
     - 函数/类签名
     - 数据结构（grep class/dataclass/sqlalchemy model）
     - 已有测试（grep test_ / describe / it）
     - 依赖关系（import 图 / 调用图）
  ② 控制台打印事实快照
  ③ 回 brainstorm（rebuild 变体）基于快照反推 prd.md
  ④ prd 写完后回 spec 写详细设计（基于代码事实，不需要猜）
  ⑤ plan 二次审计 → 过 → 正常流程
输出：事实快照 → prd.md → spec.md → 正常流程
```

---

## 边界

- 不发散方案（→ acr-brainstorm）
- 不写 prd/spec（→ acr-brainstorm / acr-spec）
- 不维护执行中的状态（→ acr-progress）
- 不执行代码（→ acr-cycle）
