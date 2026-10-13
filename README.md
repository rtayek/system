# The System

The System is the umbrella repository for Ray's related projects. It owns the
small amount of information that genuinely crosses project boundaries while
leaving implementation and history in the repositories that do the work.

## Projects

| Project | Role |
| --- | --- |
| [ChatMap](https://github.com/rtayek/chatmap) | Preserve, search, and maintain durable knowledge from conversations. |
| [dotmdfiles](https://github.com/rtayek/dotmdfiles) | Develop and deploy shared Markdown conventions for people and agents. |
| [five-rules](https://github.com/rtayek/five-rules) | Study deterministic N-dimensional agent simulations. |
| [System](https://github.com/rtayek/system) | Own cross-project facts, registry data, verification, and decisions. |
| [Clipboard](https://github.com/rtayek/clipboard) | Provide a Java desktop clipboard manager. |
| [Money](https://github.com/rtayek/money) | Analyze personal transaction data and spending reports. |
| [OpenWorker](https://github.com/rtayek/openworker) | Preserve bounded OpenWorker experiments and evidence. |
| [util](https://github.com/rtayek/utilities) | Provide reusable Java utility code. |
| [mf](https://github.com/rtayek/mf) | Parse and edit SGF game trees and develop a responsive Go user interface. |
| [dotfiles](https://github.com/rtayek/dotfiles) | Maintain workstation, shell, terminal, and project-launcher configuration. |
| [bin](https://github.com/rtayek/bin) | Provide user-facing commands that connect the other projects. |

This table mirrors the current `projects.tsv` registry. Experiments may join
the umbrella without becoming core System components.

## Ownership

System owns:

- the cross-project registry in `projects.tsv`;
- deployment and consistency checks for that registry;
- cross-project architecture, decisions, and verification.

System does not own:

- ChatMap's Java implementation or local runtime data;
- dotmdfiles templates and their two-file `CLAUDE.md` and `AGENTS.md`
  deployment;
- dotfiles shell, terminal, and launcher implementation;
- bin's user-facing commands.

This is an umbrella repository, not a monorepo or an agent orchestrator.

## Project registry

`projects.tsv` is the committed source of truth. It uses real tab characters
and this six-column header:

```text
name    path    port    color    chatgpt-url    claude-url
```

The `path` field is authoritative for the project's working-tree location.
Consumers should not infer a project path from its name, Eclipse workspace, or
the location of another project. Current entries may still live under
`~/eclipse-workspace`; that is existing data, not a required layout.

Deploy the registry as an ordinary file:

```sh
sh deploy-projects.sh
```

The default destination is `~/.config/ray/projects.tsv`. Override it with the
custom lower-camel environment variable `projectsFile`. The older
`PROJECTS_FILE` spelling remains temporarily accepted during migration.

Validate the committed file and confirm that the deployed copy is current:

```sh
sh check-projects.sh
```

The registry is deliberately a versioned text file rather than a database. It
is small, reviewable, portable, and shared by commands in dotmdfiles, dotfiles,
and bin.

## Project-location migration

Project storage and Eclipse workspace membership are separate concerns. A
project may use Gradle, Make, Eclipse only, another build system, or no build
system at all. Eclipse workspaces are views over selected projects rather than
the canonical homes of those projects.

The migration is intentionally incremental:

1. Make registry consumers honor each project's explicit path.
2. Keep all existing project locations working.
3. Create a new local project hierarchy and separate Eclipse workspace
   directories only after the tooling is location-independent.
4. Move one low-risk project and verify Git, Eclipse, direnv, project-home, and
   shared instruction synchronization.
5. Add OneDrive mirroring as a backup layer after local operation is proven.
6. Move remaining projects gradually.

No additional registry columns are required yet. Build-system, IDE, category,
or workspace metadata should be added only when migration work demonstrates a
concrete need.

## Current direction

ChatMap remains the manual pilot for the dotmdfiles layout. System should adopt
only cross-project conventions supported by experience in the individual
projects. Routine agent work must keep `.chatmap-local/` outside normal reading
and indexing.
