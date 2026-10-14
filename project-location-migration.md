# Project location migration checklist

Use this checklist when moving one registered project. The migration is meant
to be incremental; projects that have not moved continue to use their existing
paths.

1. Confirm the project is in `projects.tsv` and note its current canonical
   path.
2. Ensure the working tree or project directory is in a recoverable state.
3. Move or copy the project to the intended new local location.
4. Update only that project's `path` in `projects.tsv`.
5. Run `check-projects.sh --source-only`.
6. Deploy the registry with `deploy-projects.sh`.
7. Run `check-project-paths.sh` and confirm the project resolves at the new
   path.
8. If it is an Eclipse project, import or relink it in place. Do not copy the
   project into the Eclipse workspace unless that is explicitly desired.
9. Verify the features that actually apply to that project, such as Git,
   direnv, project-home, launcher/webterm behavior, shared agent files, build,
   or Eclipse browsing.
10. Remove the old project directory only after the new location has been used
    successfully and any needed recovery copy is secure.

A file-container Eclipse project may legitimately have no Git repository, build
system, source code, `.envrc`, or project-home page. Verification should match
the project's actual role rather than impose software-project requirements.

OneDrive backup is a separate layer. The live project location should be proven
first; mirroring can be added afterward.
