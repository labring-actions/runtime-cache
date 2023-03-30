#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
echo "build ... ${PWD##*/}"

readonly ARCH=${1:-arm64}

git clean -df 2>/dev/null || true

cat <<EOF | sed "/^$/d" >modules.text
1 1000 containerd:1.6.19

1 2000 docker:23.0.2
2 2000 cri-dockerd:0.2.6

1 3000 cri-o:1.24.4

9 3000 crun:1.8.3
9 1000 2000 runc:1.1.5
9 1000 2000 3000 sealos:4.2.0-alpha2
0 1000 2000 3000 k8s:1.24.12
5 1000 2000 3000 registry:2.8.1
EOF
sort -n modules.text | awk '{print $NF}' >modules.txt
grep -v ^$ modules.txt |
  while read -r module; do
    MODULE=${module%:*}
    VERSION=${module#*:}
    if [ -s module.init ]; then
      cp module.init "$MODULE/init.sh"
    fi
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

grep "^1 " modules.text | awk '{print $NF}' | awk -F: '{print $1}' |
  while read -r cri; do
    case $cri in
    containerd)
      grep "1000 " modules.text | sort -n | awk '{print $NF}' | while read -r module; do echo "$module-$ARCH"; done
      ;;
    docker)
      grep "2000 " modules.text | sort -n | awk '{print $NF}' | while read -r module; do echo "$module-$ARCH"; done
      ;;
    cri-o)
      grep "3000 " modules.text | sort -n | awk '{print $NF}' | while read -r module; do echo "$module-$ARCH"; done
      ;;
    esac | tee >merge.images
    cat merge.images
    # shellcheck disable=SC2046
    sudo sealos merge --platform "linux/$ARCH" -t "${2:-ghcr.io/labring-actions}/dev-merge-$cri-$(grep "^0 " modules.text | awk '{print $NF}')-$ARCH" $(xargs <merge.images)
  done

sudo sealos images | grep none | awk '{print $3}' | xargs sealos rmi >/dev/null || true
