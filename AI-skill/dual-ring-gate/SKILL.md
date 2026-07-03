---
name: dual-ring-gate
description: "Use when your Hermes agent repeatedly skips self-checks despite documented rules. Dual-Ring Gate prevents 'remember-to-check' failures with two enforcement layers: a zero-token shell gate (outer ring) and a session-pinned prompt gate (inner ring), plus a hot/warm/cold rule lifecycle system. v1.1 adds per-response hot-rules loading, session mid-segment freshness, and correction→hot-rules auto-feedback."
version: 1.1.0
author: 知夏 & 皓麟
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [self-check, guardrails, reliability, self-evolution, meta]
    related_skills: [session-startup, zhixia-woodpecker]
---

# Dual-Ring Gate (双环门禁) v1.1.0

> **Stop your AI from "forgetting" to self-check — make it impossible to skip.**

The meta-vulnerability of AI agents: every self-check mechanism (memory rules, skills, checklists) depends on the agent *remembering to load and execute it*. But "remembering to load the self-check" has no self-check of its own.

Dual-Ring Gate closes this gap by moving self-checks from **"the AI decides to do them"** to **"the system forces them before the AI speaks"**.

**v1.1.0 improvements (from real-world ERR-019 5-recurrence case):**
- 🆕 Per-response hot-rules loading — AI reads `hot-rules.json` before every reply, not just at session start
- 🆕 Session mid-segment freshness — time data expires after 5 min or 3 tool calls, forcing re-check
- 🆕 Correction→hot-rules auto-feedback — every correction auto-updates hot-rules metadata
- 🆕 Inner ring with detection keywords — not "remember to check time", but "if you see these words → you MUST date"

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
│  Token cost: 0                                   │
│  Bypass-proof: ★★★★★ (infrastructure level)      │
├─────────────────────────────────────────────────┤
│              INNER RING · Prompt Gate            │
│  [system prompt] 3 pinned instructions           │
│  Always injected via SOUL.md / AGENTS.md         │
│  Token cost: ~50/turn                            │
│  Bypass-proof: ★★★☆ (AI can ignore, can't delete)│
├─────────────────────────────────────────────────┤
│    🆕 PER-RESPONSE · Hot-Rules Auto-Inject      │
│  [pre-response] read_file('hot-rules.json')      │
│  AI must load before every reply, not just       │
│  session start. Prevents mid-conversation drift. │
│  Token cost: ~20/turn (cached in context)        │
├─────────────────────────────────────────────────┤
│              HOT/WARM/COLD · Rule Lifecycle      │
│  Rules age, cool down, and retire automatically  │
│  Token cost: on-demand loading                   │
│  Feedback-driven dynamic adjustment              │
└─────────────────────────────────────────────────┘
```

### What's new in v1.1: the Per-Response layer

The original design assumed "load hot-rules once at session start = enough." Real-world ERR-019 recurrence showed this is **not enough** — after 15+ turns of conversation, the hot-rules are pushed out of context or the AI forgets them.

**The fix**: hot-rules.json must be read before EVERY response, not just at session start. This is enforced via the Inner Ring instruction: "before replying, read_file('hot-rules.json')".

---

## Quick Start (5 minutes)

### 1. Install the Skill

```bash
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md
```

Or copy `SKILL.md` to `~/.hermes/skills/knowledge/dual-ring-gate/`.

### 2. Inject Inner Ring into Your SOUL.md

Append to `~/.hermes/SOUL.md` (or `$HERMES_HOME/SOUL.md`):

```markdown
## 🔴 Dual-Ring Gate · Inner Ring (auto-injected · cannot skip)
- **⏰ Time check (ERR-019)**: If reply contains time words (now/already/not yet/today/yesterday/tomorrow/Monday/soon/immediately) → MUST terminal('date') first. If last date was >5 min ago or 3+ tool calls ago → must re-date. **NEVER read time from memory.**
- **Gateway check**: verify gateway status on first response of each session
- **Rule update**: every fix must also update the error rule database
```

**Why SOUL.md?** It's the one file Hermes always loads into every session, regardless of working directory or project. The instructions sit in the system prompt automatically — no forgetting, no skipping.

**🆕 Key improvement in v1.1**: The time check now includes **detection keywords** and **expiry rules** (5 min / 3 tool calls), from the ERR-019 5-recurrence case study.

### 3. Create Your Hot Rules (Manual Mode)

Create `$HERMES_HOME/flywheel/hot-rules.json`:

```json
{
  "updated": "YYYY-MM-DD",
  "hot": [
    {
      "rule": "If reply contains time words → MUST terminal('date') before responding",
      "reason": "Most frequent error — speaking without checking time",
      "err_ref": "ERR-019",
      "days_active": 1,
      "last_correction": "YYYY-MM-DD"
    },
    {
      "rule": "Read hot-rules.json before every response (not just session start)",
      "reason": "Mid-conversation drift after 15+ turns",
      "err_ref": "v1.1 per-response loading",
      "days_active": 1,
      "last_correction": "YYYY-MM-DD"
    },
    {
      "rule": "Update error DB after every fix",
      "reason": "Fixes without rule updates leave no trace",
      "err_ref": "ERR-024",
      "days_active": 1,
      "last_correction": "YYYY-MM-DD"
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

**🆕 Important**: `hot-rules.json` lives under `$HERMES_HOME/flywheel/` (NOT `~/.hermes/flywheel/`), matching Hermes's actual data directory layout.

### 4. (Optional) Set Up Outer Ring Shell Gate

Create `$HERMES_HOME/scripts/pre-session-check.sh`:

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

**Activation:** Add alias to `~/.bashrc` or `~/.zshrc`:

```bash
alias hermes='$HERMES_HOME/scripts/pre-session-check.sh && hermes'
```

**Alternative (Windows git-bash):** Add to `~/.bashrc`:
```bash
alias hermes='/c/Users/<user>/AppData/Local/hermes/scripts/pre-session-check.sh && hermes'
```

---

## Rule Lifecycle: Hot → Warm → Cold → Retire

Rules should not accumulate forever. They should age, cool down, and retire.

| Layer | Condition | Volume | Access |
|:------|:----------|:------:|:-------|
| 🔥 **Hot** | Corrected within last 3 days | 2-3 rules, ~50 tokens | Auto-loaded per-response (v1.1) |
| 🌤 **Warm** | Recurrence ≥2 or structural rules | ERR summary, ~500 tokens | Loaded on task-type match |
| ❄️ **Cold** | Archived >7 days no recurrence | Full rule DB, ~7-15K tokens | Manual lookup only |

### Automatic Lifecycle Rules

- **7 days no correction** → Hot → Warm (auto-demote)
- **30 days no correction** → Cold → Retire (can be archived)
- **Retired rule recurs** → Direct to Hot (penalty bounce — not Warm)

### 🆕 Per-Response Freshness Rule (v1.1)

| Data type | Expiry | Rule |
|:----------|:-------|:-----|
| ⏰ Time (date result) | 5 minutes OR 3+ tool calls | Must re-date before any time-sensitive reply |
| 🔧 Cron status | Per query | Never use cached last_run_at — cross-validate with agent.log |
| 📁 File state | Per query | Never say "file exists" from memory — ls/stat it |

**The contract**: "There is no cached time, cron, or file state in memory. Every judgment must use fresh tool output."

---

## 🆕 Interactive Mode — With Auto-Feedback Chain (v1.1)

If you don't have an automated correction-detection system, just tell your agent:

> "I keep making [mistake X]. Put it in hot rules."

The agent will update `hot-rules.json` automatically. But **v1.1 adds a critical step**: when the AI gets corrected, it must also **update `last_correction` and `days_active`** in hot-rules.json for the relevant rule. This ensures the lifecycle clock is accurate.

### Auto-Feedback Chain (🔴 Hard Constraint)

```
Correction happens
  ↓
AI acknowledges ("我跳步了，重新走")
  ↓
AI updates hot-rules.json:
  ├─ Find matching rule (or create new)
  ├─ Set last_correction = today
  ├─ Set days_active = 1 (resets the clock)
  └─ If rule didn't exist → add to hot layer
  ↓
AI updates ERR rule database (zhixia-woodpecker or equivalent)
  ↓
Next session → hot-rules with fresh metadata
```

**What happened without this (real case)**:
- ERR-019 recurred 5 times between 06-22 and 07-03
- hot-rules.json's `last_correction` for the date rule was still `07-01` (not updated after 4th and 5th recurrence)
- Result: lifecycle clock was broken — the rule looked "stable" when it wasn't

### Example Commands

| You say | Agent does |
|:--------|:-----------|
| "I keep forgetting to check time before speaking" | Adds/updates date rule in hot layer, sets last_correction=today |
| "That rule hasn't triggered in weeks, drop it" | Demotes from warm to cold |
| "I made that mistake again even though we fixed it" | Penalty bounce → direct to hot, days_active resets |
| "Show me my hot rules" | Reads hot-rules.json |
| "You said something wrong about time just now" | Updates hot-rules last_correction=today (recording the fresh miss) |

---

## Advanced Mode (With automated feedback)

If you have an agent that reads your conversation logs (like a daily review agent), it can auto-update `hot-rules.json` by scanning for correction patterns:

```
Daily Review Agent (your own)
  → Extract corrections from conversation
  → Sort by recency and frequency
  → Update flywheel/hot-rules.json
    → 🆕 Also update last_correction/days_active for existing rules
  → Hot top 3 → inner ring auto-updates next session
```

The data format is just JSONL/JSON. Any agent or script can write to it.

---

## Design Philosophy

### Why this is different from existing solutions

| Solution | Bypass-proof | Dynamic lifecycle | Token-efficient | Reuses existing data | Per-response freshness |
|:---------|:-----------:|:----------------:|:---------------:|:-------------------:|:---------------------:|
| LangGraph __start__ node | ⭐⭐⭐⭐ | ❌ | ⭐⭐⭐ | ❌ | ❌ |
| NeMo Guardrails Server | ⭐⭐⭐⭐⭐ | ❌ | ⭐⭐ | ❌ | ❌ |
| Claude .cursorrules | ⭐⭐⭐ | ❌ | ⭐⭐⭐ | ❌ | ❌ |
| **Dual-Ring Gate v1.0** | ⭐⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ | ✅ | ❌ |
| **Dual-Ring Gate v1.1** | ⭐⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐ | ✅ | ✅ |

Three unique features no existing framework has:

1. **Two-layer enforcement** — shell (can't be skipped) + prompt (can't be deleted). Existing solutions only have one or the other.
2. **🆕 Three-layer with per-response freshness** — adds hot-rules auto-inject before every reply. Closes mid-conversation drift.
3. **Dynamic rule lifecycle** — rules grow old and retire. Existing solutions are all static: once written, they stay forever.

### What Dual-Ring Gate is NOT

- ❌ Not a replacement for good debugging or systematic fixes
- ❌ Not a guarantee against new types of errors
- ❌ Not magic — if you never correct your agent, the hot layer won't know what to promote

It's an **execution guarantee layer** for your existing error-prevention system.

---

## 🆕 Real-World Case Study: ERR-019 5-Time Recurrence (v1.1 Motivation)

**Problem**: Between 06-22 and 07-03, the agent (知夏) made the same time-awareness mistake 5 times:
- Didn't `date` before answering time-sensitive questions
- Used 30-minute-old date data
- Said "next Monday" without checking cron schedule fields

**Root cause**: All fixes were rule-level (add to memory, update ERR rules). No mechanism prevented the AI from skipping the check in fast reasoning mode.

**What worked**:
1. SOUL.md inner ring with **specific detection keywords** (not "remember to check time" but "if you see these words → MUST date")
2. **hot-rules.json** with fresh metadata (last_correction updated on every recurrence)
3. Out-ring **shell gate** that forces date before session starts (AI cannot skip)

**What v1.1 added from this case**:
1. Per-response hot-rules loading (before every reply, not just session start)
2. Session freshness rules (5 min / 3 tool calls expiry)
3. Correction→hot-rules auto-feedback chain (every correction updates metadata)
4. Detailed detection keywords in inner ring

---

## Common Pitfalls

1. ⚠️ **Rules pile up forever** — Set `retire_after_days` aggressively. A rule that hasn't triggered in 30 days is noise, not safety net.
2. ⚠️ **Inner ring too long** — Keep it to 3-4 rules max. A 10-item checklist turns into white noise.
3. ⚠️ **Outer ring blocks everything** — Don't make every check a hard fail. WARN on non-critical; FAIL only on P0.
4. ⚠️ **Assuming hot rules stay hot** — Check `hot-rules.json` weekly. If nothing changes, your agent isn't learning new patterns.
5. ⚠️ **🔴 Correcting but not updating hot-rules (most common failure)** — Every correction must touch `hot-rules.json`. Without this, the lifecycle clock is broken — a rule looks "stable" when it has actually recurred. **This was the root cause of the ERR-019 5-recurrence case.**
6. ⚠️ **Multiple agents writing to hot-rules simultaneously** — Use a lock file or sequential writes.
7. ⚠️ **Forgetting to verify after update** — Always check `hot-rules.json` after update: `wc -l` and `python -m json.tool`.
8. ⚠️ **🆕 Mid-conversation drift** — AI loads hot-rules at session start, but after 15+ turns the rules are pushed out of context. v1.1 adds per-response loading to fix this.
9. ⚠️ **🆕 SOUL.md vs $HERMES_HOME path mismatch** — On Windows, `~/.hermes/` may not equal `$env:LOCALAPPDATA/hermes/`. Verify the actual SOUL.md path with `hermes config path`.

---

## 🆕 Verification Checklist (v1.1 updated)

After setup, verify with a fresh Hermes session:

- [ ] `terminal('date')` is called before any response
- [ ] Gateway status is checked on first response
- [ ] `hot-rules.json` exists at `$HERMES_HOME/flywheel/` and has valid JSON
- [ ] Inner ring instructions are visible in SOUL.md
- [ ] Inner ring includes **detection keywords** (not just "check time")
- [ ] 🆕 Per-response behavior: AI reads hot-rules.json before each reply (not just at session start)
- [ ] Outer ring script (if configured) runs without error
- [ ] 🆕 A test correction ("I keep making mistake X") updates hot-rules — including `last_correction` and `days_active`
- [ ] 🆕 After the correction, hot-rules.json shows the updated date
- [ ] Old rules auto-demote after configured cooldown period
- [ ] 🆕 Session mid-segment: after 5+ minutes of conversation, AI still checks time before time-sensitive replies

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
