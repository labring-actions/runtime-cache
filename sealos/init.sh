#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly VERSION=${2:-4.1.6}

rm -rf /tmp/runtime-cache/sealos
mkdir -p "cri"
mkdir -p "opt"
mkdir -p "/tmp/runtime-cache/sealos/$ARCH"

sudo sealos create --platform linux/$ARCH --short "ghcr.io/labring-actions/cache-sealos:$VERSION-$ARCH" &> /tmp/runtime-cache/sealos/$ARCH/mount

pushd "cri" && {
  tar -zxvf $(cat /tmp/runtime-cache/sealos/$ARCH/mount)/modules/sealos image-cri-shim
  sudo chmod a+x image-cri-shim
}
popd

pushd "opt" && {
  tar -zxvf $(cat /tmp/runtime-cache/sealos/$ARCH/mount)/modules/sealos sealctl
  sudo chmod a+x sealctl
}
popd

LvscareImage="ghcr.io/labring/lvscare:v${VERSION}"

pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM scratch
MAINTAINER sealos
LABEL image="$LvscareImage" \
      merge.sealos.io.type.sealos="$VERSION"
COPY --from=ghcr.io/labring-actions/cache-sealos:$VERSION-$ARCH  registry .
COPY . .
EOF
