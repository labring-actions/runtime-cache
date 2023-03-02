#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly VERSION=${2:-1.25.0}

rm -rf bin
rm -rf /tmp/runtime-cache/k8s
mkdir -p "bin"
mkdir -p "/tmp/runtime-cache/k8s/$ARCH"

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

sandboxImage=""

pushd "/tmp/runtime-cache/k8s/$ARCH" && {
  sudo sealos create --platform linux/$ARCH --short "ghcr.io/labring-actions/cache:kubernetes-v${VERSION}-$ARCH" &> mount
  sandboxImage=$(cat $(cat mount)/images/shim/DefaultImageList | grep pause )
}
popd

cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache:kubernetes-v${VERSION}-$ARCH
MAINTAINER sealos
LABEL init="init-cri.sh && bash init.sh" \
      clean="clean.sh && bash clean-cri.sh" \
      merge.sealos.io.type.kube="$VERSION" \
      sealos.io.type="rootfs" \
      sealos.io.version="v1beta1" \
      version="v${VERSION}" \
      vip="\\\$defaultVIP"
ENV SEALOS_SYS_SANDBOX_IMAGE=${sandboxImage} \
    defaultVIP=10.103.97.2
COPY . .
EOF
