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
# prepare registry storage as directory
cd "$(dirname "$0")" || error "error for $0"

check_service stop registry
rm -f /etc/systemd/system/registry.service
rm -f  $(tar -tf ../modules/distribution | while read -r binary; do echo "/usr/bin/${binary##*/}"; done | xargs)

rm -rf "$registryData"
rm -rf "$registryConfig"
rm -f /etc/registry.yml

logger "clean registry success"
