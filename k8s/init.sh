#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-amd64}
readonly VERSION=${2:-1.25.0}

readonly MODULE=${PWD##*/}
cp -a ../scripts/common.sh scripts

PauseVersion=$(wget -qO- "https://github.com/kubernetes/kubernetes/raw/v$VERSION/cmd/kubeadm/app/constants/constants.go" | grep "PauseVersion = " | awk -F\" '{print $(NF-1)}')
cat <<EOF >"Kubefile"
FROM ghcr.io/labring-actions/cache-kubernetes:$VERSION-$ARCH
LABEL merge.sealos.io.type.kube="$VERSION"
MAINTAINER sealos
LABEL init="init-cri.sh && bash init.sh" \
      clean="clean.sh && bash clean-cri.sh" \
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
