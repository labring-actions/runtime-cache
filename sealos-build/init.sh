#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
readonly ARCH=${1:-amd64}
readonly VERSION=${2:-4.1.6}

mkdir -p "cri"
mkdir -p "opt"

MOUNT_SEALOS=$(sudo sealos create --platform linux/$ARCH --short "ghcr.io/labring-actions/cache-sealos:$VERSION-$ARCH" 2>&1)

pushd "cri" && {
  tar -zxvf ${MOUNT_SEALOS}/modules/sealos image-cri-shim
  sudo chmod a+x image-cri-shim
}
popd

pushd "opt" && {
  tar -zxvf ${MOUNT_SEALOS}/modules/sealos sealctl
  sudo chmod a+x sealctl
}
popd

LvscareImage="ghcr.io/labring/lvscare:v${VERSION}"

cp -rf ${MOUNT_SEALOS}/registry registry


pushd "scripts" && {
  cp ../../scripts/common.sh .
}
popd

cat <<EOF >"Kubefile"
FROM scratch
MAINTAINER sealos
LABEL image="$LvscareImage" \
      merge.sealos.io.type.sealos="$VERSION"
COPY . .
EOF
