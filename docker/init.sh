#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
export readonly ARCH=${1:-amd64}
export readonly VERSION=${2:-19.03.10}
export readonly DOCKERD_VERSION=${3:-0.3.1}

rm -rf cri
rm -rf /tmp/runtime-cache/docker
mkdir -p "cri"
mkdir -p "/tmp/runtime-cache/docker/$ARCH"

setup_verify_arch() {
    case $ARCH in
        amd64)
            DOCKER_ARCH=x86_64
            ;;
        arm64)
            DOCKER_ARCH=aarch64
            ;;
        *)
            fatal "Unsupported architecture $ARCH"
    esac
}

setup_verify_arch

pushd "cri" && {
  wget -O docker.tgz https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${VERSION}.tgz
  wget -O cri-dockerd.tgz https://github.com/Mirantis/cri-dockerd/releases/download/v${DOCKERD_VERSION}/cri-dockerd-${DOCKERD_VERSION}.${ARCH}.tgz
}
popd

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
COPY . .
EOF
