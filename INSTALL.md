# 安装与注入

acr 是纯 Markdown skill 集，无编译、无依赖。安装 = 把 `skills/` 下的 7 个目录复制到全局 skills 目录，再配置 agent 的注入层。

---

## 规约：三层注入模型

acr 的规矩分三层注入，按保证强度排序。**三层不重复，避免造第二真相源**。

| 层 | 管什么 | 保证强度 |
|---|---|---|
| **L1 全局硬规则** | 档位判定 + 硬规矩 + bootstrap 触发 | 每轮必看 |
| **L2 skills 目录** | 完整步骤 + 模板 + 参考 | 懒加载，调 skill 时读 |
| **L3 项目级规则** | 项目特定：命令 / 架构 / 文档地图 | 项目内硬注入 |

**L1 放拦截线，L2 放完整定义，L3 放项目特定。三层不重复，避免造第二真相源。**

## 真相源

| 层 | 真相源位置 |
|---|---|
| L2 skills | 本仓 `skills/` 目录——唯一，改了要同步到全局 |
| L1 全局规则 | 各平台的全局规则文件（见下方平台配置） |
| L3 项目级规则 | 各项目仓库内 |

## Bootstrap

进入新项目时，agent 自动检查项目级规则文件是否存在。**不存在 → 调 acr-init 生成项目骨架**（规则文件 + docs/ 规约骨架）。

acr-init 只负责生成内容，不写死注入位置——由当前 agent 决定写入哪个文件。

---

## 平台配置

### Trae

#### Skills 目录

全局路径：`~/.trae-cn/skills/`

同步（仓库 → 全局）：

```bash
cp -r skills/acr-* ~/.trae-cn/skills/
```

漂移检查（仓库 vs 全局）：

```bash
for s in skills/acr-*; do
  diff -r "$s" "$HOME/.trae-cn/${s#skills/}" && echo "一致 $s" || echo "漂移 $s"
done
```

#### 全局规则

`~/.trae-cn/rules/user_rules.md`——硬注入，每轮进 system prompt：

```markdown
# 用户全局开发规则

## 功能开发标准流程（六阶段）

每个功能/需求按 **设计 → 评审 → 计划 → 开发 → 测试 → 收尾** 推进，不得跳步：

> **Skill 路由**：流程骨架走 acr-*（acr-brainstorm 发散方案 / acr-spec 写需求 / acr-design-docs 写设计 / acr-cycle 完整循环 / acr-progress 维护进度 / acr-retrofit 文档重整 / acr-init 新项目初始化）。

## 档位判定 (acr-cycle 入口)

改动**落在哪层文档**决定档位，不由"改动大小"决定 —— 可升不可降：

| 档位 | 判定句 | 做法 |
|------|--------|------|
| 快道 | spec 不变 | 记一条 spec 调整日志，免设计评审，开发→测试→收尾 |
| 标准档 | spec 变，概要设计不变 | spec 修订 + 详细设计 + 走完整循环 |
| 完整档 | 概要/架构设计变 | spec → 概要 → 架构 → 详细 + 走完整循环 |

**自检两问**：① 这次改动，spec 里那句需求描述要改吗？要改 → 不是快道。② 模块划分要改吗？要改 → 完整档。

**升级规则**：任何一档进行中发现上层文档要改，**就地升级、不硬推**。

## 硬规矩（不可破）

- 设计未经用户确认，Edit/Write 改实现代码一律拦下
- **没在本轮对话里跑过验证命令，就不许声称通过/修好/完成**（"应该能过" = 去跑）
- 一次一个功能点，不攒到最后一起验证
- 实现偏离设计时只有两个出口：**改设计文档 or 改代码**，不许"先这样吧"
- 快道中发现上层文档要改，就地升级档位，不硬推

## Bootstrap：新项目自动初始化

进入新项目时，检查项目级规则文件是否存在（`.trae/rules/project_rules.md`）。**不存在 → 调 acr-init 生成项目骨架**。

## 项目特定约定

项目特有架构约定、常用命令、文档地图以各仓库项目级规则文件为准。全局只管流程骨架。
```

Trae 无 `skillOverrides` 配置——skills 目录里的 skill 自动生效。

---

### Claude Code

#### Skills 目录

全局路径：`~/.claude/skills/`

同步：

```bash
cp -r skills/acr-* ~/.claude/skills/
```

漂移检查：

```bash
for s in skills/acr-*; do
  diff -r "$s" "$HOME/.claude/${s#skills/}" && echo "一致 $s" || echo "漂移 $s"
done
```

#### 全局 CLAUDE.md

`~/.claude/CLAUDE.md`——CC 的全局规则文件，软注入（每次启动时读）：

```markdown
# Global Preferences

## 功能开发标准流程（六阶段）

任何功能/需求按 **设计 → 评审 → 计划 → 开发 → 测试 → 收尾** 推进，不得跳步。
流程与文档规约由全局 skill `acr-*` 承载（唯一真相源），本文件只保留硬规则。

| 阶段 | skill | 管什么 |
|---|---|---|
| 新项目初始化 | `acr-init` | 空仓 → 项目级规则文件 + CLAUDE.md + docs/ 骨架 |
| 设计 | `acr-brainstorm` → `acr-spec` → `acr-design-docs` | 头脑风暴、需求文档、三层设计文档 |
| 评审 | `acr-cycle` ④ | 方案未获用户确认，不写任何实现代码 |
| 计划 | `acr-progress` | 建循环、登记功能点与验收标准 |
| 开发 | `acr-cycle` ⑥ | 功能点循环、不自发 git、假设塌方就停 |
| 测试 | `acr-cycle` ⑦ | 证据先于断言，测试不过不进收尾 |
| 收尾 | `acr-cycle` ⑨ | 评审接收、文档同步、分主题提交、集成决策、推送 |
| 存量项目文档重整 | `acr-retrofit` | 老文档重整进 `docs-rebuilt/`，原文档一律不动 |

**档位判定**（改动落在哪层文档决定档位，详见 `acr-cycle` 入口）：spec 不变 = 快道（记调整日志）；spec 变 = 标准档；概要或架构变 = 完整档。自检两问：① spec 里那句需求描述要改吗？② 模块划分要改吗？

**Bootstrap**：进入新项目时检查规则文件是否存在（`CLAUDE.md` 根目录）。不存在 → 调 `acr-init` 生成骨架。

硬规则：
- **设计未经用户确认，不写任何实现代码**（评审门槛，所有体系通用）。
- **没在本轮对话里跑过验证命令，不许声称通过/修好/完成**（"应该能过" = 去跑）。
- **一次一个功能点，不攒到最后一起验证**。
- **实现偏离设计时只有两个出口：改设计文档 or 改代码**，不许"先这样吧"。
- **快道中发现上层文档要改，就地升级档位**，不硬推。
- 测试不通过不进入收尾；收尾必须同步文档（README/进度表）、分主题提交推送（feat/fix/docs 分开）。
- 中途发现方案问题，回退设计重新对齐，不带病推进。
```

---

### Cursor

#### Skills 目录

全局路径：`~/.cursor/skills/`（无官方规范，手动建）

同步：

```bash
cp -r skills/acr-* ~/.cursor/skills/
```

漂移检查：

```bash
for s in skills/acr-*; do
  diff -r "$s" "$HOME/.cursor/${s#skills/}" && echo "一致 $s" || echo "漂移 $s"
done
```

#### 全局规则

Cursor 用 `~/.cursorrules` 作为全局规则文件，格式与 CLAUDE.md 等价。内容参考上面 Trae 或 CC 的模板，按你喜欢的风格选一个。
