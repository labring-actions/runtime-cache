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
if ! command_exists cri-docker; then
  cp ../etc/cri-docker.service /etc/systemd/system/
  cp ../etc/cri-docker.socket /etc/systemd/system/
  tar --strip-components=1 -zxvf ../modules/cri-dockerd -C /usr/bin
  # shellcheck disable=SC2046
  chmod a+x $(tar -tf ../modules/cri-dockerd | while read -r binary; do echo "/usr/bin/${binary##*/}"; done | xargs)
fi
check_service start cri-docker
check_status cri-docker
logger "init docker success"
