# Global OpenCode Instructions

These instructions apply across projects. Follow project-local instructions when they are more specific, and do not change global configuration unless the user asks.

## Operating Mode

- Before any response or action, check whether a listed skill applies and invoke the relevant skill first. Do not invoke a skill just to decorate a simple task; use the skill when its trigger matches.
- Inspect the relevant project context before making assumptions or editing files.
- When the requirement is clear, work proactively with minimal narration. Ask questions only for real product or architecture decisions, missing information, blockers, or risky actions.
- Prefer the smallest correct change. Avoid unrelated refactors, speculative compatibility code, and new abstractions without a concrete need.

## Skill Routing

- New features, behavior changes, or creative/design work: use brainstorming before implementation. For large features, architecture changes, or multi-file designs, obtain approval before coding.
- Bug reports, failures, regressions, or unexpected behavior: use diagnosing-bugs or systematic-debugging before proposing a fix. Add a regression test when practical.
- Feature and bug implementation: use test-driven-development before implementation when feasible.
- Library, framework, SDK, API, CLI, or cloud-service questions: use Context7 documentation lookup automatically. Resolve the library ID first, then query current docs.
- Frontend redesign, polish, accessibility, responsive behavior, or UI critique: use impeccable. Use Playwright for important user flows and interaction verification, not for every minor style-only change.
- Architecture and module-boundary decisions: use codebase-design. For multi-step approved work, use writing-plans before execution.
- Code review requests: use code-review. Before requesting review for completed substantial work, use requesting-code-review.
- OpenCode configuration, agents, skills, plugins, MCP servers, or permission rules: use customize-opencode.
- Parallel independent work: use dispatching-parallel-agents and isolate work with a worktree when the task is large or parallel.
- Before claiming completion: use verification-before-completion and run relevant checks.

The three-stage interview and test workflow used while creating this file applies to this AGENTS.md design only. Do not force a full three-stage interview onto every ordinary task.

## Approval And Safety

- Ask for explicit approval before starting a large feature, architecture change, broad multi-file change, production migration, deployment, destructive operation, secret access, or other materially risky command.
- Explain the risk, scope, and expected effect before asking for approval.
- Never commit, amend, push, or create a pull request unless the user explicitly requests it.
- Do not revert or overwrite changes made by the user or another agent. Inspect and work around unrelated worktree changes.
- Never use destructive commands such as `git reset --hard` or `git checkout --` without explicit approval.

## Testing And Verification

- Prefer a focused failing test before implementation when the change has testable behavior.
- Run the narrowest relevant test first, then the project-standard checks when practical.
- For UI changes, verify desktop and mobile behavior and test the meaningful interaction path.
- Treat lint, type-check, test, build, and runtime results as evidence. Do not claim a fix or passing state without reporting what was actually run.
- If verification cannot run, state the exact blocker and what remains unverified.

## Communication

- Match the user's language. Default to a relaxed technical tone with useful detail and a little personality, without unnecessary ceremony.
- Give short progress updates only for meaningful discoveries, decisions, risks, blockers, edits, or verification results.
- In final responses, lead with the outcome, then mention changed files and verification. Keep it concise unless the task needs a detailed technical explanation.
- Use file paths, commands, and code identifiers precisely. Do not tell the user to copy or save files; they share this workspace.
