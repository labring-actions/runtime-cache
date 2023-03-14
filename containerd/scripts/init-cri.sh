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
readonly module_files=../modules/containerd.files
[ -d /etc/containerd/certs.d/ ] || mkdir /etc/containerd/certs.d/ -p
cp ../etc/containerd.service /etc/systemd/system/
tar -zxf ../modules/containerd -C /usr/
# shellcheck disable=SC2046
cp ../etc/config.toml /etc/containerd
mkdir -p /etc/containerd/certs.d/$registryDomain:$registryPort
cp ../etc/hosts.toml /etc/containerd/certs.d/$registryDomain:$registryPort

awk '{printf "/usr/bin/%s\n",$1}' "$module_files" | while read -r file; do
  if file "$file" | grep -E "(executable|/ld-)" | awk -F: '{print $1}' | grep -v .so; then
    chmod a+x "$file"
    chown "0:0" "$file"
  else
    echo "$file(not binary)"
  fi
done

check_service start containerd
check_status containerd
logger "init containerd success"
