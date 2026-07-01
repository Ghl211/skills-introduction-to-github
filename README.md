<p align="center">
  <h1 align="center">🤖 Dual-Ring Gate（双环门禁）</h1>
  <p align="center">
    <em>让AI的自检不再依赖"记得"——不检查，不启动。</em><br>
    <em>Stop your AI from "forgetting" to self-check — not by reminding it, but by making it impossible to skip.</em>
  </p>
  <p align="center">
    <a href="https://hermes-agent.nousresearch.com/">
      <img src="https://img.shields.io/badge/Hermes-Skill-blueviolet?style=flat-square" alt="Hermes Skill">
    </a>
    <a href="https://opensource.org/licenses/MIT">
      <img src="https://img.shields.io/badge/License-MIT-green.svg?style=flat-square" alt="MIT License">
    </a>
    <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square" alt="PRs Welcome">
  </p>
</p>

---

**其他语言 / Other Languages**: [English](README.md) | [中文](README.md)

---

<p align="center">
  <b>📦 一行安装 / One-Line Install</b><br>
  <code>hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md</code>
</p>

---

## ✨ 核心特性 / Key Features

**中文**：

| 特性 | 说明 |
|:-----|:-----|
| 🛡️ **双层强制** | Shell门禁 + Prompt固化，双层兜底，不可跳过 |
| 🔄 **规则生命周期** | 热→温→冷→退役，30天无触碰自动消失 |
| ⚡ **零配置启动** | 装好即生效，无需手动激活 |
| 🪶 **轻量无感** | 热层仅~50 token，外层环零 token |
| 🧩 **可接入复盘Agent** | 已有复盘系统？自动对接，无需改造 |

**English**：

| Feature | Description |
|:--------|:------------|
| 🛡️ **Dual-Layer Enforcement** | Shell gate + Prompt pinning — two independent layers, neither skippable |
| 🔄 **Rule Lifecycle** | Hot → Warm → Cold → Retire. Unused rules disappear after 30 days |
| ⚡ **Zero Config** | Works immediately after install. No manual activation needed |
| 🪶 **Lightweight** | Hot layer ~50 tokens only. Outer ring: zero tokens |
| 🧩 **Plugs into Review Agents** | Already have a daily review agent? It auto-updates the hot layer |

---

## 🏗️ 架构 / Architecture

```
┌─────────────────────────────────────────────┐
│  🛡️ 外层环 · Outer Ring (Shell Gate)        │
│  zero token · 不可跳过 · unskippable          │
├─────────────────────────────────────────────┤
│  📌 内层环 · Inner Ring (Prompt Gate)        │
│  ~50 token/次 · 不可删除 · undeletable       │
├──────────────────────┬──────────────────────┤
│ 🔥 Hot 热层           │ 🌤 Warm 温层          │
│ 最近3天被纠正过的规则  │ 累计复发≥2次的规则     │
│ Corrected in 3 days   │ Recurrence ≥2        │
├──────────────────────┼──────────────────────┤
│ ❄️ Cold 冷层           │ 🗑️ Retired 退役      │
│ >7天无复发            │ 30天无复发 → 归档     │
│ No recurrence for 7d  │ 30d → archived       │
└──────────────────────┴──────────────────────┘
```

---

## 🚀 快速开始 / Quick Start

### 安装 / Install

| 方式 | 命令 |
|:-----|:-----|
| **一行命令** | `hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md` |
| **一键脚本** | `curl -fsSL https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/scripts/install.sh \| bash` |
| **手动安装** | 见下方 / See below |

### 验证 / Verify

**中文**：新开一个Hermes会话，看system prompt中是否有以下3行：

**English**: Start a fresh Hermes session and check your system prompt for these 3 lines:

```
## 🔴 Dual-Ring Gate · Inner Ring (auto-injected · cannot skip)
- **Time check**: terminal('date') before every response
- **Gateway check**: verify gateway status on first response
- **Rule update**: every fix must also update the error rule database
```

---

## 📖 使用指南 / Usage Guide

### 🟢 新手模式 / Beginner — Install & Go

**中文**：装好即用，无需配置。外层环 + 内层环自动生效。

**English**: Install and it works. Outer ring + inner ring active immediately.

### 🟡 进阶模式 / Intermediate — Grow Your Rules

**中文**：当AI犯了新错误，只需说一句：

**English**: When the AI makes a new mistake, just say:

> "我总是不确认时间就说话，把它放热层。"
> "I keep speaking without checking the time. Put it in hot layer."

**中文**：AI自动更新 `hot-rules.json`。30天没再犯 → 自动退役。

**English**: The AI updates `hot-rules.json`. No recurrence in 30 days → auto-retired.

### 🔴 专家模式 / Expert — Connect a Review Agent

**中文**：如有每日复盘Agent，它会自动扫描对话中的纠正信号，自动更新热层。

**English**: If you have a daily review agent, it auto-scans conversations for corrections and updates the hot layer.

```
复盘Agent → 提取correction → 排序TOP3 → 更新hot-rules.json → 内层环次日加载
Review Agent → Extract corrections → Sort TOP3 → Update hot-rules.json → Inner ring loads next session
```

---

## ⚙️ 触发机制 / How It Activates

**中文**：双环门禁是被动技能——不调不叫，自动生效。

**English**: Dual-Ring Gate is a passive skill — once installed, it activates automatically.

| 组件 / Component | 触发条件 / Trigger | 自动程度 / Auto |
|:-----------------|:-------------------|:---------------:|
| **内层环 Inner Ring** | 每次新会话 Every new session | ✅ 自动 / Auto |
| **外层环 Outer Ring** | 每次启动Hermes Before every launch | ✅ 自动（需配置alias） |
| **热层更新 Hot Rules** | 你纠正AI时 When you correct the AI | 🔄 手动或自动 Auto or manual |

---

## 📁 项目结构 / Project Structure

```
AI-skill/dual-ring-gate/
├── SKILL.md                    ← 主文件 / Main skill (install entry)
├── scripts/
│   ├── pre-session-check.sh    ← 外层环 / Outer ring shell gate
│   └── install.sh              ← 安装脚本 / Auto-install
└── templates/
    └── hot-rules.json          ← 热层模板 / Hot rules template
```

---

## 🤝 参与贡献 / Contributing

**中文**：欢迎参与！Star、Issue、PR、分享案例，都是支持。

**English**: Contributions welcome! Stars, Issues, PRs, and sharing your story — all appreciated.

- ⭐ **Star** — 让更多人看到 / Help others discover it
- 🐛 **Issue** — 报告问题或提建议 / Report bugs or suggest features
- 🔀 **PR** — 改进代码或文档 / Improve code or docs
- 💬 **分享 / Share** — 在社区推荐它 / Spread the word in the Hermes community

---

## 🌐 社区 / Community

- **Hermes Discord**: https://discord.gg/hermes-agent
- **GitHub Issues**: 提交问题 / Submit issues [here](https://github.com/Ghl211/skills-introduction-to-github/issues)
- **GitHub Discussions**: 讨论用法 / Discuss usage

---

## 📜 许可证 / License

MIT License. 自由使用、修改、分发。Free to use, modify, and distribute.

---

<p align="center">
  <sub>受到自进化方法论（五步法：感知→分析→决策→执行→反馈+记忆）启发。<br>
  Inspired by the Self-Evolution Methodology (5-Step: Sense → Diagnose → Decide → Act → Feedback & Memory).</sub>
</p>
