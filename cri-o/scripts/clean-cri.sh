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
check_service stop crio
rm -rf /etc/crio
rm -rf /etc/systemd/system/crio.service
rm -rf ${SEALOS_SYS_CRI_ENDPOINT}
rm -rf ${criData}
rm -rf ${criCRIOData}
rm -rf /usr/bin/{crio,crio-status,conmon,pinns}
{
  rm -fv /etc/cni/net.d/*.conf
  rm -fv /opt/cni/bin/*
  ip link delete cni0
}

logger "clean crio success"
