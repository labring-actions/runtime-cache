#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}
readonly VERSION=${2:-2.8.1}

readonly MODULE=${PWD##*/}
cp -a ../scripts/common.sh scripts
cp -a ../scripts/untar-registry.sh scripts

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-distribution:$VERSION-$ARCH
LABEL merge.sealos.io.type.$MODULE="$VERSION"
LABEL init-registry="init-registry.sh" \
      clean-registry="clean-registry.sh"
ENV registryData=/var/lib/registry \
    registryConfig=/etc/registry \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd
COPY . .
EOF
