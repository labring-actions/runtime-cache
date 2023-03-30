#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}
readonly VERSION=${2:-4.1.6}

readonly MODULE=${PWD##*/}
cp -a ../scripts/common.sh scripts
cp -a ../tools/"$ARCH"/ .

  cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-$MODULE:$VERSION-$ARCH
LABEL merge.sealos.io.type.$MODULE="$VERSION"
MAINTAINER sealos
LABEL image="ghcr.io/labring/lvscare:v${VERSION}"
COPY . .
EOF
