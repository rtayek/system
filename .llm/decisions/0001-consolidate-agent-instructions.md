# ADR: Consolidate Agent Instructions into `AGENTS.md`

## Status

Accepted 2026-10-07

## Context

The current cross-project instruction model uses several Markdown files to describe agent behavior, user preferences, persona, discovery, and project context.

The deployed set has included:

* `CLAUDE.md`
* `AGENTS.md`
* `.llm/index.md`
* `.llm/human.md`
* `.llm/persona.md`

This structure has useful semantic separation, but reliable operation depends on an agent following a chain of references correctly.

Different LLM clients have different discovery behavior. Some automatically load `AGENTS.md`, some recognize `CLAUDE.md`, and some may not reliably follow additional references from those files.

As a result, important constraints can be missed even when the information exists in the repository.

The architecture should optimize first for reliable delivery of governing instructions. Semantic organization remains important, but it must not depend on every client implementing the same recursive document-discovery behavior.

The system also needs to distinguish between:

* governing agent instructions,
* repository-specific context,
* large project documents,
* historical handoffs,
* skills,
* machine-readable configuration,
* and executable automation.

These should remain separate according to their roles without requiring a fragile discovery chain.

## Decision

Each repository will use `AGENTS.md` as its primary self-contained governing document for agents.

`CLAUDE.md` will remain as a thin compatibility adapter for clients that discover it automatically. Its primary purpose is to direct Claude-compatible agents to `AGENTS.md`.

Critical governing instructions MUST NOT depend on an agent discovering `.llm/human.md`, `.llm/persona.md`, `.llm/index.md`, or another secondary Markdown file.

The important semantic content previously distributed among those files will be consolidated into clearly scoped sections of `AGENTS.md`.

The expected general structure is:

```markdown
# Agent Instructions

## Normative Language
## Authority and Conflict Resolution
## Permissions and Scope
## Human Constraints and Preferences
## Agent Persona
## Skills Policy

<!-- BEGIN PROJECT CONTEXT -->

## Project Requirements
## Project Document Map

<!-- END PROJECT CONTEXT -->
```

The portion outside the project-context markers is shared cross-project policy.

The portion inside the project-context markers is owned by the individual repository.

The `dotmdfiles` project will maintain the canonical shared content and the tooling used to deploy or synchronize it.

Synchronization tooling MUST preserve repository-owned project context when updating the shared portion.

### Normative language

Agent requirements will use BCP 14 terminology, based on RFC 2119 as updated by RFC 8174.

Uppercase terms such as `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, and `MAY` will be reserved for testable normative requirements.

Ordinary facts, explanations, rationale, and preferences should normally use ordinary declarative language.

### Document discovery

`AGENTS.md` will explicitly name additional project documents when they are required.

Broad instructions such as:

```text
Read all relevant Markdown files.
```

should be avoided.

Instead, requirements should identify exact documents and conditions, for example:

```markdown
Agents MUST read `.llm/design.md` before changing architecture.

Agents MUST NOT read `.llm/handoffs/` unless the current task requires
historical evidence.
```

Large project documents may remain under `.llm/`, but their existence does not imply that they should be loaded automatically.

Historical handoffs are evidence and continuity artifacts, not governing authority.

### Skills

Skills remain separate from `AGENTS.md`.

A skill represents a reusable capability, specialty, or workflow. Skills may contain instructions, scripts, references, and assets.

They should be loaded when selected or when their declared purpose clearly matches the current task.

A large skills library should remain searchable rather than being automatically exposed or loaded for every agent.

Project instruction consolidation does not imply skill consolidation.

### File-format boundaries

Markdown is used for human-readable policy, design, decisions, context, and handoffs.

YAML front matter may describe metadata about a Markdown document or skill.

JSON should be introduced when software actually requires a machine-readable manifest, schema, configuration, or state representation.

Shell scripts perform deterministic actions and automation. They are not the semantic authority for agent behavior.

## Consequences

### Positive

Agent behavior becomes less dependent on multi-step document discovery.

Critical rules become easier to inspect, test, compare, and deploy.

Cross-project behavior can remain standardized while still allowing repositories to own their local context.

Client-specific adapters remain small.

Project-specific documents can continue to exist without automatically consuming context-window capacity.

The relationship between policy, project context, skills, working state, and historical material becomes clearer.

The design becomes easier to validate mechanically because there is a single primary governing document.

### Negative

`AGENTS.md` will become larger than it is today.

Some semantic separation provided by `human.md`, `persona.md`, and `index.md` will move from file boundaries to section boundaries.

Synchronization becomes slightly more sophisticated because tooling must replace shared content while preserving repository-owned content.

Information that was previously centralized in separate source files may be duplicated conceptually inside the combined document unless maintenance discipline is maintained.

Client-specific conventions may continue to evolve, so compatibility adapters may need to change over time.

## Alternatives Considered

### Keep the existing multi-file discovery chain

Retain `AGENTS.md`, `human.md`, `persona.md`, `index.md`, and related files as separate authoritative documents.

Rejected because reliable behavior depends on every client recursively discovering and interpreting all of them correctly.

The structure is semantically clean but operationally fragile.

### Require agents to read every Markdown file in `.llm`

This simplifies discovery rules superficially.

Rejected because repositories may accumulate many design documents, handoffs, experiments, archives, and temporary files.

Automatic loading would increase noise and context consumption and could allow historical material to compete with current authority.

### Keep five identical standardized files across repositories

This provides easy synchronization but does not solve discovery reliability and makes repository-specific context awkward.

Rejected as the primary architecture.

Standardization remains useful for the shared portion of `AGENTS.md`.

### Use symlinks to canonical files

This would provide one physical source of truth.

Rejected as a cross-platform default because Windows symlink behavior and permissions add unnecessary operational complexity.

Ordinary files are preferred.

### Put skills directly into `AGENTS.md`

This would make capabilities immediately visible.

Rejected because skills can become numerous and task-specific.

Loading all skill instructions into every session would waste context and blur the distinction between governing policy and optional capability.

### Introduce a JSON manifest for document discovery

A machine-readable manifest could eventually make discovery deterministic.

Deferred because no current program requires or consumes such a manifest.

Machine-readable structure should be introduced when there is an actual consumer and validator rather than as speculative infrastructure.

## Ownership

The `system` repository owns this architectural decision.

The `dotmdfiles` repository owns the canonical shared `AGENTS.md` template and the synchronization mechanism that implements the decision.

Individual repositories own their project-context sections and their project-specific supporting documents.

## Validation

Acceptance followed the completed dotmdfiles and ChatMap pilots, passing marker
regression tests, migration of the registered repositories, verification of
ordinary tracked file modes, and workstation-wide checks of the synchronized
`CLAUDE.md` and `AGENTS.md` files. Critical governing instructions no longer
depend on secondary-file discovery.
