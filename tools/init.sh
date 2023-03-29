#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}

cat <<EOF >"Kubefile"
FROM scratch
MAINTAINER sealos
COPY $ARCH/ .
EOF
