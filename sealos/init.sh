#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly VERSION=${2:-4.1.6}

rm -rf /tmp/runtime-cache/sealos
mkdir -p "cri"
mkdir -p "opt"
mkdir -p "images/shim"
mkdir -p "/tmp/runtime-cache/sealos/$ARCH"
##GHPROXY=https://ghproxy.com/
pushd "/tmp/runtime-cache/sealos/$ARCH" && {
  wget -O sealos.tar.gz ${GHPROXY}https://github.com/labring/sealos/releases/download/v${VERSION}/sealos_${VERSION}_linux_${ARCH}.tar.gz
}
popd

pushd "cri" && {
  tar -zxvf /tmp/runtime-cache/sealos/$ARCH/sealos.tar.gz image-cri-shim
}
popd

pushd "opt" && {
  tar -zxvf /tmp/runtime-cache/sealos/$ARCH/sealos.tar.gz sealctl
}
popd

LvscareImage="ghcr.io/labring/lvscare:v${VERSION}"

echo $LvscareImage >  images/shim/lvscareImage

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
