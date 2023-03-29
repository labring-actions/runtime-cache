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
cp -rf ../etc/image-cri-shim.service /etc/systemd/system/
cp -rf ../etc/image-cri-shim.yaml /etc

mkdir -p ../cri ../opt
if ! ../cri/image-cri-shim --version; then
  tar -C ../cri -zxf ../modules/sealos image-cri-shim
fi
if ! ../opt/sealctl version --short; then
  tar -C ../opt -zxf ../modules/sealos sealctl
fi

cp -rf ../cri/image-cri-shim /usr/bin

check_service start image-cri-shim
check_status image-cri-shim

logger "init shim success"
