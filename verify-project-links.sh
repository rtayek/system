#!/bin/sh

# Verify the shared LLM discovery files in the System umbrella workspace.

set -u

script_version=1
default_projects='system chatmap dotmdfiles dotfiles bin'
shared_paths='AGENTS.md .llm/human.md .llm/persona.md'

usage() {
    printf 'Usage: %s [workspace [project ...]]\n' "${0##*/}"
    printf '\n'
    printf 'With no arguments, the workspace is the parent of this script and\n'
    printf 'the default projects are: %s\n' "$default_projects"
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
    # Project names contain no whitespace.
    set -- $default_projects
fi

resolve_path() {
    if command -v realpath >/dev/null 2>&1; then
        realpath "$1" 2>/dev/null
    elif command -v readlink >/dev/null 2>&1; then
        readlink -f "$1" 2>/dev/null
    else
        return 1
    fi
}

system_dir=$workspace/system
if [ ! -d "$system_dir" ]; then
    printf 'Error: System project not found: %s\n' "$system_dir" >&2
    exit 2
fi

if [ ! -d "$system_dir/.git" ] && [ ! -f "$system_dir/.git" ]; then
    printf 'Error: System project is not a Git working tree: %s\n' "$system_dir" >&2
    exit 2
fi

for relative_path in $shared_paths; do
    canonical_path=$system_dir/$relative_path
    if [ ! -e "$canonical_path" ]; then
        printf 'Error: canonical file is missing or broken: %s\n' "$canonical_path" >&2
        exit 2
    fi
    if ! resolve_path "$canonical_path" >/dev/null; then
        printf 'Error: realpath or readlink -f is required.\n' >&2
        exit 2
    fi
done

failures=0
checked=0

printf 'System project: %s\n' "$system_dir"
printf 'Workspace: %s\n' "$workspace"

for project_name do
    project_dir=$workspace/$project_name

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

    if [ -r "$project_dir/CLAUDE.md" ] && grep -F 'AGENTS.md' "$project_dir/CLAUDE.md" >/dev/null 2>&1; then
        printf 'OK:   CLAUDE.md routes to AGENTS.md\n'
    else
        printf 'FAIL: CLAUDE.md is missing, unreadable, or does not mention AGENTS.md\n'
        failures=$((failures + 1))
    fi

    if [ -r "$project_dir/.llm/index.md" ] && [ ! -L "$project_dir/.llm/index.md" ]; then
        printf 'OK:   .llm/index.md is project-owned\n'
    else
        printf 'FAIL: .llm/index.md is missing, unreadable, or is a symlink\n'
        failures=$((failures + 1))
    fi

    for relative_path in $shared_paths; do
        project_path=$project_dir/$relative_path
        canonical_path=$system_dir/$relative_path

        if [ "$project_dir" = "$system_dir" ]; then
            if [ -r "$canonical_path" ]; then
                printf 'OK:   %s is the canonical file\n' "$relative_path"
            else
                printf 'FAIL: canonical %s is unreadable\n' "$relative_path"
                failures=$((failures + 1))
            fi
            continue
        fi

        if [ ! -L "$project_path" ]; then
            printf 'FAIL: %s is not a symlink\n' "$relative_path"
            failures=$((failures + 1))
            continue
        fi

        project_target=$(resolve_path "$project_path") || project_target=''
        canonical_target=$(resolve_path "$canonical_path") || canonical_target=''

        if [ -n "$project_target" ] && [ "$project_target" = "$canonical_target" ]; then
            printf 'OK:   %s -> %s\n' "$relative_path" "$project_target"
        else
            printf 'FAIL: %s resolves to %s\n' "$relative_path" "${project_target:-(broken link)}"
            printf '      expected %s\n' "$canonical_target"
            failures=$((failures + 1))
        fi
    done
done

printf '%s\n' '------------------------------------------------------------'
if [ "$checked" -eq 0 ]; then
    printf 'FAIL: no projects were checked\n'
    exit 1
fi

if [ "$failures" -eq 0 ]; then
    printf 'PASS: %s project(s) checked; all links are consistent.\n' "$checked"
    exit 0
fi

printf 'FAIL: %s problem(s) found in %s checked project(s).\n' "$failures" "$checked"
exit 1
