#!/bin/sh

set -eu

projectsFile=${projectsFile:-${PROJECTS_FILE:-"$HOME/.config/ray/projects.tsv"}}
projectsRoot=${projectsRoot:-${PROJECTS_ROOT:-"$HOME/eclipse-workspace"}}

usage() {
    cat <<'EOF'
Usage:
  check-project-paths.sh [FILE]

Reports observed project characteristics from the registry. Missing optional
features are not failures. The command exits nonzero only when the registry
cannot be read or contains an invalid name/path entry.

Environment:
  projectsFile  Registry file. Defaults to ~/.config/ray/projects.tsv.
  projectsRoot  Base used only for legacy relative registry paths.
EOF
}

case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    --*)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
esac

if [ "$#" -gt 1 ]; then
    usage >&2
    exit 2
fi

registry=${1:-$projectsFile}

[ -r "$registry" ] || {
    echo "Cannot read project registry: $registry" >&2
    exit 2
}

resolvePath() {
    value=$1
    case "$value" in
        "~") printf '%s\n' "$HOME" ;;
        "~/"*) printf '%s/%s\n' "$HOME" "${value#??}" ;;
        /*|[A-Za-z]:/*) printf '%s\n' "$value" ;;
        *) printf '%s/%s\n' "$projectsRoot" "$value" ;;
    esac
}

buildKind() {
    directory=$1
    if [ -f "$directory/gradlew" ] || [ -f "$directory/build.gradle" ] || [ -f "$directory/build.gradle.kts" ]; then
        printf 'gradle'
    elif [ -f "$directory/pom.xml" ]; then
        printf 'maven'
    elif [ -f "$directory/Makefile" ] || [ -f "$directory/makefile" ]; then
        printf 'make'
    else
        printf 'none'
    fi
}

yesNo() {
    if [ "$1" = true ]; then printf 'yes'; else printf 'no'; fi
}

printf '%-14s %-7s %-5s %-7s %-8s %-7s %-6s %-6s %s\n' \
    NAME EXISTS GIT ECLIPSE BUILD AGENTS ENVRC HOME PATH

tab=$(printf '\t')
invalid=0

awk -F "$tab" 'NR > 1 { print $1 "|" $2 }' "$registry" |
while IFS='|' read -r name value; do
    if [ -z "$name" ] || [ -z "$value" ]; then
        echo "Invalid registry entry: $name|$value" >&2
        invalid=1
        continue
    fi

    path=$(resolvePath "$value")

    exists=false
    git=false
    eclipse=false
    agents=false
    envrc=false
    homePage=false
    build=missing

    if [ -d "$path" ]; then
        exists=true
        [ -e "$path/.git" ] && git=true
        [ -f "$path/.project" ] && eclipse=true
        [ -f "$path/AGENTS.md" ] && agents=true
        [ -f "$path/.envrc" ] && envrc=true
        [ -f "$path/project-home.html" ] && homePage=true
        build=$(buildKind "$path")
    fi

    printf '%-14s %-7s %-5s %-7s %-8s %-7s %-6s %-6s %s\n' \
        "$name" "$(yesNo "$exists")" "$(yesNo "$git")" "$(yesNo "$eclipse")" \
        "$build" "$(yesNo "$agents")" "$(yesNo "$envrc")" "$(yesNo "$homePage")" "$path"
done

exit "$invalid"
