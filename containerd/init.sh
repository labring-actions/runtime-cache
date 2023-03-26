#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
readonly ARCH=${1:-amd64}
readonly VERSION=${2:-1.6.19}

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-containerd:$VERSION-$ARCH
MAINTAINER sealos
LABEL check="check.sh" \
      merge.sealos.io.type.containerd="$VERSION"
ENV criData=/var/lib/containerd \
    criContainerdData=/run/containerd \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd \
    criSystemdCgroup=true \
    criDisableApparmor=false \
    SEALOS_SYS_CRI_ENDPOINT=/run/containerd/containerd.sock
COPY . .
EOF
