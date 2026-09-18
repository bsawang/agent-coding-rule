# 安装与注入

acr 是纯 Markdown skill 集，无编译、无依赖。安装 = 把 `skills/` 下的 6 个目录复制到全局 skills 目录，再配置 agent 的注入层。

---

## 规约：三层注入模型

acr 的规矩分三层注入，按保证强度排序。**三层不重复，避免造第二真相源**。

| 层 | 管什么 | 保证强度 |
|---|---|---|
| **L1 全局硬规则** | 档位判定 + 硬规矩 + bootstrap 触发 | 每轮必看 |
| **L2 skills 目录** | 完整步骤 + 模板 + 参考 | 懒加载，调 skill 时读 |
| **L3 项目级规则** | 项目特定：命令 / 架构 / 文档地图 | 项目内硬注入 |

**L1 放拦截线，L2 放完整定义，L3 放项目特定。三层不重复，避免造第二真相源。**

## 真相源体系

详见 [docs/SSOT.md](docs/SSOT.md)——六层六源 + 谁能写谁只能读 + 禁止事项 + 镜像同步机制。

| 层 | 真相源 |
|---|---|
| 规范层 | 各 `skills/acr-*/SKILL.md` |
| 编号层 | `skills/acr-spec/reference/numbering.md` |
| 设计层 | `docs/prd.md` + `docs/spec.md` |
| 实施层 | `docs/PROGRESS.md`（只有 progress skill 能写） |

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

每个功能/需求按 **发散→prd→spec→plan→progress→cycle** 推进，不得跳步：

> **Skill 路由**：流程骨架走 acr-*（acr-brainstorm 发散+prd / acr-spec 技术规格 / acr-plan 档位+对账+下发 / acr-progress 状态+同步 / acr-cycle 执行 / acr-init 新项目）。存量项目审计走 acr-plan（审计模式），有代码无文档走 acr-plan（rebuild 模式）。

## 档位判定 (acr-plan 内置)

改动**落在哪层文档**决定档位，不由"改动大小"决定 —— 可升不可降：

| 档位 | 判定句 | 做法 |
|------|--------|------|
| 快道 | Mx.y 集合与验收判据都不变 | 直接改代码 → 跑验证 → 写 spec §7 快道日志。免 progress |
| 标准档 | Mx.y 集合或验收判据变，模块边界不变 | prd+spec 增量修订 → 完整 progress → cycle |
| 完整档 | 架构要变（技术底座/模块边界/存储通信方式） | prd+spec 全链修订 → 完整 progress → cycle |

**自检两问**：① Mx.y 集合或某条验收判据要改吗？② 模块边界要改吗？

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

任何功能/需求按 **发散→prd→spec→plan→progress→cycle** 推进，不得跳步。
流程与文档规约由全局 skill `acr-*` 承载（唯一真相源），本文件只保留硬规则。

| 阶段 | skill | 管什么 |
|---|---|---|
| 新项目初始化 | `acr-init` | 空仓 → 项目级规则文件 + 指引 + docs/ 骨架（prd.md + spec.md 占位） |
| 发散 + prd 收敛 | `acr-brainstorm` | 发散方案 → 砍选项 → 收敛 prd.md（业务层） |
| 技术规格 | `acr-spec` | Mx.y 编号 + 需求树 + 验收 + 详细设计 |
| 档位 + 对账 | `acr-plan` | 档位判定（内置）+ 事实预检查 + 下发范围（正常模式嵌流程里；审计/rebuild 独立调用） |
| 状态 + 同步 | `acr-progress` | 计划侧对账 + F2/F3 事实对账 + 状态/游标/回写栏 + 同步回 prd/spec |
| 执行 | `acr-cycle` | 无状态：读 PROGRESS.md 游标续做，收点触发 F1（✅ 必须有本轮新鲜证据） |

**档位判定**（acr-plan 内置）：Mx.y 集合与验收判据都不变 = 快道；Mx.y 集合或验收判据变 + 模块边界不变 = 标准档；架构要变 = 完整档。

**对账点**：plan 事实预检查（spec↔代码）→ cycle F1（收点有证据）→ progress F2+F3（收尾三方 diff）。agent 不许跳过。

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
