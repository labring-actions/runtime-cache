#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
readonly ARCH=${1:-amd64}
readonly VERSION=${2:-1.1.4}

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-runc:$VERSION-$ARCH
MAINTAINER sealos
LABEL init="init-runtime.sh && bash init-cri.sh && bash init.sh" \
      clean="clean.sh && bash clean-cri.sh && bash clean-runtime.sh" \
      merge.sealos.io.type.runc="$VERSION"
COPY . .
EOF
