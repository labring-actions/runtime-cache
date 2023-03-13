#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
readonly ARCH=${1:-amd64}
readonly VERSION=${2:-19.03.15}

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-docker:$VERSION-$ARCH
MAINTAINER sealos
LABEL check="check.sh" \
      auth="auth.sh" \
      merge.sealos.io.type.docker="$VERSION"
ENV criData=/var/lib/docker \
    criDockerdData=/var/lib/cri-dockerd \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd \
    criCgroupdriver=systemd
COPY . .
EOF
