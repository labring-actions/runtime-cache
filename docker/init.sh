#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly VERSION=${2:-19.03.15}

rm -rf cri
rm -rf /tmp/runtime-cache/docker
mkdir -p "cri"
mkdir -p "/tmp/runtime-cache/docker/$ARCH"

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM scratch
MAINTAINER sealos
LABEL check="check.sh" \
      auth="auth.sh" \
      merge.sealos.io.type.docker="$VERSION" \
      merge.sealos.io.type.cri-dockerd="$DOCKERD_VERSION"
ENV criData=/var/lib/docker \
    criDockerdData=/var/lib/cri-dockerd \
    SEALOS_SYS_CRI_ENDPOINT=/var/run/cri-dockerd.sock \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd
COPY --from=ghcr.io/labring-actions/cache-docker:$VERSION-$ARCH  . .
COPY . .
EOF
