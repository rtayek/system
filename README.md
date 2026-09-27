# The System

The System is the umbrella repository for Ray's related projects. It owns the
small amount of information that genuinely crosses project boundaries while
leaving implementation and history in the repositories that do the work.

## Projects

| Project | Role |
| --- | --- |
| [ChatMap](https://github.com/rtayek/chatmap) | Preserve, search, and maintain durable knowledge from conversations. |
| [dotmdfiles](https://github.com/rtayek/dotmdfiles) | Develop and deploy shared Markdown conventions for people and agents. |
| [dotfiles](https://github.com/rtayek/dotfiles) | Maintain workstation, shell, terminal, and project-launcher configuration. |
| [bin](https://github.com/rtayek/bin) | Provide user-facing commands that connect the other projects. |

Other experiments may join the umbrella without becoming System components.

## Ownership

System owns:

- the cross-project registry in `projects.tsv`;
- deployment and consistency checks for that registry;
- cross-project architecture, decisions, and verification.

System does not own:

- ChatMap's Java implementation or local runtime data;
- dotmdfiles templates and their five-file deployment;
- dotfiles shell, terminal, and launcher implementation;
- bin's user-facing commands.

This is an umbrella repository, not a monorepo or an agent orchestrator.

## Project registry

`projects.tsv` is the committed source of truth. It uses real tab characters
and this six-column header:

```text
name    path    port    color    chatgpt-url    claude-url
```

Deploy it as an ordinary file:

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

## Current direction

ChatMap remains the manual pilot for the dotmdfiles layout. System should adopt
only cross-project conventions supported by experience in the individual
projects. Routine agent work must keep `.chatmap-local/` outside normal reading
and indexing.
