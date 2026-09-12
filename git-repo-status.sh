#!/bin/sh

# Report Git status and remote information for working-tree repositories
# found recursively beneath a directory.

set -u

script_version=2

usage() {
    printf 'Usage: %s [directory]\n' "${0##*/}"
    printf 'Searches directory (or the current directory) recursively.\n'
    printf 'Hidden subdirectories such as .claude and .cache are skipped.\n'
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

if [ "$#" -gt 1 ]; then
    usage >&2
    exit 2
fi

search_root=${1-.}

if [ ! -d "$search_root" ]; then
    printf 'Error: not a directory: %s\n' "$search_root" >&2
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    printf 'Error: git was not found in PATH.\n' >&2
    exit 1
fi

search_root=$(CDPATH= cd -- "$search_root" 2>/dev/null && pwd -P) || {
    printf 'Error: cannot access directory: %s\n' "$search_root" >&2
    exit 1
}

# A normal repository has a .git directory. A linked Git worktree has a
# .git file, so find both. Do not descend into Git's administrative data or
# into other hidden subdirectories such as .claude, .cache, and .gradle.
git_markers=$(find "$search_root" \
    \( -type d -name .git -prune -print \) -o \
    \( -type d -name '.*' ! -path "$search_root" -prune \) -o \
    \( -type f -name .git -print \) \
    2>/dev/null | LC_ALL=C sort -u)

if [ -z "$git_markers" ]; then
    printf 'No Git working-tree repositories found under: %s\n' "$search_root"
    exit 0
fi

printf '%s\n' "$git_markers" | while IFS= read -r git_marker; do
    repo=${git_marker%/.git}
    relative_repo=${repo#"$search_root"/}

    # Defensive second check: even if a particular find implementation does
    # not prune as expected, reject repositories beneath a hidden path.
    case "/$relative_repo/" in
        */.*/*)
            continue
            ;;
    esac

    printf '%s\n' '------------------------------------------------------------'
    printf 'Repository: %s\n' "$repo"

    if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf 'Status: unable to inspect this repository\n'
        continue
    fi

    branch=$(git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null) || branch=''
    if [ -n "$branch" ]; then
        printf 'Branch: %s\n' "$branch"
    else
        short_head=$(git -C "$repo" rev-parse --short HEAD 2>/dev/null) || short_head='unknown'
        printf 'Branch: detached at %s\n' "$short_head"
    fi

    tracking=$(git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) || tracking=''
    if [ -n "$tracking" ]; then
        printf 'Tracking upstream: %s\n' "$tracking"
    else
        printf 'Tracking upstream: (none)\n'
    fi

    remote=origin
    if ! git -C "$repo" config --get "remote.$remote.url" >/dev/null 2>&1; then
        remote=$(git -C "$repo" remote 2>/dev/null | sed -n '1p')
    fi

    if [ -n "$remote" ]; then
        remote_url=$(git -C "$repo" config --get "remote.$remote.url" 2>/dev/null) || remote_url=''
        if [ -n "$remote_url" ]; then
            printf 'Remote URL (%s): %s\n' "$remote" "$remote_url"
        else
            printf 'Remote URL: (none)\n'
        fi
    else
        printf 'Remote URL: (none)\n'
    fi

    printf 'Git status:\n'
    status=$(git -C "$repo" status --short --branch 2>&1)
    status_result=$?
    if [ "$status_result" -eq 0 ]; then
        printf '%s\n' "$status" | sed 's/^/  /'
    else
        printf '  unable to read status: %s\n' "$status"
    fi
done

printf '%s\n' '------------------------------------------------------------'
