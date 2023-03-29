#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-arm64}

git clean -df 2>/dev/null || true

cat <<EOF | sed "/^$/d" >modules.txt
containerd:1.6.19

docker:20.10.23
cri-dockerd:0.2.6

cri-o:1.23.5

k8s:1.22.17
registry:2.8.1
crun:1.8.1
runc:1.1.5
sealos:4.2.0-alpha1
tools:latest
EOF

grep -v ^$ modules.txt |
  while read -r module; do
    MODULE=${module%:*}
    VERSION=${module#*:}
    #cp build-init.sh "$MODULE/init.sh"
    bash "$MODULE/init.sh" "$ARCH" "$VERSION"
    case $MODULE in
    k8s | sealos)
      sudo sealos build --platform "linux/$ARCH" -t "$module-$ARCH" --compress "$MODULE"
      ;;
    *)
      sudo sealos build --platform "linux/$ARCH" -t "$module-$ARCH" "$MODULE"
      ;;
    esac
  done

grep -E "(docker|containerd|cri-o):" modules.txt | awk -F: '{print $1}' |
  while read -r cri; do
    # shellcheck disable=SC2046
    sudo sealos merge --platform "linux/$ARCH" -t "${2:-ghcr.io/labring-actions}/dev-merge-$cri-$(grep k8s: modules.txt)-$ARCH" $(
      # k8s
      echo "$(grep "k8s:" modules.txt)-$ARCH"
      # cri
      case $cri in
      docker)
        grep -E "($cri|cri-dockerd):" modules.txt | while read -r module; do echo "$module-$ARCH"; done
        ;;
      *)
        grep -E "$cri:" modules.txt | while read -r module; do echo "$module-$ARCH"; done
        ;;
      esac
      # other
      grep -vE "(k8s|docker|cri-dockerd|containerd|cri-o):" modules.txt | while read -r module; do echo "$module-$ARCH"; done
    )
  done

sealos images | grep none | awk '{print $3}' | xargs sealos rmi >/dev/null || true
