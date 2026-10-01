---
id: SYS-HANDOFF-2026-10-01-01
lifecycle: working
status: active
provenance: chat-handoff
---

# Handoff: Cross-project documentation cleanup

## Purpose

Continue the documentation cleanup across System, dotmdfiles, dotfiles, and
ChatMap after the shared agent-instruction migration.

## Adopted governing model

The implemented instruction entry path is:

```text
CLAUDE.md -> AGENTS.md
```

`AGENTS.md` is self-contained. It contains shared governing instructions and a
repository-owned project-context block delimited by:

```text
<!-- BEGIN PROJECT CONTEXT -->
<!-- END PROJECT CONTEXT -->
```

Dotmdfiles synchronization replaces the shared portions while preserving the
project-context block. `human.md` and `persona.md` were consolidated into
`AGENTS.md` and retired as active discovery files.

Synchronization manages only `CLAUDE.md` and `AGENTS.md`. Marker regression
tests pass for valid, missing, duplicate, and reversed markers. The shared-file
check passed for dotmdfiles, dotfiles, ChatMap, and System.

## Optional index.md

An individual repository may use `.llm/index.md` as a project-owned catalog of
deeper knowledge. It is not governing authority and is not part of automatic
instruction discovery. It must not contain critical instructions or cause
recursive loading of `.llm/`.

Current working preference: do not add a general reference to `index.md` in
the shared `AGENTS.md`. When an index is useful for a task, the user or the
repository's project context can explicitly direct the agent to read it.

## Current ownership boundaries

- System owns the cross-project registry, cross-project architecture, ADRs,
  and verification.
- dotmdfiles owns the canonical shared Markdown templates and synchronization.
- dotfiles owns shell, terminal, launcher, and workstation configuration.
- bin owns user-facing commands.
- ChatMap owns its application design, durable continuity model, and project
  documentation.

System's committed registry is `projects.tsv`; its deployed runtime copy is
`~/.config/ray/projects.tsv`.

## Documentation drift to correct

### ChatMap

`.llm/working-context.md` still says the consolidated instructions are not
implemented, transitional `index.md`, `human.md`, and `persona.md` remain, and
ChatMap must wait for dotmdfiles. Those statements are obsolete.

`.llm/design.md` also describes `index.md` as transitional even though the
migration is complete. The manifest correctly names `AGENTS.md` as the
entrypoint.

Update the working context and design to record the completed migration. Keep
the existing semantic-extraction refinement as a candidate next application
step; the bounded instruction-and-skill provenance experiment is now unblocked.

### dotfiles

`README.md` still describes:

```text
CLAUDE.md -> AGENTS.md -> .llm/index.md
```

Replace that section with the two-file governing model.

The README also says Eclipse metadata is not globally ignored. The actual
global ignore file now contains `.project`, `.classpath`, and `.settings/`.

### System

`README.md` still refers to dotmdfiles' five-file deployment. It now deploys
two shared root files.

The project table omits several registered projects, including five-rules,
clipboard, money, openworker, and util. Either list all registered projects or
label the table as the central/core projects.

The consolidation ADR at
`.llm/decisions/0001-consolidate-agent-instructions.md` remains `Proposed`.
The dotmdfiles and ChatMap pilots and marker tests are complete. After a final
workstation-wide synchronization check, consider changing it to `Accepted`.

`ChatMap-Core-Repository.md` describes the obsolete index-based discovery
chain, ASCII-only encoding, and an old manifest name. Move it to historical
material or label it superseded.

Update `.llm/working-context.md` to record the completed instruction migration
and current registry state, including util.

### dotmdfiles

The README and current `AGENTS.md` describe the implemented model correctly.

`.llm/project-context.md` is a legacy pilot source and now contains stale
claims. Retire it after confirming its remaining durable content is already in
the root `AGENTS.md` project section.

The September 27 consolidation handoff says implementation had not started;
retain it as historical evidence but mark it superseded if its metadata remains
active.

`language-in-md-files.md` reflects an older proposal that treated skills mainly
as YAML/JSON contracts. The adopted model uses `SKILL.md` packages with
optional scripts, references, and assets. Revise or label the older document
as exploratory.

## Cleanup order

1. Read each repository's current `AGENTS.md` before editing it.
2. Update ChatMap's working context and design.
3. Correct the dotfiles README.
4. Update the System README and working context.
5. Run the workstation-wide shared-file and registry checks.
6. Decide whether the System ADR is ready for `Accepted` status.
7. Retire or label the obsolete System and dotmdfiles documents.
8. Preserve historical handoffs as evidence; do not rewrite them merely to
   match current architecture.

## Verification commands

From dotmdfiles:

```sh
sh bin/sync-project-files-test.sh
sh bin/sync-project-files.sh --check
```

From System:

```sh
sh check-projects.sh
sh verify-project-links.sh
```

Then inspect all registered repositories:

```sh
frequent-project-status.sh
```

## New-chat opening prompt

> Continue from System's
> `.llm/handoffs/2026-10-01-cross-project-documentation-cleanup-handoff.md`.
> Read the applicable `AGENTS.md` files first, verify the current repository
> state, and complete the cross-project documentation cleanup. Preserve
> historical handoffs as historical evidence.
