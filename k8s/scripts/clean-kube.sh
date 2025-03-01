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
check_service stop kubelet
rm -f /usr/bin/conntrack
rm -f /usr/bin/kubelet-pre-start.sh
rm -f /usr/bin/kubelet-post-stop.sh
rm -f /usr/bin/kubeadm
rm -f /usr/bin/kubectl
rm -f /usr/bin/kubelet

rm -f /etc/sysctl.d/k8s.conf
rm -f /etc/systemd/system/kubelet.service
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /var/lib/kubelet/
logger "clean kubelet success"
