---
id: SYS-CTX-01
lifecycle: working
status: active
provenance: cross-project-registry-migration
---
# Working Context

## Current state

System is the umbrella over ChatMap, dotmdfiles, dotfiles, bin, and related
experiments. Each project keeps its own implementation and history.

System owns the authoritative cross-project registry, `projects.tsv`. The file
is deployed as an ordinary copy to `~/.config/ray/projects.tsv`; consumers do
not depend on the System checkout at runtime.

The consolidated instruction migration is complete. Registered projects use a
thin `CLAUDE.md` adapter and a self-contained `AGENTS.md`; dotmdfiles owns their
shared content and synchronization. Secondary `.llm` documents are loaded only
when a project's `AGENTS.md` names them for the current task.

The registry currently includes ChatMap, dotmdfiles, five-rules, System,
Clipboard, Money, OpenWorker, util, dotfiles, and bin.

## Current direction

- Keep System thin and focused on cross-project facts and verification.
- Let dotmdfiles own shared Markdown sources and deployment.
- Let dotfiles own shell, terminal, and launcher implementation.
- Let bin own user-facing commands.
- Keep ChatMap's `.chatmap-local/` out of routine agent reading.
- Use lower camel case for custom shell variables and reserve established
  uppercase names for external conventions such as `HOME` and `PATH`.

## Next evidence to collect

- Exercise the TSV registry through normal project launch and setup work.
- Remove temporary `PROJECTS_FILE` compatibility after local callers migrate.
- Revisit database storage only if concurrent writes or query volume make the
  versioned text file inadequate.
