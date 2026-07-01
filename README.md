# 🤖 Dual-Ring Gate（双环门禁）

> **让你的AI不再"忘记"自检——不是提醒它做，而是不让它跳过。**
> **Stop your AI from "forgetting" to self-check — not by reminding it, but by making it impossible to skip.**

[![Hermes Skill](https://img.shields.io/badge/Hermes-Skill-blueviolet?style=flat-square)](https://hermes-agent.nousresearch.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

---

## 🎯 一句话 / One-Liner

**中文**：所有AI自检机制都依赖"AI记得去执行它"——但"记得去执行自检"这件事本身，没有自检。**双环门禁补的就是这个元层漏洞。**

**English**: Every AI self-check mechanism relies on the AI *remembering to run it* — but "remembering to run the self-check" has no self-check of its own. **Dual-Ring Gate closes this meta-vulnerability.**

---

## 🔥 为什么你需要它 / Why You Need It

**中文**：如果你使用AI Agent（Claude Code、Cursor、Hermes Agent等），你一定遇到过：

| 场景 | 你花的代价 |
|:-----|:----------|
| AI犯了一个错，你纠正了，它也记住了 | 你花时间教了 |
| 第二天新会话，AI又犯了同样的错 | 你再花时间教一次 |
| 你建立了规则库、检查清单、记忆系统 | 你花心思设计了 |
| AI说"好的记得了"——然后**又跳过自检了** | 你开始怀疑AI能不能真的学会 |

**问题不在AI不聪明，在"自检"和"执行"之间隔了一层"记得"。**

**English**: If you use AI agents (Claude Code, Cursor, Hermes Agent, etc.), you've experienced this:

| Scenario | Your Cost |
|:---------|:----------|
| AI makes a mistake, you correct it, it remembers | You spent time teaching |
| Next day, new session — same mistake again | You teach it again |
| You build rulebooks, checklists, memory systems | You spent effort designing |
| AI says "got it" — then **skips the self-check anyway** | You wonder if it can ever truly learn |

**The problem isn't that AI isn't smart. It's that between "self-check" and "execution" there's a layer called "remembering" — and that layer has no safety net.**

---

## 🏗️ 架构 / Architecture

### 外层环 · Shell Gate（零token · 不可跳过 / Zero-token · Unskippable）

**中文**：由shell脚本在AI启动前强制执行。不依赖AI"记得"——它根本没机会开口。

**English**: Enforced by a shell script *before* the AI can speak. Doesn't rely on the AI "remembering" — it never gets the chance to skip.

```bash
# pre-session-check.sh
date '+%Y-%m-%d %H:%M'           # Time confirmation
hermes gateway status            # Gateway check (cron scheduler)
```

**中文**：如果Gateway没启动 → shell脚本直接启动它 → 启动失败 → 会话拒绝启动。

**English**: Gateway down? The shell starts it. Start fails? Session refuses to launch.

### 内层环 · Prompt Gate（~50token · 不可删除 / Cannot delete）

**中文**：3条最高优先级的指令写入 `SOUL.md`，每次会话自动注入system prompt。AI可以在思维链中忽略它，但**无法删除这个载体**。

**English**: Three high-priority instructions live in `SOUL.md`, auto-injected into every session's system prompt. The AI can ignore them in its chain of thought, but **it cannot delete the container**.

```markdown
## 🔴 Dual-Ring Gate · Inner Ring (auto-injected · cannot skip)
- **Time check**: terminal('date') before every response
- **Gateway check**: verify gateway status on first response of each session
- **Rule update**: every fix must also update the error rule database
```

### 热/温/冷三层 · Rule Lifecycle（动态调整 / Dynamic）

**中文**：规则不是永久的——它们会老、会死。

**English**: Rules aren't permanent — they age, cool down, and retire.

```
🔥 Hot (corrected within 3 days)      → Auto-promoted to inner ring
🌤 Warm (recurrence ≥2)               → Loaded on demand
❄️ Cold (>7 days no recurrence)       → Manual lookup only
🗑️ Retired (30 days no recurrence)    → Archived
```

**中文**：如果某条规则已经退役，但又复发了 → **罚性反弹**：直接回到热层，不走温层。

**English**: A retired rule that recurs? **Penalty bounce** — straight back to hot, skipping warm.

---

## 🆚 与众不同的地方 / What Makes It Different

| 对比维度 / Dimension | 其他方案 / Others (LangGraph/NeMo/Cursor) | **双环门禁 / Dual-Ring Gate** |
|:---------------------|:------------------------------------------|:-----------------------------|
| **Enforcement layers** | Single (prompt OR shell) | **Dual** (shell + prompt, independent) |
| **Rule lifecycle** | ❌ Static — written once, lives forever | ✅ **Dynamic** — auto-demotes, auto-retires |
| **Setup cost** | Deploy a middleware server, modify framework code | **3 minutes**, one skill + one SOUL.md snippet |
| **Token cost** | Full rule set every turn | **Layered on-demand**, hot layer ~50 tokens |
| **External dependency** | Requires dedicated monitoring | ✅ **None** — just say "put it in hot layer" |
| **Reuses existing data** | ❌ Build from scratch | ✅ **One-fish-multi-eat** — plugs into review agents |

**中文**：别人做的是"你犯错→你写规则→规则钉在那"，我们做的是"你犯错→规则进热层→不犯了自动退役"。

**English**: Others do "you make a mistake → you write a rule → the rule stays forever." We do "you make a mistake → rule goes to hot → mistake stops → rule retires itself."

---

## ⚡ 触发方式 / How It Activates

**中文**：双环门禁是**被动技能**——不是"你叫它才触发"，而是"自动生效"。

**English**: Dual-Ring Gate is a **passive skill** — it doesn't wait to be called, it activates automatically.

| 组件 / Component | 触发条件 / Trigger | 触发者 / By |
|:-----------------|:-------------------|:------------|
| **Inner Ring** (SOUL.md) | Every new session | **Auto** — SOUL.md is injected into every system prompt |
| **Outer Ring** (shell script) | Every Hermes launch | **Auto** — configure a shell alias, it runs before you can type |
| **Hot Rules** (hot-rules.json) | When you correct the AI | **Manual or auto** — say "put it in hot layer", or a review agent updates it |

### 装好后什么都不用做 / Zero Configuration After Install

**中文**：你不需要每次手动激活。装好后的第一分钟它就在工作了。

**English**: No manual `/skill dual-ring-gate` needed. It starts working from the first session after install.

```
安装完成 / Installed → 下次新会话 / Next new session
  → SOUL.md注入system prompt（内层环自动生效 / Inner ring auto-activates）
  → shell alias触发pre-session-check.sh（外层环可选 / Outer ring optional）
  → 3条热层规则在prompt里摆着 / 3 hot rules in the prompt
  → 你发现AI忘了查时间 → 你说"放热层" → hot-rules.json更新
  → AI forgets time check → you say "put it in hot" → hot-rules.json updates
```

### 验证是否生效 / Verify It's Working

**中文**：新开一个Hermes会话，看system prompt里是否有这3行。

**English**: Start a fresh Hermes session and check your system prompt for these 3 lines:

```markdown
## 🔴 Dual-Ring Gate · Inner Ring (auto-injected · cannot skip)
- **Time check**: terminal('date') before every response
- **Gateway check**: verify gateway status on first response of each session
- **Rule update**: every fix must also update the error rule database
```

**中文**：有 → 生效了。没有 → 检查SOUL.md是否已追加。

**English**: Present → it's working. Missing → check that SOUL.md has been updated.

---

## ⚡ 快速安装 / Quick Install

### 方式一：一行命令 / One-Line Install

```bash
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md
```

### 方式二：一键脚本 / Auto-Install Script

```bash
curl -fsSL https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/scripts/install.sh | bash
```

### 方式三：手动 / Manual (3 steps, 2 minutes)

**中文**：
1. 把 `AI-skill/dual-ring-gate/SKILL.md` 复制到 `~/.hermes/skills/knowledge/dual-ring-gate/`
2. 把内层环3条指令追加到 `~/.hermes/SOUL.md`
3. 把 `hot-rules.json` 放到 `~/.hermes/flywheel/`，填上你最常犯的3个错误

**English**:
1. Copy `AI-skill/dual-ring-gate/SKILL.md` to `~/.hermes/skills/knowledge/dual-ring-gate/`
2. Append the 3 inner ring instructions to `~/.hermes/SOUL.md`
3. Place `hot-rules.json` in `~/.hermes/flywheel/` and fill in your top 3 mistakes

---

## 📖 使用方式 / Usage Guide

### 🟢 新手模式 / Beginner Mode（即装即用 / Install & Go）

**中文**：装好就有外层环+内层环兜底，不需要任何额外配置。

**English**: Outer ring + inner ring active immediately after install. Zero configuration needed.

### 🟡 进阶模式 / Intermediate Mode（养自己的规则 / Grow Your Own Rules）

**中文**：当AI犯了一个新错误，你只需要说一句。

**English**: When the AI makes a new mistake, just say:

> "我总是不check时间就说话，把它放热层。"
> "I keep speaking without checking the time. Put it in hot layer."

**中文**：AI会自动更新 `hot-rules.json`，把这条规则放入热层。30天没再犯，它自动退役。

**English**: The AI auto-updates `hot-rules.json`, promoting the rule to hot. No recurrence in 30 days → it retires itself.

### 🔴 专家模式 / Expert Mode（接入复盘Agent / Connect a Review Agent）

**中文**：如果你有自己的对话复盘Agent，它可以每天自动扫描对话中的correction信号，自动更新热层。

**English**: If you have a daily review agent that scans conversations, it can auto-extract corrections and update the hot layer.

```mermaid
flowchart LR
    A[Review Agent scans daily conversations] --> B[Extract correction signals]
    B --> C[Sort TOP3 by frequency]
    C --> D[Update hot-rules.json]
    D --> E[Inner ring auto-loads next session]
```

---

## 📂 项目结构 / Project Structure

```
AI-skill/dual-ring-gate/
├── SKILL.md                    ← Main skill file (hermes skills install entry)
├── scripts/
│   ├── pre-session-check.sh    ← Outer ring shell gate
│   └── install.sh              ← Auto-install script
└── templates/
    └── hot-rules.json          ← Hot rules template
```

---

## 🤝 参与贡献 / Contribute

**中文**：这是一个开源项目，欢迎参与。

**English**: This is an open-source project. Contributions welcome!

- ⭐ Star to encourage
- 🐛 Open an Issue for bugs or ideas
- 🔀 Submit a PR to improve the code
- 💡 Share your use cases and experience

---

## 📜 许可证 / License

MIT License — 自由使用、修改、分发。 / Free to use, modify, and distribute.

---

## 👥 关于 / About

**中文**：由 [@Ghl211](https://github.com/Ghl211) 创建和维护。受到自进化方法论（五步法：感知→分析→决策→执行→反馈+记忆）启发，将"规则执行门禁"从方法论层面的概念落地为可安装的Hermes技能。

**English**: Created and maintained by [@Ghl211](https://github.com/Ghl211). Inspired by the Self-Evolution Methodology (5-Step: Sense → Diagnose → Decide → Act → Feedback & Memory), Dual-Ring Gate brings the concept of "execution guardrails for rules" from methodology theory into an installable Hermes skill.

> *"你投进系统里的每一次纠正，不应该清零——它应该折旧，但不是白费。"*
> *"Every correction you invest in the system shouldn't reset to zero — it should depreciate, but never be wasted."*
