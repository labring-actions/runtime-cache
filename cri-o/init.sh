#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
readonly ARCH=${1:-amd64}
readonly VERSION=${2:-1.23.5}

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-cri-o:$VERSION-$ARCH
MAINTAINER sealos
LABEL check="check.sh" \
      auth="auth.sh" \
      merge.sealos.io.type.cri-o="$VERSION"
ENV criData=/var/lib/crio \
    criCRIOData=/run/crio \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd \
    criCgroupdriver=systemd \
    criDisableApparmor=false \
    SEALOS_SYS_CRI_ENDPOINT=/var/run/crio/crio.sock
COPY . .
EOF
