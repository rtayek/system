# The System

The System is a top-level coordination project for an experimental AI-native
working environment. It connects three related projects without replacing
their repositories, histories, or local responsibilities.

## Projects

| Project | Role |
| --- | --- |
| [ChatMap](https://github.com/rtayek/chatmap) | Extract, preserve, search, and maintain durable semantic knowledge from conversations. |
| [dotmdfiles](https://github.com/rtayek/dotmdfiles) | Study and develop conventions for Markdown files used by people and LLM tools. |
| [dotfiles](https://github.com/rtayek/dotfiles) | Maintain workstation configuration, shell behavior, and project-launching infrastructure. |

## Purpose

This repository provides a place to:

- maintain the shared direction across the three projects;
- record decisions and dependencies that cross repository boundaries;
- distinguish reusable system principles from project-specific experiments;
- provide a stable entry point for understanding how the projects fit together.

The System is a coordination and design layer. It is not a monorepo, a
replacement for the three projects, or an agent orchestrator.

## Current Direction

The current work is exploring a file protocol that helps an LLM enter a
project, find authoritative context, and avoid loading irrelevant material.

The main working ideas are:

- Standardize discovery, not internal organization.
- Let Git preserve chronology while Markdown preserves durable knowledge.
- Use file roles and authority rather than relying only on filenames.
- Use YAML headers for compact human- and LLM-readable state.
- Use JSON sidecars for machine-readable tracking and validation.
- Keep raw transcripts, generated output, and other high-volume material
  outside normal agent ingestion.

These ideas are being tested manually before adding substantial automation.
Only principles supported by experience in the individual projects should
become system-wide conventions.

## Project Boundaries

Each project owns its own implementation, documentation, working context,
tests, and history. Material may begin here while its proper home is being
determined, but project-specific decisions should ultimately remain with the
project they govern.

The current [ChatMap handoff](ChatMap-Core-Repository.md) describes the active
manual file-protocol experiment. Most of its operational details belong to
ChatMap. This repository is the place to evaluate which results should later
be shared with dotmdfiles, dotfiles, or the System as a whole.

## Status

The System is at an early design and experimentation stage. The immediate goal
is to learn from the ChatMap pilot, preserve useful cross-project decisions,
and avoid imposing a large framework before the workflow has been proven.
