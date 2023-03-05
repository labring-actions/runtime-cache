#!/bin/bash

set -e
ARCH=${1:-arm64}

rm -rf registry/{cri,Kubefile,opt,scripts/common.sh}
rm -rf docker/{cri,Kubefile,opt,scripts/common.sh}
rm -rf cri-dockerd/{cri,Kubefile,opt,scripts/common.sh,bin}
rm -rf sealos/{cri,Kubefile,opt,scripts/common.sh,images,registry}
rm -rf tools/Kubefile
rm -rf k8s/{cri,Kubefile,opt,scripts/common.sh,bin}

pushd "registry" && {
  echo "build registry"
  bash init.sh ${ARCH} 2.8.1
  sealos build -t dev-registry:2.8.1 .
}
popd

pushd "sealos" && {
  echo "build sealos"
  bash init.sh ${ARCH} 4.1.6
  sealos build -t dev-sealos:4.1.6 .
}
popd

pushd "tools" && {
  echo "build tools"
  bash init.sh ${ARCH}
  sealos build -t dev-tools .
}
popd

pushd "docker" && {
  echo "build docker"
  bash init.sh ${ARCH} 20.10.23
  sealos build -t dev-docker:20.10.23 .
}
popd

pushd "cri-dockerd" && {
  echo "build cri-dockerd"
  bash init.sh ${ARCH} 0.2.6
  sealos build -t dev-cri-dockerd:0.2.6 .
}
popd

pushd "k8s" && {
  echo "build k8s"
  bash init.sh ${ARCH} 1.23.17 1.23.0
  sealos build -t dev-k8s:1.23.17 .
}
popd

sealos merge -t dev-merge-k8s:1.23.17 dev-k8s:1.23.17 dev-cri-dockerd:0.2.6 dev-docker:20.10.23 dev-tools dev-sealos:4.1.6 dev-registry:2.8.1 dev-tools
