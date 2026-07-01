<p align="center">
  <h1 align="center">🤖 Dual-Ring Gate</h1>
  <p align="center">
    <em>A Hermes Agent skill that makes self-checks impossible to skip.<br>
    Not by reminding the AI — by making it physically unable to bypass.</em>
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
      <img src="https://img.shields.io/badge/Install-hermes%20skills%20install-blue?style=flat-square" alt="Install">
    </a>
    <a href="https://github.com/Ghl211/skills-introduction-to-github/pulls">
      <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square" alt="PRs Welcome">
    </a>
  </p>
  <p align="center">
    <a href="README.md">English</a> | <a href="README_CN.md">中文</a>
  </p>
</p>

---

## Quick Install

```bash
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md
```

That's it. Restart your Hermes session — the inner ring activates automatically.

---

## Key Features

| Feature | What it does |
|:--------|:-------------|
| 🛡️ **Dual-layer enforcement** | Shell gate (can't skip) + Prompt gate (can't delete) |
| 🔄 **Rule lifecycle** | Rules auto-retire after 30 days of no recurrence |
| ⚡ **Zero config** | Works immediately after install |
| 🪶 **Lightweight** | Hot layer ~50 tokens. Outer ring: zero tokens |
| 🧩 **Pluggable** | Works standalone, or connects to your existing review agent |

---

## Architecture

```
┌─────────────────────────────────────┐
│  OUTER RING · Shell Gate            │
│  Enforced before AI starts speaking │
├─────────────────────────────────────┤
│  INNER RING · Prompt Gate           │
│  Pinned in SOUL.md, always injected │
├──────────────┬──────────────────────┤
│ 🔥 Hot       │ 🌤 Warm              │
│ Last 3 days  │ Recurrence ≥ 2       │
├──────────────┼──────────────────────┤
│ ❄️ Cold      │ 🗑️ Retired           │
│ >7d dormant  │ 30d → archived       │
└──────────────┴──────────────────────┘
```

---

## Usage

### 🟢 Beginner — Install & Go

No configuration needed. Outer ring + inner ring activate immediately on next session.

### 🟡 Intermediate — Grow Your Rules

When the AI makes a new mistake, just tell it:

> _"I keep forgetting to check the time before speaking. Put it in the hot layer."_

The AI updates `hot-rules.json` automatically. No recurrence for 30 days? The rule retires itself.

### 🔴 Expert — Connect a Review Agent

If you have a daily review agent, it can auto-scan conversations for corrections and update the hot layer:

```
Review Agent → Extract corrections → Sort TOP3 → Update hot-rules.json → Next session loads new rules
```

---

## Verify It's Working

Start a fresh Hermes session. You should see these 3 lines in your system prompt:

```
## 🔴 Dual-Ring Gate · Inner Ring (auto-injected · cannot skip)
- **Time check**: terminal('date') before every response
- **Gateway check**: verify gateway status on first response
- **Rule update**: every fix must also update the error rule database
```

Present → it's working. Missing → check `~/.hermes/SOUL.md`.

---

## How It Activates

| Component | Trigger | Automation |
|:----------|:--------|:----------:|
| **Inner Ring** | Every new session | ✅ Auto |
| **Outer Ring** (shell script) | Before each Hermes launch | ✅ Auto (with alias) |
| **Hot Rules** | When you correct the AI | 🔄 Manual or auto |

---

## Install Options

### One-liner
```bash
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md
```

### Auto-install script
```bash
curl -fsSL https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/scripts/install.sh | bash
```

### Manual (3 steps)
1. Copy `AI-skill/dual-ring-gate/SKILL.md` → `~/.hermes/skills/knowledge/dual-ring-gate/`
2. Append inner ring instructions to `~/.hermes/SOUL.md`
3. Place `hot-rules.json` in `~/.hermes/flywheel/` and fill in your top 3 mistakes

---

## Project Structure

```
AI-skill/dual-ring-gate/
├── SKILL.md                    ← Main skill (install entry)
├── scripts/
│   ├── pre-session-check.sh    ← Outer ring shell gate
│   └── install.sh              ← Auto-install script
└── templates/
    └── hot-rules.json          ← Hot rules template
```

---

## Contributing

Contributions welcome! ⭐ Star · 🐛 Issue · 🔀 PR · 💬 Share

---

## Community

- **Issues**: [github.com/Ghl211/skills-introduction-to-github/issues](https://github.com/Ghl211/skills-introduction-to-github/issues)
- **Discussions**: GitHub Discussions
- **Hermes Discord**: [discord.gg/hermes-agent](https://discord.gg/hermes-agent)

---

## License

MIT License. Free to use, modify, and distribute.
