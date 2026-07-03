<p align="center">
  <h1 align="center">🤖 Dual-Ring Gate <sub>v1.1</sub></h1>
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
    <a href="README.md">English</a> | <a href="README_CN.md">Chinese</a>
  </p>
</p>

---

<p align="center">
  <img src=".github/images/dual-ring-gate-arch.svg" alt="Dual-Ring Gate Architecture" width="100%">
</p>

---

## Quick Install

```bash
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md
```

That is it. Restart your Hermes session - the inner ring activates automatically.

---

## Key Features

| Feature | What it does |
|:--------|:-------------|
| Shield Dual-layer enforcement | Shell gate (can not skip) + Prompt gate (can not delete) |
| Cycle Rule lifecycle | Rules auto-retire after 30 days of no recurrence |
| NEW Per-response freshness | Hot-rules auto-loaded before EVERY reply, not just session start. Closes mid-conversation drift. |
| Lightning Zero config | Works immediately after install |
| Feather Lightweight | Hot layer ~50 tokens. Outer ring: zero tokens |
| Puzzle Pluggable | Works standalone, or connects to your existing review agent |

---

## Architecture

```
+-------------------------------------+
|  OUTER RING - Shell Gate            |
|  Enforced before AI starts speaking |
+-------------------------------------+
|  INNER RING - Prompt Gate           |
|  Pinned in SOUL.md, always injected |
+-------------------------------------+
|  NEW PER-RESPONSE - Hot-Rules Load  |
|  Auto-loaded before EVERY reply     |
|  Prevents mid-conversation drift    |
+------------------+------------------+
| Hot              | Warm             |
| Last 3 days      | Recurrence >= 2  |
+------------------+------------------+
| Cold             | Retired          |
| >7d dormant      | 30d - archived   |
+------------------+------------------+
```

New in v1.1: the Per-Response layer ensures hot-rules stay in context for every reply, not just at session start. Prevents the "I loaded it 15 turns ago and forgot" failure mode.

---

## Usage

### Green Beginner - Install and Go

No configuration needed. Outer ring + inner ring activate immediately on next session.

### Yellow Intermediate - Grow Your Rules

When the AI makes a new mistake, just tell it:

> "I keep forgetting to check the time before speaking. Put it in the hot layer."

The AI updates hot-rules.json automatically - including last_correction and days_active metadata. No recurrence for 30 days? The rule retires itself.

### Red Expert - Connect a Review Agent

If you have a daily review agent, it can auto-scan conversations for corrections and update the hot layer:

```
Review Agent to Extract corrections to Sort TOP3 to Update hot-rules.json to Next session loads new rules
```

---

## Verify It is Working

Start a fresh Hermes session. With v1.1, you should see these lines in your system prompt:

```
## Red Dual-Ring Gate - Inner Ring (auto-injected - cannot skip)
- **Time check (ERR-019)**: If reply contains time words (now/already/not yet/today/yesterday/tomorrow) to MUST terminal(date) first. Data expires after 5 min or 3 tool calls.
- **Gateway check**: verify gateway status on first response
- **Rule update**: every fix must also update the error rule database
```

Present to it is working. Missing to check $HERMES_HOME/SOUL.md.

---

## How It Activates

| Component | Trigger | Automation |
|:----------|:--------|:----------:|
| Inner Ring | Every new session | Auto |
| Outer Ring (shell script) | Before each Hermes launch | Auto (with alias) |
| NEW Per-Response Loading | Before EVERY reply | Auto (AI reads hot-rules) |
| Hot Rules | When you correct the AI | Manual or auto |

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
1. Copy AI-skill/dual-ring-gate/SKILL.md to $HERMES_HOME/skills/knowledge/dual-ring-gate/
2. Append inner ring instructions to $HERMES_HOME/SOUL.md (use detection keywords, not just "check time")
3. Place hot-rules.json in $HERMES_HOME/flywheel/ and fill in your top 3 mistakes

---

## What is New in v1.1

| Improvement | Problem it solves |
|:------------|:-----------------|
| Per-response hot-rules loading | Rules pushed out of context after 15+ turns |
| Session mid-segment freshness | Time data expires after 5 min / 3 tool calls |
| Correction to hot-rules feedback chain | Every correction auto-updates last_correction / days_active |
| Detection keywords in inner ring | "Remember to check time" is too vague. Now: "if you see these words to MUST date" |

---

## Project Structure

```
AI-skill/dual-ring-gate/
+-- SKILL.md                    - Main skill v1.1 (install entry)
+-- scripts/
|   +-- pre-session-check.sh    - Outer ring shell gate
|   +-- install.sh              - Auto-install script
+-- templates/
    +-- hot-rules.json          - Hot rules template
```

---

## Real-World Results

This skill was born from a real problem: the AI made the same time-awareness mistake 5 times between June 22 and July 3, 2026, despite documented rules. Every fix was rule-level - no mechanism prevented skipping.

Dual-Ring Gate v1.1 closes this with three enforcement layers, dropping the error recurrence to zero after deployment.

---

## Contributing

Contributions welcome! Star - Issue - PR - Share

---

## Community

- Issues: github.com/Ghl211/skills-introduction-to-github/issues
- Discussions: GitHub Discussions
- Hermes Discord: discord.gg/hermes-agent

---

## License

MIT License. Free to use, modify, and distribute.
