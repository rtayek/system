# Project model

System uses **project** in a broad sense. A registered project is a named unit
of work or material that is useful to locate, open, inspect, launch, or manage
consistently. It is not defined by a particular language, build system, IDE, or
repository layout.

Examples include:

- software with a build system such as Gradle or Make;
- software managed mainly as an Eclipse project, with no external build;
- an Eclipse file-container project used primarily to browse and organize
  documents or other files, with little or no code;
- a non-Eclipse project such as shell tooling, documentation, or data work.

These descriptions are observational. A project is not defective because it
lacks Git, Gradle, source code, an Eclipse `.project` file, or another feature
that some other project has.

## Location

The `path` field in `projects.tsv` is the canonical working-tree or project
location for registered projects. Tools should use that path rather than infer
a location from the project name or from an Eclipse workspace.

Project storage and Eclipse workspace membership are separate concepts. Eclipse
may import a project in place from its canonical location. A project may appear
in one workspace, several workspaces, or no Eclipse workspace.

## Metadata

Do not add registry columns merely to describe distinctions that can already be
observed from a project. In particular, build system, IDE use, project kind,
workspace membership, and backup policy should become registry metadata only
when a concrete workflow requires them.

The current migration therefore keeps the existing registry schema and first
makes project-location consumers honor the existing `path` field.
