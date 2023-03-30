#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}
readonly VERSION=${2?}

readonly MODULE=${PWD##*/}
cp -a ../scripts/common.sh scripts
case $MODULE in
registry)
  cp -a ../scripts/untar-registry.sh scripts
  cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-distribution:$VERSION-$ARCH
LABEL merge.sealos.io.type.$MODULE="$VERSION"
MAINTAINER sealos
EOF
  ;;
k8s)
  cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-kubernetes:$VERSION-$ARCH
LABEL merge.sealos.io.type.kube="$VERSION"
MAINTAINER sealos
EOF
  ;;
*)
  cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-$MODULE:$VERSION-$ARCH
LABEL merge.sealos.io.type.$MODULE="$VERSION"
MAINTAINER sealos
EOF
  ;;
esac

case $MODULE in
containerd)
  cat <<EOF >>"Kubefile"
LABEL check="check.sh"
ENV criData=/var/lib/containerd \
    criContainerdData=/run/containerd \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd \
    criSystemdCgroup=true \
    criDisableApparmor=false \
    SEALOS_SYS_CRI_ENDPOINT=/run/containerd/containerd.sock
COPY . .
EOF
  ;;
cri-dockerd)
  cat <<EOF >>"Kubefile"
ENV criDockerdData=/var/lib/cri-dockerd \
    SEALOS_SYS_CRI_ENDPOINT=/var/run/cri-dockerd.sock
COPY . .
EOF
  ;;
cri-o)
  cat <<EOF >>"Kubefile"
LABEL check="check.sh"
ENV criData=/var/lib/crio \
    criCRIOData=/run/crio \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd \
    criCgroupdriver=systemd \
    criDisableApparmor=false \
    SEALOS_SYS_CRI_ENDPOINT=/var/run/crio/crio.sock
COPY . .
EOF
  ;;
crun)
  cat <<EOF >>"Kubefile"
ENV SEALOS_SYS_CRI_RUNTIME=crun
COPY . .
EOF
  ;;
docker)
  cat <<EOF >>"Kubefile"
LABEL check="check.sh"
ENV criData=/var/lib/docker \
    criDockerdData=/var/lib/cri-dockerd \
    registryDomain=sealos.hub \
    registryPort=5000 \
    registryUsername=admin \
    registryPassword=passw0rd \
    criCgroupdriver=systemd
COPY . .
EOF
  ;;
k8s)
  PauseVersion=$(wget -qO- "https://github.com/kubernetes/kubernetes/raw/v$VERSION/cmd/kubeadm/app/constants/constants.go" | grep "PauseVersion = " | awk -F\" '{print $(NF-1)}')
  cat <<EOF >>"Kubefile"
LABEL init="init-runtime.sh && bash init-cri.sh && bash init.sh" \
      clean="clean.sh && bash clean-cri.sh && bash clean-runtime.sh" \
      sealos.io.type="rootfs" \
      sealos.io.version="v1beta2" \
      sealos.io.runtime="$MODULE" \
      version="v$VERSION" \
      vip="\\\$defaultVIP"
ENV SEALOS_SYS_SANDBOX_IMAGE=registry.k8s.io/pause:$PauseVersion \
    defaultVIP=10.103.97.2
COPY --from=ghcr.io/labring-actions/cache-cri-tools:$(
    for tag in $(git ls-remote --refs --sort="version:refname" --tags "https://github.com/kubernetes-sigs/cri-tools.git" | cut -d/ -f3- | grep -E "^v[0-9.]+$" |
      grep "${VERSION%.*}" | sort -r); do
      if curl -sL "https://github.com/kubernetes-sigs/cri-tools/releases/tag/$tag" | grep Assets >/dev/null; then
        cut -dv -f2 <<<"$tag"
        break
      fi
    done
  )-$ARCH . .
COPY . .
EOF
  ;;
registry)
  cat <<EOF >>"Kubefile"
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
  ;;
runc)
  cat <<EOF >>"Kubefile"
ENV SEALOS_SYS_CRI_RUNTIME=runc
COPY . .
EOF
  ;;
sealos)
  cat <<EOF >>"Kubefile"
LABEL image="ghcr.io/labring/lvscare:v${VERSION}"
COPY . .
EOF
  ;;
tools)
  cat <<EOF >"Kubefile"
FROM scratch
MAINTAINER sealos
COPY $ARCH/ .
EOF
  ;;
esac

rm -f "$0"
