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
# Use other network plugin, eg: calico.
{
  rm -fv /etc/cni/net.d/*.conf
  rm -fv /opt/cni/bin/*
  mkdir -p /etc/cni/net.d
  mkdir -p /opt/cni/bin
}

mkdir -p ../cri && tar -zxf ../modules/cri-o -C ../cri

# install crio
cp -rf ../cri/cri-o/bin/{conmon,crio,crio-status,pinns} /usr/bin/
# install cni
cp -rf ../cri/cri-o/cni-plugins/* /opt/cni/bin/
cp -rf ../etc/10-crio-bridge.conf /etc/cni/net.d/
# install crio config
mkdir -p /etc/crio/crio.conf.d
cp ../etc/99-crio.conf /etc/crio/crio.conf.d/
cp ../etc/crio.service /etc/systemd/system/
if ! [ -s /etc/containers/policy.json ];then
  mkdir -p /etc/containers && cp ../etc/policy.json /etc/containers
fi
cp ../etc/config.json /etc/crio

check_service start crio
check_status crio

logger "init crio success"
