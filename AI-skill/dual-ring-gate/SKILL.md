---
name: dual-ring-gate
description: "Use when your Hermes agent repeatedly skips self-checks despite documented rules. Dual-Ring Gate prevents 'remember-to-check' failures with two enforcement layers: a zero-token shell gate (outer ring) and a session-pinned prompt gate (inner ring), plus a hot/warm/cold rule lifecycle system."
version: 1.0.0
author: 知夏 & 皓麟
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [self-check, guardrails, reliability, self-evolution, meta]
    related_skills: [session-startup]
---

# Dual-Ring Gate (双环门禁)

> **Stop your AI from "forgetting" to self-check — make it impossible to skip.**

The meta-vulnerability of AI agents: every self-check mechanism (memory rules, skills, checklists) depends on the agent *remembering to load and execute it*. But "remembering to load the self-check" has no self-check of its own.

Dual-Ring Gate closes this gap by moving self-checks from **"the AI decides to do them"** to **"the system forces them before the AI speaks"**.

---

## When to Use

Apply this skill when your Hermes agent:

- ❌ Repeatedly makes the same mistake despite documented rules
- ❌ Skips startup checks (time confirmation, gateway status) in new sessions
- ❌ Fixes problems without updating its error rule database
- ❌ Has a growing pile of static rules that never get pruned or updated
- ❌ You're spending more time correcting it than it saves

**Don't use for**: one-shot tasks, simple queries, or agents that already follow their rules perfectly.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│              OUTER RING · Shell Gate             │
│  [shell] pre-session-check.sh                   │
│  date + gateway + workspace-health               │
│  FAIL → session refused to start                │
│  Token cost: 0                                  │
│  Bypass-proof: ★★★★★ (infrastructure level)     │
├─────────────────────────────────────────────────┤
│              INNER RING · Prompt Gate            │
│  [system prompt] 3 pinned instructions           │
│  Always injected via SOUL.md / AGENTS.md         │
│  Token cost: ~50/turn                            │
│  Bypass-proof: ★★★★ (AI can ignore, can't delete)│
├─────────────────────────────────────────────────┤
│              HOT/WARM/COLD · Rule Lifecycle      │
│  Rules age, cool down, and retire automatically  │
│  Token cost: on-demand loading                   │
│  Feedback-driven dynamic adjustment              │
└─────────────────────────────────────────────────┘
```

---

## Quick Start (5 minutes)

### 1. Install the Skill

```bash
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md
```

Or copy `SKILL.md` to `~/.hermes/skills/knowledge/dual-ring-gate/`.

### 2. Inject Inner Ring into Your SOUL.md

Append to `~/.hermes/SOUL.md`:

```markdown
## 🔴 Dual-Ring Gate · Inner Ring (auto-injected · cannot skip)
- **Time check**: `terminal('date')` before every response
- **Gateway check**: verify gateway status on first response of each session
- **Rule update**: every fix must also update the error rule database
```

**Why SOUL.md?** It's the one file Hermes always loads into every session, regardless of working directory or project. The instructions sit in the system prompt automatically — no forgetting, no skipping.

### 3. Create Your Hot Rules (Manual Mode)

Create `~/.hermes/flywheel/hot-rules.json`:

```json
{
  "updated": "2026-07-01",
  "hot": [
    {
      "rule": "terminal('date') before every response",
      "reason": "Most frequent error — speaking without checking time",
      "days_active": 1,
      "last_correction": "2026-07-01"
    },
    {
      "rule": "Update error DB after every fix",
      "reason": "Fixes without rule updates leave no trace",
      "days_active": 1,
      "last_correction": "2026-07-01"
    },
    {
      "rule": "Check gateway on session start",
      "reason": "Gateway runs cron scheduler — offline = missed tasks",
      "days_active": 1,
      "last_correction": "2026-07-01"
    }
  ],
  "warm": [],
  "meta": {
    "hot_promote_if": "New correction within last 3 days",
    "warm_cooldown": "No recurrence for 7 days → warm → cold",
    "retire_after_days": 30,
    "retire_reentry": "Retired rule that recurs → direct to hot (penalty for old habits)"
  }
}
```

### 4. (Optional) Set Up Outer Ring Shell Gate

Create `~/.hermes/scripts/pre-session-check.sh`:

```bash
#!/bin/bash
set -e
echo "=== Dual-Ring Gate · Outer Ring ==="
echo "[CHECK] Time: $(date '+%Y-%m-%d %H:%M %A')"
GW_STATUS=$(hermes gateway status 2>&1)
if echo "$GW_STATUS" | grep -q "running"; then
    echo "[PASS] Gateway running"
else
    echo "[FAIL] Gateway not running, starting..."
    hermes gateway run --replace
    sleep 2
    hermes gateway status | grep -q "running" || {
        echo "[FATAL] Gateway start failed"
        exit 1
    }
    echo "[PASS] Gateway started"
fi
echo "=== Outer Ring Passed ==="
```

Run on session start via shell init (`~/.bashrc`) or a `hermes` wrapper script:

```bash
alias hermes='~/.hermes/scripts/pre-session-check.sh && hermes'
```

---

## Rule Lifecycle: Hot → Warm → Cold → Retire

Rules should not accumulate forever. They should age, cool down, and retire.

| Layer | Condition | Volume | Access |
|:------|:----------|:------:|:-------|
| 🔥 **Hot** | Corrected within last 3 days | 2-3 rules, ~50 tokens | Pinned in inner ring + pre-response check |
| 🌤 **Warm** | Recurrence ≥2 or structural rules | ERR summary, ~500 tokens | Loaded on task-type match |
| ❄️ **Cold** | Archived >7 days no recurrence | Full rule DB, ~7-15K tokens | Manual lookup only |

### Automatic Lifecycle Rules

- **7 days no correction** → Hot → Warm (auto-demote)
- **30 days no correction** → Cold → Retire (can be archived)
- **Retired rule recurs** → Direct to Hot (penalty bounce — not Warm)

---

## Interactive Mode (No external feedback source needed)

If you don't have an automated correction-detection system, just tell your agent:

> "I keep making [mistake X]. Put it in hot rules."

The agent will update `hot-rules.json` automatically. This is the **manual feedback mode** — you say it once, it takes effect on next session.

### Example Commands

| You say | Agent does |
|:--------|:-----------|
| "I keep forgetting to check time before speaking" | Adds "date before response" to hot layer |
| "That rule hasn't triggered in weeks, drop it" | Demotes from warm to cold |
| "I made that mistake again even though we fixed it" | Penalty bounce → direct to hot |
| "Show me my hot rules" | Reads hot-rules.json |

---

## Advanced Mode (With automated feedback)

If you have an agent that reads your conversation logs (like a daily review agent), it can auto-update `hot-rules.json` by scanning for correction patterns:

```
Daily Review Agent (your own)
  → Extract corrections from conversation
  → Sort by recency and frequency
  → Update flywheel/hot-rules.json
  → Hot top 3 → inner ring auto-updates next session
```

The data format is just JSON. Any agent or script can write to it.

---

## Design Philosophy

### Why this is different from existing solutions

| Solution | Bypass-proof | Dynamic lifecycle | Token-efficient | Reuses existing data |
|:---------|:-----------:|:----------------:|:---------------:|:-------------------:|
| LangGraph __start__ node | ⭐⭐⭐⭐ | ❌ | ⭐⭐⭐ | ❌ |
| NeMo Guardrails Server | ⭐⭐⭐⭐⭐ | ❌ | ⭐⭐ | ❌ |
| Claude .cursorrules | ⭐⭐⭐ | ❌ | ⭐⭐⭐ | ❌ |
| **Dual-Ring Gate** | ⭐⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ | ✅ |

Two unique features no existing framework has:

1. **Two-layer enforcement** — shell (can't be skipped) + prompt (can't be deleted). Existing solutions only have one or the other.
2. **Dynamic rule lifecycle** — rules grow old and retire. Existing solutions are all static: once written, they stay forever.

### What Dual-Ring Gate is NOT

- ❌ Not a replacement for good debugging or systematic fixes
- ❌ Not a guarantee against new types of errors
- ❌ Not magic — if you never correct your agent, the hot layer won't know what to promote

It's an **execution guarantee layer** for your existing error-prevention system.

---

## Common Pitfalls

1. **Rules pile up forever** — Set `retire_after_days` aggressively. A rule that hasn't triggered in 30 days is noise, not safety net.
2. **Inner ring too long** — Keep it to 3 rules max. A 10-item checklist turns into white noise.
3. **Outer ring blocks everything** — Don't make every check a hard fail. WARN on non-critical; FAIL only on P0.
4. **Assuming hot rules stay hot** — Check `hot-rules.json` weekly. If nothing changes, your agent isn't learning new patterns.
5. **Interacting fixes but not updating rules** — This is the most common failure mode. Every fix must touch `hot-rules.json` or the error DB.
6. **Multiple agents writing to hot-rules simultaneously** — Use a lock file or sequential writes.
7. **Forgetting to verify after update** — Always check `hot-rules.json` after update: `wc -l` and `python -m json.tool`.

---

## Verification Checklist

After setup, verify with a fresh Hermes session:

- [ ] `terminal('date')` is called before any response
- [ ] Gateway status is checked on first response
- [ ] `hot-rules.json` exists and has valid JSON
- [ ] Inner ring instructions are visible in SOUL.md
- [ ] Outer ring script (if configured) runs without error
- [ ] A test correction ("I keep making mistake X") updates hot-rules
- [ ] Old rules auto-demote after configured cooldown period

---

## Files

| File | Purpose |
|:-----|:--------|
| `SKILL.md` | This file — install via `hermes skills install` |
| `templates/hot-rules.json` | Template for rule lifecycle file |
| `scripts/pre-session-check.sh` | Outer ring shell gate |
| `scripts/install.sh` | One-command setup script |

---

## License

MIT. Use freely, modify freely, contribute freely.
