#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly VERSION=${2:-2.8}

rm -rf cri
rm -rf /tmp/runtime-cache/registry
mkdir -p "cri"
mkdir -p "/tmp/runtime-cache/registry/$ARCH"
pushd "cri" && {
  sudo sealos create --platform linux/$ARCH --short "docker.io/library/registry:$VERSION" &> /tmp/runtime-cache/registry/$ARCH/mount
  sudo cp $(cat /tmp/runtime-cache/registry/$ARCH/mount)/bin/registry .
  sudo chmod a+x registry
}
popd

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM scratch
MAINTAINER sealos
LABEL init-registry="init-registry.sh" \
      clean-registry="clean-registry.sh" \
      merge.sealos.io.type.registry="$VERSION"
ENV registryData=/var/lib/registry \
    registryConfig=/etc/registry \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd
COPY . .
EOF
