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

check_registry_port_inuse() {
    portOut="$(../opt/lsof -i:"${1}")"
    if [ -n "$portOut" ]; then
      error "Port: ${1} occupied. Please turn off registry service."
    fi
}

check_registry_port_inuse 5001
check_registry_port_inuse $registryPort

mkdir -p "$registryData" "$registryConfig"

tar -C /usr/bin/ -zxvf ../modules/distribution registry
chmod a+x  /usr/bin/registry
cp -a ../etc/registry.service /etc/systemd/system/

cp -a ../etc/registry_config.yml "$registryConfig"
cp -a ../etc/registry_htpasswd "$registryConfig"

check_service start registry
check_status registry

logger "init registry success"
