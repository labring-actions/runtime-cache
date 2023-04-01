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
readonly module_files=../modules/moby.files
source common.sh
check_service stop docker
rm -rf /etc/docker/daemon.json
rm -rf /etc/systemd/system/docker.service
rm -rf ${criData}
awk '{printf "/usr/bin/%s\n",$1}' "$module_files" | xargs rm -fv
ip link delete docker0
logger "clean docker success"
