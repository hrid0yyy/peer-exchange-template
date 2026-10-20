---
name: peer-exchange
description: >-
  Asynchronous peer collaboration and communication loop between Antigravity and Claude via a shared mailbox file (PEER_EXCHANGE.md).
  Use whenever collaborating with Claude, passing tasks, receiving reviews/critiques, or coordinating multi-turn agent handoffs.
---

# Peer Exchange: Antigravity <-> Claude Mailbox Protocol

This skill governs the bidirectional communication loop between **Antigravity (AGY)** and **Claude (CC)** using a single mailbox file (`PEER_EXCHANGE.md`).

---

## 1. Explicit Role Division
In this protocol, roles are strictly partitioned:
* **Claude (Planner & Reviewer):** 
  - Plans architecture, strategies, milestones, and task checklists.
  - Reviews Antigravity's completed work, code diffs, and test outputs.
  - Answers technical questions and resolves edge-case ambiguities.
  - **Does NOT execute or modify repository code directly.**
* **Antigravity (Sole Executor & Builder):** 
  - Implements the code, modules, tests, and configurations.
  - Runs test suites, builds, and validation scripts.
  - **Handles all Git version control**: stages changes and creates verified Git commits once tests pass.
  - Reports exact verification metrics, commit hashes, and files modified.
  - Requests reviews and planning directions from Claude.

---

## 2. When to Activate This Skill
Activate this skill whenever:
* The user asks to "check mailbox", "check peer exchange", or "see what Claude said".
* The user asks to "send to Claude", "prepare update for Claude", or "hand off to Claude".
* Running an iterative loop where AGY develops/tests code and Claude conducts peer reviews or plans milestones.

---

## 3. Core Protocol Rules

1. **Single File:** `PEER_EXCHANGE.md` at the project root is the only file used for communication. Each turn updates this file directly.
2. **Turn State Machine:**
   * `🟡 AWAITING_CLAUDE`: Antigravity has dispatched its update. Claude needs to review/plan.
   * `🟢 AWAITING_AGY`: Claude has provided directives/review. Antigravity must execute.
   * `⚙️ IN_PROGRESS`: Antigravity is currently implementing tasks.
   * `✅ COMPLETE`: Current milestone or goal reached.
3. **Concise Reporting:**
   * Keep diffs and reports concise; reference committed file paths and commit hashes instead of dumping large code blocks into the file.
4. **Copy-Paste Prompt for the User:**
   * Whenever AGY completes a dispatch and transitions state to `🟡 AWAITING_CLAUDE`, AGY **MUST** provide a clean 1-click copyable prompt in chat that the user can immediately paste into Claude.

---

## 4. Step-by-Step Procedure

### Step 1: Read Mailbox and Verify State
* Read `PEER_EXCHANGE.md`.
* Parse the frontmatter:
  ```yaml
  turn: <number>
  status: <AWAITING_AGY | AWAITING_CLAUDE | ...>
  active_goal: <summary>
  ```
* If `status: AWAITING_CLAUDE`: Warn the user that Claude has not responded to the current turn yet, or ask if they have an updated message from Claude.
* If `status: AWAITING_AGY`: Extract Claude's directives from **Section 3 (Claude's Review, Plan & Directives)**. Set status to `⚙️ IN_PROGRESS`.

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
* Set `last_updated_by: Antigravity`.
* Populate the three canonical sections:
  1. **Section 1: Work Report (Antigravity)**: Summary of what was executed, commit hash, files touched, test verification results.
  2. **Section 2: Targeted Questions & Decisions Needed (Antigravity)**: Specific questions, design forks, or verification requests for Claude.
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
active_goal: "<One-sentence summary of overall milestone>"
last_updated_by: Antigravity
timestamp: "<YYYY-MM-DD HH:MM>"
---

> **📋 Copy-Paste Prompt for Claude:**  
> *"Please inspect `PEER_EXCHANGE.md`. Review Section 1 & Section 2, fill out Section 3 with your critique, verdict, and numbered task list for Antigravity, and set `status: AWAITING_AGY` in the frontmatter."*

---

## Section 1: Work Report (Antigravity - Executor)
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
<!-- Claude: Write your review, next plan, and actionable steps for AGY, then update status to AWAITING_AGY -->
*(Awaiting Claude's review)*
```
