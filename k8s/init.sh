#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
readonly ARCH=${1:-amd64}
readonly VERSION=${2:-1.25.0}
readonly CRICTL_VERSION=${3:-1.25.0}

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
  sudo sealos create --short "ghcr.io/labring-actions/cache-kubernetes:${VERSION}-$ARCH" &>mount
  sandboxImage=$(cat $(cat mount)/images/shim/DefaultImageList | grep pause)
  sandboxImage=${sandboxImage#*/}
}
popd

cat <<EOF >"Kubefile"
FROM scratch
MAINTAINER sealos
LABEL init="init-cri.sh && bash init.sh" \
      clean="clean.sh && bash clean-cri.sh" \
      merge.sealos.io.type.kube="$VERSION" \
      sealos.io.type="rootfs" \
      sealos.io.version="v1beta2" \
      version="v${VERSION}" \
      vip="\\\$defaultVIP"
ENV SEALOS_SYS_SANDBOX_IMAGE=${sandboxImage} \
    defaultVIP=10.103.97.2
COPY --from=ghcr.io/labring-actions/cache-cri-tools:${CRICTL_VERSION}-$ARCH . .
COPY . .
EOF
