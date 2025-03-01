#!/bin/bash
# Copyright © 2022 sealos.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
cd "$(dirname "$0")" >/dev/null 2>&1 || exit
source common.sh

check_k8s_port_inuse

tar -C /usr/bin/ -zxf ../modules/cri-tools crictl
[ -f ../etc/crictl.yaml ] && cp -a ../etc/crictl.yaml /etc

if ! bash init-shim.sh; then
  error "====init image-cri-shim failed!===="
fi

#need after cri-shim
crictl pull ${registryDomain}:${registryPort}/${SEALOS_SYS_SANDBOX_IMAGE}

if ! bash init-kube.sh; then
  error "====init kubelet failed!===="
fi

logger "init rootfs success"
