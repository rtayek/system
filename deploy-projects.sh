#!/bin/sh

set -eu

scriptDir=$(CDPATH= cd "$(dirname "$0")" && pwd)
sourceFile="$scriptDir/projects.tsv"
projectsFile=${projectsFile:-${PROJECTS_FILE:-"$HOME/.config/ray/projects.tsv"}}
targetDir=$(dirname "$projectsFile")
tempFile="$targetDir/projects.tsv.tmp.$$"

sh "$scriptDir/check-projects.sh" --source-only "$sourceFile"
mkdir -p "$targetDir"
trap 'rm -f "$tempFile"' 0 1 2 15
cp "$sourceFile" "$tempFile"
mv "$tempFile" "$projectsFile"
trap - 0 1 2 15

if ! cmp -s "$sourceFile" "$projectsFile"; then
    echo "Deployment verification failed: $projectsFile" >&2
    exit 1
fi

echo "Deployed project registry: $projectsFile"
