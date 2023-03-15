#!/bin/bash

set -e
ARCH=${1:-arm64}

rm -rf registry/{cri,Kubefile,opt,scripts/common.sh}
rm -rf docker/{cri,Kubefile,opt,scripts/common.sh}
rm -rf cri-dockerd/{cri,Kubefile,opt,scripts/common.sh,bin}
rm -rf sealos/{cri,Kubefile,opt,scripts/common.sh,images,registry}
rm -rf tools/Kubefile
rm -rf k8s/{cri,Kubefile,opt,scripts/common.sh,bin,registry}
rm -rf containerd/{cri,Kubefile,opt,scripts/common.sh,bin}
rm -rf crun/{cri,Kubefile,opt,scripts/common.sh,bin}
rm -rf runc/{cri,Kubefile,opt,scripts/common.sh,bin}
rm -rf cri-o/{cri,Kubefile,opt,scripts/common.sh,bin}


pushd "registry" && {
  echo "build registry"
  bash init.sh ${ARCH} 2.8.1
  sealos build -t dev-registry:2.8.1-${ARCH} .
}
popd

pushd "sealos" && {
  echo "build sealos"
  bash init.sh ${ARCH} 4.1.6
  sealos build --compress -t dev-sealos:4.1.6-${ARCH} .
}
popd

pushd "tools" && {
  echo "build tools"
  bash init.sh ${ARCH}
  sealos build -t dev-tools:latest-${ARCH} .
}
popd

pushd "docker" && {
  echo "build docker"
  bash init.sh ${ARCH} 20.10.23
  sealos build -t dev-docker:20.10.23-${ARCH} .
}
popd

pushd "cri-dockerd" && {
  echo "build cri-dockerd"
  bash init.sh ${ARCH} 0.2.6
  sealos build -t dev-cri-dockerd:0.2.6-${ARCH} .
}
popd

pushd "k8s" && {
  echo "build k8s"
  bash init.sh ${ARCH} 1.23.17 1.23.0
  sealos build --compress --debug -t dev-k8s:1.23.17-${ARCH} .
}
popd

pushd "containerd" && {
  echo "build containerd"
  bash init.sh ${ARCH} 1.6.19
  sealos build --debug -t dev-containerd:1.6.19-${ARCH} .
}
popd

pushd "runc" && {
  echo "build runc"
  bash init.sh ${ARCH} 1.1.4
  sealos build --debug -t dev-runc:1.1.4-${ARCH} .
}
popd


pushd "crun" && {
  echo "build crun"
  bash init.sh ${ARCH} 1.8.1
  sealos build --debug -t dev-crun:1.8.1-${ARCH} .
}
popd

pushd "cri-o" && {
  echo "build cri-o"
  bash init.sh ${ARCH} 1.23.5
  sealos build --debug -t dev-crio:1.23.5-${ARCH} .
}
popd

sealos merge --platform linux/${ARCH} -t dev-merge-docker-k8s:1.23.17-${ARCH} dev-k8s:1.23.17-${ARCH} dev-cri-dockerd:0.2.6-${ARCH} dev-docker:20.10.23-${ARCH} dev-sealos:4.1.6-${ARCH} dev-registry:2.8.1-${ARCH} dev-tools:latest-${ARCH}
sealos merge --platform linux/${ARCH} -t dev-merge-containerd-k8s:1.23.17-${ARCH} dev-k8s:1.23.17-${ARCH} dev-containerd:1.6.19-${ARCH} dev-runc:1.1.4-${ARCH}  dev-sealos:4.1.6-${ARCH} dev-registry:2.8.1-${ARCH} dev-tools:latest-${ARCH}
sealos merge --platform linux/${ARCH} -t dev-merge-crio-k8s:1.23.17-${ARCH} dev-k8s:1.23.17-${ARCH} dev-crio:1.23.5-${ARCH} dev-crun:1.8.1-${ARCH}   dev-sealos:4.1.6-${ARCH} dev-registry:2.8.1-${ARCH} dev-tools:latest-${ARCH}
