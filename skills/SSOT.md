# acr 真相源体系

**定义**：每个事实只在一个地方有权写入，其他地方只能读或由唯一写方**主动回写镜像**。写方之外的任何修改都是违规。

## 五层五源

| 层 | 真相源 | 写方 | 其他方角色 |
|---|---|---|---|
| **规范层** | `skills/acr-*/SKILL.md` | 维护者改代码推仓库 | 所有项目**只读**。项目级规则文件只是拦截线摘要，不重复 skill 完整定义 |
| **编码规范层** | `skills/acr-spec/reference/numbering.md` | 维护者 | 所有项目 + skill **只读**。编号、章节、状态后缀、引用格式、代码层规范全在这 |
| **设计层** | `docs/prd.md` + `docs/spec.md` | prd 由 brainstorm 写，spec 由 spec skill 写 | 各自**只读对方**。brainstorm 不碰 spec，spec 不碰 prd 的模块边界 |
| **实施层** | `docs/PROGRESS.md` | **只有 progress skill** | cycle 写证据 → progress 收点；prd/spec 的 🟢⏳ 是 progress **主动回写的镜像** |
| **项目代码层** | spec §3.2 架构概览 | spec skill 写 | 项目级规则文件不重复代码规范，全看 spec |

## 禁止的事

| 禁止 | 原因 | 正确做法 |
|---|---|---|
| prd 自己改 🟢⬜ 状态后缀 | PROGRESS.md 才是状态的真相源 | progress 在 cycle 收尾时统一回写 prd/spec 的镜像 |
| spec 加 prd 没定义的 Mx 模块 | MX 集合对账硬检查拦截 | 加新模块必须先走 brainstorm 修订 prd |
| cycle 写 PROGRESS.md 的状态字段 | cycle 只写证据，收点是 progress 的活 | cycle 把证据塞在子需求行 → progress 确认后改状态 |
| 项目级规则文件抄 skill 完整内容 | 造第二真相源 | 规则文件只放拦截线摘要，详细定义回 skill 找 |
| 在非 numbering.md 里写编号/章节/emoji/引用规则 | 造编码规范的第二真相源 | 所有编码相关问题 → numbering.md |
| init 填项目技术栈/架构约定/常用命令 | 这些是代码层规范，真相源在 spec §3 | spec 写 §3 时从 pyproject.toml / Makefile 推断 |
| prd 写技术细节（DB schema / CLI flags / 接口签名） | prd 是业务层，技术细节是 spec 的事 | prd 只写功能描述 + 非目标 + 模块切分 |

## 镜像同步机制

progress 在 cycle 收尾做 F2+F3 对账后，**主动**把 PROGRESS.md 的状态回写到 prd/spec 的标题上：

```
prd 原来：### M1 短链生成 ⬜
progress 回写后：### M1 短链生成 🟢
```

这一步是 progress 的硬约束——不回写就是没收完点。prd/spec 在 progress 回写之前，状态**永远是 ⬜**。
