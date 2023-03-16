#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
readonly ARCH=${1:-amd64}
readonly VERSION=${2:-1.8.1}

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-crun:$VERSION-$ARCH
MAINTAINER sealos
LABEL init="init-runtime.sh && bash init-cri.sh && bash init.sh" \
      clean="clean.sh && bash clean-cri.sh && bash clean-runtime.sh" \
      merge.sealos.io.type.crun="$VERSION"
ENV SEALOS_SYS_CRI_RUNTIME=crun
COPY . .
EOF
