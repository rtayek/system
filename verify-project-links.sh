#!/bin/sh

# Verify the shared governing files in the System umbrella workspace.

set -u

script_version=1
projectsFile=${projectsFile:-${PROJECTS_FILE:-"$HOME/.config/ray/projects.tsv"}}

usage() {
    printf 'Usage: %s [workspace [project ...]]\n' "${0##*/}"
    printf '\n'
    printf 'With no arguments, the workspace is the parent of this script.\n'
    printf 'With no project arguments, paths are read from: %s\n' "$projectsFile"
    printf '\n'
    printf 'Examples:\n'
    printf '  %s\n' "${0##*/}"
    printf '  %s /c/Users/ray/eclipse-workspace\n' "${0##*/}"
    printf '  %s /c/Users/ray/eclipse-workspace system chatmap dotmdfiles\n' "${0##*/}"
}

case ${1-} in
    -h|--help)
        usage
        exit 0
        ;;
    --version)
        printf '%s version %s\n' "${0##*/}" "$script_version"
        exit 0
        ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd -P) || {
    printf 'Error: cannot determine the script directory.\n' >&2
    exit 2
}

workspace=${1-$(dirname -- "$script_dir")}
if [ "$#" -gt 0 ]; then
    shift
fi

if [ ! -d "$workspace" ]; then
    printf 'Error: not a directory: %s\n' "$workspace" >&2
    exit 2
fi

workspace=$(CDPATH= cd -- "$workspace" 2>/dev/null && pwd -P) || {
    printf 'Error: cannot access workspace: %s\n' "$workspace" >&2
    exit 2
}

if [ "$#" -eq 0 ]; then
    if [ ! -f "$projectsFile" ]; then
        printf 'Error: project registry not found: %s\n' "$projectsFile" >&2
        exit 2
    fi
    tab=$(printf '\t')
    defaultProjects=$(awk -F "$tab" 'NR > 1 { print $2 }' "$projectsFile")
    if [ -z "$defaultProjects" ]; then
        printf 'Error: project registry has no projects: %s\n' "$projectsFile" >&2
        exit 2
    fi
    set -- $defaultProjects
fi

canonicalDir=$workspace/dotmdfiles/real
syncScript=$workspace/dotmdfiles/bin/sync-project-files.sh
if [ ! -d "$canonicalDir" ]; then
    printf 'Error: Canonical directory not found: %s\n' "$canonicalDir" >&2
    exit 2
fi

if [ ! -d "$workspace/dotmdfiles/.git" ] && [ ! -f "$workspace/dotmdfiles/.git" ]; then
    printf 'Error: dotmdfiles project is not a Git working tree: %s\n' "$workspace/dotmdfiles" >&2
    exit 2
fi

for sharedPath in AGENTS.md CLAUDE.md; do
    if [ ! -f "$canonicalDir/$sharedPath" ]; then
        printf 'Error: canonical file is missing: %s\n' "$canonicalDir/$sharedPath" >&2
        exit 2
    fi
done

if [ ! -f "$syncScript" ]; then
    printf 'Error: synchronization checker is missing: %s\n' "$syncScript" >&2
    exit 2
fi

failures=0
checked=0

printf 'Canonical dir: %s\n' "$canonicalDir"
printf 'Workspace: %s\n' "$workspace"

for project_name do
    case $project_name in
        "~"/*) project_dir=$HOME/${project_name#"~/"} ;;
        /*|[A-Za-z]:*) project_dir=$project_name ;;
        *) project_dir=$workspace/$project_name ;;
    esac

    printf '%s\n' '------------------------------------------------------------'
    printf 'Project: %s\n' "$project_dir"

    if [ ! -d "$project_dir" ]; then
        printf 'WARN: project directory is absent; skipped\n'
        continue
    fi

    if [ ! -d "$project_dir/.git" ] && [ ! -f "$project_dir/.git" ]; then
        printf 'FAIL: not a Git working tree\n'
        failures=$((failures + 1))
        continue
    fi

    checked=$((checked + 1))

    if sh "$syncScript" --check "$project_dir"; then
        printf 'OK:   shared governing content matches canonical sources\n'
    else
        printf 'FAIL: shared governing content differs or is invalid\n'
        failures=$((failures + 1))
    fi

    for relativePath in AGENTS.md CLAUDE.md; do
        trackedMode=$(git -C "$project_dir" ls-files -s -- "$relativePath" |
            awk 'NR == 1 { print $1 }')
        case $trackedMode in
            100644|100755)
                printf 'OK:   %s is tracked as an ordinary file\n' "$relativePath"
                ;;
            '')
                printf 'FAIL: %s is not tracked\n' "$relativePath"
                failures=$((failures + 1))
                ;;
            *)
                printf 'FAIL: %s has tracked mode %s; expected an ordinary file\n' \
                    "$relativePath" "$trackedMode"
                failures=$((failures + 1))
                ;;
        esac
    done
done

printf '%s\n' '------------------------------------------------------------'
if [ "$checked" -eq 0 ]; then
    printf 'FAIL: no projects were checked\n'
    exit 1
fi

if [ "$failures" -eq 0 ]; then
    printf 'PASS: %s project(s) checked; all shared files are consistent.\n' "$checked"
    exit 0
fi

printf 'FAIL: %s problem(s) found in %s checked project(s).\n' "$failures" "$checked"
exit 1
