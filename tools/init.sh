#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}

cat <<EOF >"$ARCH/Kubefile"
FROM scratch
COPY . .
EOF
