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
Clipboard, Money, OpenWorker, util, mf, dotfiles, and bin.

A gradual project-location migration has started. The immediate rule is that
registry paths are authoritative and tooling must not assume that registered
projects share one Eclipse workspace or one parent directory. Existing paths
remain unchanged while scripts are made location-independent.

System now explicitly treats "project" broadly: software projects, Eclipse-only
software, Eclipse file-container projects used mainly for browsing files, and
non-Eclipse projects may all be registered. Missing Git, build files, source
code, or Eclipse metadata is not inherently an error. `check-project-paths.sh`
reports these characteristics observationally.

The intended longer-term layout keeps live project working trees on a normal
local drive, keeps Eclipse workspace metadata separate from project storage,
and uses OneDrive as a mirrored backup destination rather than as the live
development filesystem. Migration will happen one project at a time.

## Current direction

- Keep System thin and focused on cross-project facts and verification.
- Let dotmdfiles own shared Markdown sources and deployment.
- Let dotfiles own shell, terminal, and launcher implementation.
- Let bin own user-facing commands.
- Treat each project's registry path as its canonical location.
- Remove assumptions that all projects live under `~/eclipse-workspace`.
- Do not add build-system, IDE, category, or workspace columns until real
  migration work demonstrates that those distinctions are needed.
- Keep ChatMap's `.chatmap-local/` out of routine agent reading.
- Use lower camel case for custom shell variables and reserve established
  uppercase names for external conventions such as `HOME` and `PATH`.

## Next evidence to collect

- Exercise `check-project-paths.sh`, registry-driven project setup, and
  shared-file verification using the existing project locations.
- Move one low-risk project only after the relevant tooling works without a
  common-workspace assumption.
- Add OneDrive mirroring after the first moved project works normally from its
  new local location.
- Remove temporary `PROJECTS_FILE` compatibility after local callers migrate.
- Revisit database storage only if concurrent writes or query volume make the
  versioned text file inadequate.
