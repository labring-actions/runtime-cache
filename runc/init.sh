#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}
readonly VERSION=${2:-1.1.4}

readonly MODULE=${PWD##*/}
cp -a ../scripts/common.sh scripts

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-$MODULE:$VERSION-$ARCH
LABEL merge.sealos.io.type.$MODULE="$VERSION"
ENV SEALOS_SYS_CRI_RUNTIME=runc
COPY . .
EOF
