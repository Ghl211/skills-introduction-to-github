<p align="center">
  <h1 align="center">🤖 Dual-Ring Gate（双环门禁）</h1>
  <p align="center">
    <em>让 AI 的自检不再依赖"记得去执行"——不检查，不启动。</em>
  </p>
  <p align="center">
    <a href="https://github.com/Ghl211/skills-introduction-to-github/stargazers">
      <img src="https://img.shields.io/github/stars/Ghl211/skills-introduction-to-github?style=flat-square&logo=github" alt="Stars">
    </a>
    <a href="https://github.com/Ghl211/skills-introduction-to-github/blob/main/LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-green.svg?style=flat-square" alt="MIT License">
    </a>
    <a href="https://hermes-agent.nousresearch.com/">
      <img src="https://img.shields.io/badge/Hermes-Skill-blueviolet?style=flat-square" alt="Hermes Skill">
    </a>
    <a href="https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md">
      <img src="https://img.shields.io/badge/安装-hermes%20skills%20install-blue?style=flat-square" alt="安装">
    </a>
    <a href="https://github.com/Ghl211/skills-introduction-to-github/pulls">
      <img src="https://img.shields.io/badge/PR-欢迎-brightgreen?style=flat-square" alt="PR欢迎">
    </a>
  </p>
  <p align="center">
    <a href="README.md">English</a> | <a href="README_CN.md">中文</a>
  </p>
</p>

---

## 快速安装

```bash
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md```

装完重启 Hermes 会话即可——内层环自动生效。

---

## 核心特性

| 特性 | 说明 |
|:-----|:------|
| 🛡️ **双层强制** | Shell 门禁（不可跳过）+ Prompt 固化（不可删除） |
| 🔄 **规则生命周期** | 30 天无复发自动退役，规则不会无限堆积 |
| ⚡ **零配置启动** | 装好即生效，无需手动激活 |
| 🪶 **轻量无感** | 热层仅 ~50 token，外层环零 token |
| 🧩 **可独立可联动** | 独立使用，也可对接已有的复盘 Agent |

---

## 架构

```
┌─────────────────────────────────────┐
│  外层环 · Shell 门禁                 │
│  AI 开口前强制执行                    │
├─────────────────────────────────────┤
│  内层环 · Prompt 固化                │
│  写入 SOUL.md，每次会话自动注入        │
├──────────────┬──────────────────────┤
│ 🔥 热层      │ 🌤 温层              │
│ 近 3 天被纠正  │ 累计复发 ≥ 2 次     │
├──────────────┼──────────────────────┤
│ ❄️ 冷层      │ 🗑️ 退役             │
│ >7 天无复发   │ 30 天 → 归档         │
└──────────────┴──────────────────────┘
```

---

## 使用方式

### 🟢 新手模式——装好就用

无需配置。下次新会话，外层环 + 内层环自动生效。

### 🟡 进阶模式——养自己的规则

当 AI 犯了一个新错误，直接告诉它：

> "我总是不看时间就说话，把它放热层。"

AI 自动更新 `hot-rules.json`。30 天没再犯？规则自动退役。

### 🔴 专家模式——接入复盘 Agent

如果有每日复盘 Agent，它可以自动扫描对话中的纠正信号，自动更新热层：

```
复盘Agent → 提取纠正信号 → 排序TOP3 → 更新hot-rules.json → 次日加载新规则
```

---

## 验证是否生效

新开一个 Hermes 会话，检查 system prompt 中是否有以下 3 行：

```
## 🔴 Dual-Ring Gate · Inner Ring (auto-injected · cannot skip)
- **Time check**: terminal('date') before every response
- **Gateway check**: verify gateway status on first response
- **Rule update**: every fix must also update the error rule database
```

有 → 生效了。没有 → 检查 `~/.hermes/SOUL.md` 是否已追加。

---

## 触发方式

| 组件 | 触发条件 | 自动化程度 |
|:-----|:---------|:----------:|
| **内层环** | 每次新会话 | ✅ 自动 |
| **外层环**（shell脚本） | 每次启动 Hermes | ✅ 自动（配置 alias 后） |
| **热层更新** | 你纠正 AI 时 | 🔄 手动或自动 |

---

## 安装方式

### 一行命令
```bash
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md```

### 一键脚本
```bash
curl -fsSL https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/scripts/install.sh | bash```

### 手动安装（3 步）
1. 把 `AI-skill/dual-ring-gate/SKILL.md` 复制到 `~/.hermes/skills/knowledge/dual-ring-gate/`
2. 把内层环指令追加到 `~/.hermes/SOUL.md`
3. 把 `hot-rules.json` 放到 `~/.hermes/flywheel/`，填上你最常犯的 3 个错误

---

## 项目结构

```
AI-skill/dual-ring-gate/
├── SKILL.md                    ← 主技能文件（安装入口）
├── scripts/
│   ├── pre-session-check.sh    ← 外层环 Shell 门禁
│   └── install.sh              ← 一键安装脚本
└── templates/
    └── hot-rules.json          ← 热层规则模板
```

---

## 参与贡献

欢迎参与！⭐ Star · 🐛 Issue · 🔀 PR · 💬 分享

---

## 社区

- **Issues**：[github.com/Ghl211/skills-introduction-to-github/issues](https://github.com/Ghl211/skills-introduction-to-github/issues)
- **Discussion**：GitHub Discussions
- **Hermes Discord**：[discord.gg/hermes-agent](https://discord.gg/hermes-agent)

---

## 许可证

MIT License。自由使用、修改、分发。
