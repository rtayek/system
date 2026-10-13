#!/bin/sh

# Verify the shared governing files in registered projects.

set -u

script_version=2
projectsFile=${projectsFile:-${PROJECTS_FILE:-"$HOME/.config/ray/projects.tsv"}}
projectsRoot=${projectsRoot:-${PROJECTS_ROOT:-"$HOME/eclipse-workspace"}}

usage() {
    printf 'Usage: %s [project ...]\n' "${0##*/}"
    printf '\n'
    printf 'With no project arguments, all paths are read from: %s\n' "$projectsFile"
    printf 'Arguments may be registered project names or explicit project paths.\n'
    printf '\n'
    printf 'Examples:\n'
    printf '  %s\n' "${0##*/}"
    printf '  %s system chatmap dotmdfiles\n' "${0##*/}"
    printf '  %s /d/projects/system /d/projects/chatmap\n' "${0##*/}"
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

if [ ! -f "$projectsFile" ]; then
    printf 'Error: project registry not found: %s\n' "$projectsFile" >&2
    exit 2
fi

resolvePath() {
    value=$1
    case "$value" in
        "~")
            printf '%s\n' "$HOME"
            ;;
        "~/"*)
            printf '%s/%s\n' "$HOME" "${value#??}"
            ;;
        /*|[A-Za-z]:/*)
            printf '%s\n' "$value"
            ;;
        *)
            printf '%s/%s\n' "$projectsRoot" "$value"
            ;;
    esac
}

registeredPath() {
    projectName=$1
    value=$(awk -F '\t' -v name="$projectName" 'NR > 1 && $1 == name { print $2; exit }' "$projectsFile")
    [ -n "$value" ] || return 1
    resolvePath "$value"
}

dotmdfilesDir=$(registeredPath dotmdfiles) || {
    printf 'Error: dotmdfiles is not registered in %s\n' "$projectsFile" >&2
    exit 2
}
syncScript=$dotmdfilesDir/bin/sync-project-files.sh

if [ ! -d "$dotmdfilesDir/.git" ] && [ ! -f "$dotmdfilesDir/.git" ]; then
    printf 'Error: dotmdfiles project is not a Git working tree: %s\n' "$dotmdfilesDir" >&2
    exit 2
fi

if [ ! -f "$syncScript" ]; then
    printf 'Error: synchronization checker is missing: %s\n' "$syncScript" >&2
    exit 2
fi

if [ "$#" -eq 0 ]; then
    tab=$(printf '\t')
    defaultProjects=$(awk -F "$tab" 'NR > 1 { print $1 }' "$projectsFile")
    if [ -z "$defaultProjects" ]; then
        printf 'Error: project registry has no projects: %s\n' "$projectsFile" >&2
        exit 2
    fi
    set -- $defaultProjects
fi

failures=0
checked=0

printf 'Registry: %s\n' "$projectsFile"
printf 'dotmdfiles: %s\n' "$dotmdfilesDir"

for projectValue do
    if projectDir=$(registeredPath "$projectValue" 2>/dev/null); then
        projectName=$projectValue
    else
        projectName=$projectValue
        projectDir=$(resolvePath "$projectValue")
    fi

    printf '%s\n' '------------------------------------------------------------'
    printf 'Project: %s\n' "$projectDir"

    if [ ! -d "$projectDir" ]; then
        printf 'WARN: project directory is absent; skipped\n'
        continue
    fi

    if [ ! -d "$projectDir/.git" ] && [ ! -f "$projectDir/.git" ]; then
        printf 'FAIL: not a Git working tree\n'
        failures=$((failures + 1))
        continue
    fi

    checked=$((checked + 1))

    if sh "$syncScript" --check "$projectDir"; then
        printf 'OK:   shared governing content matches canonical sources\n'
    else
        printf 'FAIL: shared governing content differs or is invalid\n'
        failures=$((failures + 1))
    fi

    for relativePath in AGENTS.md CLAUDE.md; do
        trackedMode=$(git -C "$projectDir" ls-files -s -- "$relativePath" |
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
