#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}
readonly VERSION=${2:-1.6.19}

readonly MODULE=${PWD##*/}
cp -a ../scripts/common.sh scripts

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-$MODULE:$VERSION-$ARCH
LABEL merge.sealos.io.type.$MODULE="$VERSION"
MAINTAINER sealos
LABEL check="check.sh"
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
