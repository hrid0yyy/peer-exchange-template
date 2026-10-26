---
name: peer-exchange
description: >-
  Asynchronous peer collaboration and communication loop between an Executor
  (OpenCode or Antigravity) and Claude (Planner/Reviewer) via a shared mailbox file (PEER_EXCHANGE.md).
  Use whenever collaborating with Claude, passing tasks, receiving reviews/critiques,
  or coordinating multi-turn agent handoffs.
metadata:
  opencode/slash: "true"
---

# Peer Exchange: Executor (OpenCode | Antigravity) <-> Claude Mailbox Protocol

This skill governs the bidirectional communication loop between the **Executor**
(**OpenCode (OC)** or **Antigravity (AGY)** — fully interchangeable) and **Claude (CC)**
using a single mailbox file (`PEER_EXCHANGE.md`).

---

## 1. Explicit Role Division
In this protocol, roles are strictly partitioned:
* **Claude (Planner & Reviewer):**
  - Plans architecture, strategies, milestones, and task checklists.
  - Reviews the Executor's completed work, code diffs, and test outputs.
  - Answers technical questions and resolves edge-case ambiguities.
  - Performs its own research, decision-making, and verification on critical matters; does not delegate these to the Executor.
  - **Does NOT execute or modify repository code directly.**
* **The Executor (OpenCode OR Antigravity):**
  - Implements the code, modules, tests, and configurations.
  - Runs test suites, builds, and validation scripts.
  - **Handles all Git version control**: stages changes and creates verified Git commits once tests pass.
  - Reports exact verification metrics, commit hashes, and files modified.
  - Requests reviews and planning directions from Claude.

**Executor identity:** whichever agent you are running as, *you are the Executor for that turn*.
Declare it in the mailbox frontmatter via `executor: OpenCode` (or `executor: Antigravity`).
Only one executor acts per turn; never write Section 1 and Section 3 in the same turn.

---

## 2. When to Activate This Skill
Activate this skill whenever:
* The user asks to "check mailbox", "check peer exchange", or "see what Claude said".
* The user asks to "send to Claude", "prepare update for Claude", or "hand off to Claude".
* Running an iterative loop where the Executor develops/tests code and Claude conducts peer reviews or plans milestones.

---

## 3. Core Protocol Rules

1. **Single File:** `PEER_EXCHANGE.md` at the project root is the only file used for communication. Each turn updates this file directly.
2. **Turn State Machine:**
   * `🟡 AWAITING_CLAUDE`: The Executor has dispatched its update. Claude needs to review/plan.
   * `🟢 AWAITING_EXECUTOR`: Claude has provided directives/review. The Executor must execute.
     * Legacy alias: `AWAITING_AGY` == `AWAITING_EXECUTOR` — accept and normalize both when parsing.
   * `⚙️ IN_PROGRESS`: The Executor is currently implementing tasks.
   * `✅ COMPLETE`: Current milestone or goal reached.
3. **Concise Reporting:**
   * Keep diffs and reports concise; reference committed file paths and commit hashes instead of dumping large code blocks into the file.
4. **Copy-Paste Prompt for the User:**
   * Whenever the Executor completes a dispatch and transitions state to `🟡 AWAITING_CLAUDE`, the Executor **MUST** provide a clean 1-click copyable prompt in chat that the user can immediately paste into Claude.

---

## 4. Step-by-Step Procedure

### Step 1: Read Mailbox and Verify State
* Read `PEER_EXCHANGE.md`.
* Parse the frontmatter:
  ```yaml
  turn: <number>
  status: <AWAITING_EXECUTOR | AWAITING_CLAUDE | IN_PROGRESS | COMPLETE>
  executor: <OpenCode | Antigravity>
  active_goal: <summary>
  ```
* If `status: AWAITING_CLAUDE`: Warn the user that Claude has not responded to the current turn yet, or ask if they have an updated message from Claude.
* If `status: AWAITING_EXECUTOR` (or `AWAITING_AGY`): Extract Claude's directives from **Section 3 (Claude's Review, Plan & Directives)**. Set status to `⚙️ IN_PROGRESS`.

### Step 2: Execute Directives, Validate & Commit
* Work through Claude's task checklist sequentially.
* Run relevant unit tests, builds, or validation commands to verify your work.
* Once tests pass, stage and commit the changes via Git.
* Record:
  - Exact files created or modified.
  - Git commit hash and commit message.
  - Test command results (pass count, failures, edge cases).

### Step 3: Write Outbound Dispatch to `PEER_EXCHANGE.md`
Update `PEER_EXCHANGE.md` with the new turn:
* Increment `turn` by 1.
* Set `status: AWAITING_CLAUDE`.
* Set `executor: OpenCode` (or `Antigravity`) and `last_updated_by` to the same identity.
* Populate the three canonical sections:
  1. **Section 1: Work Report (Executor)**: Summary of what was executed, commit hash, files touched, test verification results.
  2. **Section 2: Targeted Questions & Decisions Needed (Executor)**: Specific questions, design forks, or verification requests for Claude.
  3. **Section 3: Claude's Review, Plan & Directives (Claude)**: Blank template ready for Claude to fill out.

### Step 4: Deliver the 1-Click Prompt to User
In the chat response to the user:
* Summarize what was completed.
* Highlight any key question for Claude.
* Render the exact prompt the user should paste into Claude.

---

## 5. Standard Format for `PEER_EXCHANGE.md`

```markdown
---
turn: 1
status: AWAITING_CLAUDE
executor: OpenCode
active_goal: "<One-sentence summary of overall milestone>"
last_updated_by: OpenCode
timestamp: "<YYYY-MM-DD HH:MM>"
---

> **📋 Copy-Paste Prompt for Claude:**  
> *"Please inspect `PEER_EXCHANGE.md`. Review Section 1 & Section 2, fill out Section 3 with your critique, verdict, and numbered task list for the executor, and set `status: AWAITING_EXECUTOR` in the frontmatter."*

---

## Section 1: Work Report (Executor)
- **Commit**: `<hash> <commit message>`
- **Summary**: <What was completed>
- **Files Modified/Created**:
  - `path/to/file1` - <notes>
- **Verification & Tests**:
  - Command: `<command>` -> Result: `<pass/fail>`

## Section 2: Targeted Questions & Decisions Needed
1. <Specific question 1>
2. <Specific question 2>

---

## Section 3: Claude's Review, Plan & Directives (Planner & Reviewer)
<!-- Claude: Write your review, next plan, and actionable steps for the executor, then update status to AWAITING_EXECUTOR -->
*(Awaiting Claude's review)*
```

---

## 6. Executor Notes

### OpenCode
* The skill is discovered from `.agents/skills/peer-exchange/SKILL.md` (project) or `~/.config/opencode/skills/peer-exchange/SKILL.md` (global).
* `metadata.opencode/slash: "true"` exposes it as the `/peer-exchange` command in the TUI.
* Use the `edit`/`write` tools for the mailbox and `bash` for Git; never hand-edit frontmatter YAML with shell redirection.

### Antigravity
* The skill is discovered from `.agents/skills/peer-exchange/SKILL.md` the same way.
* Identical protocol — only the `executor:` value changes.
