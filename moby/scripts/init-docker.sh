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
if ! command_exists docker; then
  lsb_dist=$(get_distribution)
  lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
  echo "current system is $lsb_dist"
  case "$lsb_dist" in
  alios)
    ip link add name docker0 type bridge
    ip addr add dev docker0 172.17.0.1/16
    ;;
  esac

  [ -d /etc/docker/ ] || mkdir /etc/docker/ -p
  cp ../etc/docker.service /etc/systemd/system/
  tar --strip-components=1 -zxvf ../modules/moby -C /usr/bin

  awk '{printf "/usr/bin/%s\n",$1}' "$module_files" | while read -r file; do
    if file "$file" | grep -E "(executable|/ld-)" | awk -F: '{print $1}' | grep -v .so; then
      chmod a+x "$file"
      chown "0:0" "$file"
    else
      echo "$file(not binary)"
    fi
  done

  cp ../etc/daemon.json /etc/docker
fi
disable_selinux
check_service start docker
check_status docker
logger "init docker success"