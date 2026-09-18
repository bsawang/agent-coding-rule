# 质检清单

**谁用**：progress 收尾时逐条过（F2+F3）；cycle 收点时过本子需求的 F1；spec 写完过 spec 阶段；plan 下发前过 plan 阶段。

**每个阶段的 checklist 是该阶段的**硬门槛**——没全勾上不许进入下一步。**

---

## 1. brainstorm 写完 prd 后（prd 审点）

| # | 检查 | 硬约束来源 | 怎么验 |
|---|---|---|---|
| P1 | 所有 Mx = ⬜ | SSOT.md 禁止 #1 | grep 所有 `### M\d+`，每个后面是 ⬜ |
| P2 | prd 不写技术细节 | brainstorm SKILL.md prd 边界表 | grep DB/sql/frontmatter/cli/接口/import/依赖 等关键词，出现就是越界 |
| P3 | 模块粒度 = 业务价值单元 | numbering.md §1 谁负责编 | 一个 Mx 对应"用户能单独感知的一个功能域" |
| P4 | 非目标不空 | brainstorm SKILL.md | prd §3 非目标至少 3 条 |
| P5 | 双向关联指向 spec.md | numbering.md §4 引用格式 | prd 开头有 `> 技术设计见 [spec.md](.spec.md)` |

---

## 2. spec 写完后（spec 审点）

| # | 检查 | 硬约束来源 | 怎么验 |
|---|---|---|---|
| S1 | prd Mx 集合 = spec Mx 集合 | spec SKILL.md 三步对账 ① | `grep "### M\d+" docs/prd.md` vs `grep "### M\d+" docs/spec.md`，集合一致 |
| S2 | spec Mx.y 都归属 prd 定义的 Mx | spec SKILL.md 三步对账 ② | 取每个 `#### Mx.y` 的 Mx 前缀，查 prd 有没有这个 Mx |
| S3 | 每个 Mx.y 有验收条件 | spec-template 合格线 ③ | 验收栏不许空 |
| S4 | 每个 Mx.y 有错误与边界 | coding.md §2 | 详细设计里错误与边界字段不许空 |
| S5 | 完整档 = 所有 Mx.y 六个字段全写 | spec SKILL.md 详细设计档位门槛 | 数据流 / 接口 / 数据结构 / 算法 / 错误边界 / 测试要点 全有 |
| S6 | 待定项不阻塞验收 | spec SKILL.md 硬规矩 | 验收条件不许引用未定待定项的具体值 |
| S7 | 有 mermaid 需求树 | spec-template 合格线 | ```` ```mermaid flowchart ```` 存在 |
| S8 | 有模块边界约定 | coding.md §1 | spec §3.2 显式写了什么不许跨 |
| S9 | 技术底座有否决方案记录 | spec SKILL.md | §3.1 否决方案不空 |
| S10 | 双向关联指向 prd.md | numbering.md §4 | spec 开头有 `> 业务需求见 [prd.md](.prd.md)` |

---

## 3. plan 下发前（档位 + 事实预检查）

| # | 检查 | 硬约束来源 | 怎么验 |
|---|---|---|---|
| PL1 | 自检两问答完了 | plan SKILL.md 档位判定 | ① 要不要改 Mx.y 集合/验收？② 要不要改模块边界？ |
| PL2 | 档位决定正确 | plan SKILL.md 档位判定表 | 快道 = Mx.y+验收都不变；标准档 = 集合或验收变/边界不变；完整档 = 架构变 |
| PL3 | 依赖序拓扑无环 | progress SKILL.md 硬规矩 | 画依赖图，不能有 A→B→A |
| PL4 | 本批次 Mx.y ⊆ spec 全集 | progress SKILL.md 硬规矩 | 没有 spec 没定义的 Mx.y |

---

## 4. progress 接收 plan 下发声明（计划侧对账）

**plan 已经过了档位判定 + 事实预检查，spec 已经过了三步 MX 集合对账。progress 只查 spec 不覆盖的项。**

| # | 检查 | 硬约束来源 | 怎么验 |
|---|---|---|---|
| PR1 | 依赖图拓扑序无环 | progress SKILL.md 硬规矩 | 画依赖图，不能有 A→B→A |
| PR2 | 每个本批次内的待定项有主有期 | progress SKILL.md 硬规矩 | spec §6 待定项"何时必须定"不空 |
| PR3 | PROGRESS.md 结构正确 | progress SKILL.md 结构硬约束 | 全览前置（索引+唯一真相源）+ 批次块线性追加 + 6 要素 + 子需求表只有状态+证据两列 |

**全勾上才能交给 cycle。有一个不勾 → 回去改 plan 或 spec。**

---

## 5. cycle 每个 Mx.y 收点（F1 事实对账）

| # | 检查 | 硬约束来源 | 怎么验 |
|---|---|---|---|
| C1 | TDD RED 真看到红 | cycle SKILL.md + coding.md | 证据列有 FAILED 输出片段 |
| C2 | TDD GREEN 全过 | cycle SKILL.md | 证据列有 passed 输出片段 |
| C3 | 证据列 = 命令 + 输出片段 + 轮次 | progress SKILL.md 关键约束 | `pytest xxx -v → 4 passed in 0.06s（本轮 2026-09-18）` |
| C4 | 验收条件逐条对齐 | cycle SKILL.md | spec 验收栏的每一条都被测试覆盖 |
| C5 | 没有跨模块边界 import | coding.md §1 | grep import 看是否违反 spec §3.2 的边界约定 |
| C6 | 没有引入未声明依赖 | coding.md §4 | imports 都在 spec §3.1 里有 |
| C7 | 错误场景都覆盖 | coding.md §2 | spec 详细设计列出的每个错误场景都有测试 |

**全勾上才能写 ✅。有一个不勾 → 不许写 ✅，回去补。**

---

## 6. progress 收尾（F2+F3 三方 diff）

| # | 检查 | 硬约束来源 | 怎么验 |
|---|---|---|---|
| F2-1 | spec 验收 ↔ progress 证据 对得上 | progress SKILL.md F2 | PROGRESS 里每个 ✅ 的测试，确实覆盖了 spec 验收栏的对应条目 |
| F2-2 | progress 证据 ↔ 代码测试 对得上 | progress SKILL.md F2 | 本轮跑的测试命令，确实在代码里存在且输出和 PROGRESS 记录一致 |
| F3-1 | 代码结构 ↔ spec §3.2 目录树 对得上 | progress SKILL.md F3 | src/ 目录结构和 spec 定义的一致 |
| F3-2 | 无大漂移 | progress SKILL.md F3 | 模块边界没跨 / 依赖没偷偷加 / 接口签名和 spec 一致 |
| F3-3 | 小漂移已记在需求回写栏 | progress SKILL.md F3 | 有小差异 → 记了，没 → 说明没问题 |

---

## 7. 全项目完成归档

| # | 检查 | 硬约束来源 | 怎么验 |
|---|---|---|---|
| A1 | PROGRESS.md 所有 Mx.y = ✅ | SSOT.md 实施层真相源 | 全览表里没有 ⬜ ⏳ |
| A2 | prd/spec 状态后缀和 PROGRESS 一致 | SSOT.md 镜像同步 | prd/spec 的 🟢🟡 对照 PROGRESS 里的状态 |
| A3 | 需求回写栏已清空 | progress SKILL.md 硬规矩 | 收尾时先落回 prd/spec 再清空 |
| A4 | 待定项全关闭 | SSOT.md | spec §6 待定项全有结论（不阻塞了） |
| A5 | 代码无循环依赖 | coding.md §1 | grep import 图无环 |
| A6 | 所有测试全绿 | coding.md §3 | pytest 全项目跑一遍 |

---

## 违反后果

**一个阶段的 checklist 有未勾项 → 不许进入下一阶段。** 具体来说：

| 未勾项阶段 | 后果 |
|---|---|
| prd 审点 | 不许写 spec |
| spec 审点 | 不许走 plan |
| plan 下发前 | 不许调 progress |
| progress 初始态 | 不许调 cycle |
| cycle F1 | 不许写 ✅ |
| progress F2+F3 | 不许标归档 |
| 全项目归档 | 项目不算完成 |
