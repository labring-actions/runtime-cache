#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-arm64}
readonly REPO=${2:-ghcr.io/labring-actions}

git clean -df 2>/dev/null || true

cat <<EOF | sed "/^$/d" >modules.text
1 1000 containerd:1.6.20

1 2000 moby:23.0.2
2 2000 cri-dockerd:0.2.6

1 3000 cri-o:1.24.4

3 3000 crun:1.8.3
3 1000 2000 runc:1.1.5

0 1000 2000 3000 k8s:1.24.12
5 1000 2000 3000 registry:2.8.1
5 1000 2000 3000 sealos:4.2.0-alpha2
5 1000 2000 3000 tools:scratch
EOF
sort -n modules.text | awk '{print $NF}' >modules.txt
declare -a concurrencyQueue
grep -v ^$ modules.txt |
  while read -r module; do
    MODULE=${module%:*}
    VERSION=${module#*:}
    bash "$MODULE/init.sh" "$ARCH" "$VERSION"
    case $MODULE in
    tools)
      sudo sealos build --platform "linux/$ARCH" -t "$module-$ARCH" "$MODULE/$ARCH"
      ;;
    *)
      sudo sealos build --platform "linux/$ARCH" -t "$module-$ARCH" --compress "$MODULE"
      ;;
    esac
  done
sudo find . -type f -name "compressed-*"

grep "^1 " modules.text | awk '{print $NF}' | awk -F: '{print $1}' |
  while read -r cri; do
    case $cri in
    containerd)
      grep "1000 " modules.text | sort -n | awk '{print $NF}' | while read -r module; do echo "$module-$ARCH"; done
      ;;
    moby)
      grep "2000 " modules.text | sort -n | awk '{print $NF}' | while read -r module; do echo "$module-$ARCH"; done
      ;;
    cri-o)
      grep "3000 " modules.text | sort -n | awk '{print $NF}' | while read -r module; do echo "$module-$ARCH"; done
      ;;
    esac | tee >merge.images
    cat merge.images
    case $cri in
    moby)
      cri=docker
      ;;
    cri-o)
      cri=crio
      ;;
    esac
    # shellcheck disable=SC2046
    sudo sealos merge --platform "linux/$ARCH" -t "from-$cri:$ARCH" \
      --label org.opencontainers.image.description="sealos(merge) rootfs image" \
      --label org.opencontainers.image.licenses="Apache 2.0" \
      --label org.opencontainers.image.source="https://github.com/labring/sealos" \
      $(xargs <merge.images)
    # https://github.com/labring/sealos/blob/main/pkg/buildimage/merge.go#L65
    sudo sealos merge --platform "linux/$ARCH" -t "$REPO/dev-merge-$cri-$(grep "^0 " modules.text | awk '{print $NF}')-$ARCH" \
      "tools:scratch-$ARCH" "from-$cri:$ARCH"
  done

sudo sealos images | grep localhost/
sudo sealos images | grep none | awk '{print $3}' | xargs sealos rmi >/dev/null || true
sudo sealos images | grep -v localhost/
