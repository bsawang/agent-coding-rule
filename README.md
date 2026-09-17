# agent-coding-rule

一套给 AI coding agent 用的**开发流程与文档规范化**技能集 —— 全局生效、单一真相源。

装上之后，agent 的手艺不再靠临场发挥：先头脑风暴再落文档，写实现代码前要你确认方案，说「做完了」之前必须跑验证，收尾先同步文档再分主题提交。

> 当前状态：6 个 skill 设计定稿。设计内容已合入 acr-spec（不再有独立 acr-design-docs）。存量项目审计 / rebuild 走 acr-plan（审计 / rebuild 模式），不再有独立 acr-retrofit。
>
> **6 个 skill**：acr-init / acr-brainstorm / acr-spec / acr-plan / acr-progress / acr-cycle

## 能力

| 能力 | 你会得到 |
|---|---|
| **新项目初始化** | 空仓 → 项目级规则文件 + 指引 + docs/ 骨架（prd.md 占位 + spec.md 占位），开箱即走 acr 流程 |
| 发散 + prd 收敛 | 头脑风暴发散方案 → 砍选项带理由 → 收敛成 prd.md（业务层，设计层唯一产出） |
| 标准化技术规格 | spec.md 含模块 Mx + 子需求 Mx.y + 需求树 + 验收标准 + 详细设计 + 状态后缀；三层设计按档位决定写多少 |
| **plan（档位 + 对账）** | 档位判定内置（快道/标准档/完整档）；事实预检查（spec↔代码）；正常模式嵌流程里，审计/rebuild 模式独立调用 |
| **progress（单一真相源）** | 计划侧对账 + 事实侧对账 + 状态 + 游标 + 需求回写栏 + 同步回 prd/spec + 归档；prd/spec 里的状态是镜像 |
| **cycle（无状态执行）** | 从 PROGRESS.md 读游标续做；收点触发 F1（✅ 必须有本轮新鲜证据）；F2/F3 归 progress 收尾 |
| 存量项目审计 / rebuild | 直接调 acr-plan（审计模式）扫 spec↔代码出 diff + 自动生成整改清单；有代码无文档走 rebuild 模式反推 prd/spec |
| 全流程纪律 | 三个审点（prd 后 / plan 后 / 无 progress 审）+ 三个对账点（plan 内部 / cycle 收点 F1 / progress 收尾 F2+F3），agent 不许跳过 |

## 安装

技能源在本仓 `skills/`，装到各 agent 的全局 skills 目录，全局生效（规约不分项目）。

详见 [`INSTALL.md`](INSTALL.md) —— 三层注入规约、skills 同步、各 agent 配置方式都在里面。

## 文档

开发侧的规范文档（设计稿、注入审计）在本地 `docs/`，不进版本库 —— 它们面向「改它的人」，含个人工作习惯细节。使用者看本文件即可。
