#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly VERSION=${2:-2.8.1}

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-distribution:$VERSION-$ARCH
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
