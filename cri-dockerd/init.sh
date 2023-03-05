#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
readonly ARCH=${1:-amd64}
readonly VERSION=${2:-0.3.1}

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM scratch
MAINTAINER sealos
LABEL merge.sealos.io.type.cri-dockerd="$VERSION"
ENV criDockerdData=/var/lib/cri-dockerd \
    SEALOS_SYS_CRI_ENDPOINT=/var/run/cri-dockerd.sock
COPY --from=ghcr.io/labring-actions/cache-cri-dockerd:$VERSION-$ARCH  . .
COPY . .
EOF
