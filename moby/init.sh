#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}
readonly VERSION=${2:-19.03.15}

readonly MODULE=${PWD##*/}
cp -a ../scripts/common.sh scripts

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-$MODULE:$VERSION-$ARCH
LABEL merge.sealos.io.type.$MODULE="$VERSION"
LABEL check="check.sh"
ENV criData=/var/lib/docker \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd \
    criCgroupdriver=systemd
COPY . .
EOF
