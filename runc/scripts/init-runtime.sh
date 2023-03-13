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
source common.sh
mkdir -p /opt/containerd && tar -zxf ../modules/libseccomp.tar.gz -C /opt/containerd
echo "/opt/containerd/lib" >/etc/ld.so.conf.d/containerd.conf
ldconfig
# shellcheck disable=SC2046
cp ../modules/runc /usr/bin/
chmod a+x /usr/bin/runc
logger "init container runtime runc success"
