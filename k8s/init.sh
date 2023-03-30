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

if ! [[ "$PauseVersion" =~ ^[0-9.]+$ ]]; then
  echo "$PauseVersion"
  exit 1
fi

{
  IMAGE=ghcr.io/labring-actions/cache-kubernetes:$VERSION-$ARCH
  sudo cp -a "$(sudo sealos create --platform "linux/$ARCH" --short "$IMAGE")/"* .
  sudo rm -rf images
  IMAGE=ghcr.io/labring-actions/cache-cri-tools:$(
    for tag in $(git ls-remote --refs --sort="version:refname" --tags "https://github.com/kubernetes-sigs/cri-tools.git" | cut -d/ -f3- | grep -E "^v[0-9.]+$" |
      grep "${VERSION%.*}" | sort -r); do
      if curl -sL "https://github.com/kubernetes-sigs/cri-tools/releases/tag/$tag" | grep Assets >/dev/null; then
        cut -dv -f2 <<<"$tag"
        break
      fi
    done
  )-$ARCH
  sudo cp -a "$(sudo sealos create --platform "linux/$ARCH" --short "$IMAGE")/"* .
}

cat <<EOF >"Kubefile"
FROM scratch
LABEL merge.sealos.io.type.kube="$VERSION"
LABEL init="init-runtime.sh && bash init-cri.sh && bash init.sh" \
      clean="clean.sh && bash clean-cri.sh && bash clean-runtime.sh" \
      sealos.io.type="rootfs" \
      sealos.io.version="v1beta2" \
      sealos.io.runtime="$MODULE" \
      version="v$VERSION" \
      vip="\\\$defaultVIP"
ENV SEALOS_SYS_SANDBOX_IMAGE=pause:$PauseVersion \
    defaultVIP=10.103.97.2
COPY . .
EOF
