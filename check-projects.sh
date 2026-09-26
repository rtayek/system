#!/bin/sh

set -eu

usage() {
    cat <<'EOF'
Usage:
  check-projects.sh [--source-only] [FILE]

Without --source-only, also verify that the deployed copy matches FILE.

Environment:
  projectsFile  Deployed registry. Defaults to ~/.config/ray/projects.tsv.
  PROJECTS_FILE Legacy spelling accepted during migration.
EOF
}

sourceOnly=false
case "${1:-}" in
    --source-only)
        sourceOnly=true
        shift
        ;;
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

scriptDir=$(CDPATH= cd "$(dirname "$0")" && pwd)
sourceFile=${1:-"$scriptDir/projects.tsv"}
projectsFile=${projectsFile:-${PROJECTS_FILE:-"$HOME/.config/ray/projects.tsv"}}

[ "$#" -le 1 ] || {
    usage >&2
    exit 2
}

[ -f "$sourceFile" ] || {
    echo "Missing project registry: $sourceFile" >&2
    exit 1
}

carriageReturn=$(printf '\r')
if LC_ALL=C grep -n "$carriageReturn" "$sourceFile" >/dev/null 2>&1; then
    echo "Project registry contains CR characters: $sourceFile" >&2
    exit 1
fi

tab=$(printf '\t')
awk -F "$tab" '
BEGIN {
    expected = "name\tpath\tport\tcolor\tchatgpt-url\tclaude-url"
    failures = 0
}
NR == 1 {
    if ($0 != expected) {
        print "Invalid header: " $0 > "/dev/stderr"
        failures = 1
    }
    next
}
NF != 6 {
    print "Line " NR " has " NF " fields; expected 6" > "/dev/stderr"
    failures = 1
    next
}
$1 == "" {
    print "Line " NR " has no project name" > "/dev/stderr"
    failures = 1
}
$2 == "" {
    print "Line " NR " has no project path" > "/dev/stderr"
    failures = 1
}
$1 != "" && seenName[$1]++ {
    print "Duplicate project name on line " NR ": " $1 > "/dev/stderr"
    failures = 1
}
$3 != "" && $3 !~ /^[0-9]+$/ {
    print "Invalid port on line " NR ": " $3 > "/dev/stderr"
    failures = 1
}
$3 != "" && seenPort[$3]++ {
    print "Duplicate port on line " NR ": " $3 > "/dev/stderr"
    failures = 1
}
$3 != "" && $4 == "" {
    print "Line " NR " has a port but no color" > "/dev/stderr"
    failures = 1
}
END {
    if (NR < 2) {
        print "Project registry has no records" > "/dev/stderr"
        failures = 1
    }
    exit failures
}
' "$sourceFile"

echo "Registry format is valid: $sourceFile"

if [ "$sourceOnly" = true ]; then
    exit 0
fi

[ -f "$projectsFile" ] || {
    echo "Deployed registry is missing: $projectsFile" >&2
    exit 1
}

if ! cmp -s "$sourceFile" "$projectsFile"; then
    echo "Deployed registry differs from source: $projectsFile" >&2
    exit 1
fi

echo "Deployed registry matches: $projectsFile"
