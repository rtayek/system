# Project location audit

This audit classifies known `eclipse-workspace` references that matter to the
location migration. It is intentionally about active assumptions, not every
historical occurrence of the string.

## Live assumptions being removed on `migration/project-locations`

- System `verify-project-links.sh`: previously derived projects and
  dotmdfiles from one common workspace. The branch version resolves them from
  the registry.
- bin `new-project.sh`: previously hardcoded System and dotmdfiles locations
  and could ignore the registered path for an existing project. The branch
  version resolves dependencies and existing projects from the registry.
- bin `sync-handoffs.sh`: previously hardcoded several project checkout
  paths. The branch version resolves named destinations from the registry.
- bin `sort-handoffs.sh` and `status.sh`: the branch versions enumerate
  registered locations rather than a fixed workspace.
- dotfiles `publish-utilities/build.gradle` and its validation script:
  previously hardcoded the util checkout. The branch versions resolve util
  from the registry.
- dotmdfiles `bin/project-paths.sh`: the branch version treats
  `projectsRoot` only as compatibility for legacy relative registry paths.

## Valid defaults or examples

These do not require immediate removal because they describe a default rather
than impose a canonical location:

- the default root for newly created projects;
- examples in project-creation or Eclipse helper usage;
- a default Eclipse workspace accepted by scripts whose purpose is explicitly
  to inspect one workspace.

The new-project default is being made configurable while remaining
`~/eclipse-workspace` for compatibility.

## Already registry-driven

- dotfiles `bin/frequent-project-status.sh`;
- dotfiles `bin/launch-webterms.sh`;
- dotfiles `bin/update-project-homes.sh`.

These already read project paths from the deployed registry.

## Historical or machine-state evidence

Do not rewrite these merely to eliminate old path strings:

- historical handoffs;
- generated task reports;
- Eclipse preference exports;
- old machine-specific comparison files.

They describe prior state rather than define current project-location policy.

## Special-purpose items to revisit only when used

- `find_bugatti_files.sh`;
- `new-gradle-eclipse-project.sh`;
- `find-external-eclipse-projects.sh`;
- `launch-bash-boxes.sh`.

Some contain examples or old defaults. They should be changed when their
current role is established, rather than folded blindly into this migration.
