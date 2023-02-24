#!/bin/bash
#
# Copyright (C) 2023 Android-Generic Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

top_dir=`pwd`
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
loc_man="${top_dir}/.repo/local_manifests"
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp/"
config_type="$1"
popt=0
# source $rompath/vendor/$vendor_path/ag-core/gui/easybashgui
source $ag_vendor_path/core-menu/includes/easybashgui
# include $rompath/vendor/$vendor_path/ag-core/gui/easybashgui

SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
rompath="$(dirname "$SCRIPT_PATH")"
echo -e "SCRIPT_PATH: $SCRIPT_PATH"
echo -e "rompath: $rompath"

echo -e "ag_vendor_path: $ag_vendor_path"
echo -e "temp_path: $temp_path"
echo -e "targetspath: $targetspath"
echo -e "CURRENT_pc_MANIFEST_PATH: $CURRENT_pc_MANIFEST_PATH"
# manifests_url="https://raw.githubusercontent.com/android-generic/vendor_ag/unified/configs/pc"
base_manifests_path="$CURRENT_pc_MANIFEST_PATH"
echo -e "CURRENT_pc_PATCHES_PATH: $CURRENT_pc_PATCHES_PATH"
echo -e "CURRENT_TARGET_PATH: $CURRENT_TARGET_PATH"

echo -e "variables set"

echo -e "Setting up local_manifests"
mkdir -p ${loc_man}

# Parse available manifest options
preManifestsString=()
preManifestsString="$(cd $base_manifests_path && dirs=(*/); echo "${dirs[@]%/}" && cd $rompath)"

echo -e "preManifestsString: $preManifestsString"
manifestsStringArray=($preManifestsString)
for m in $preManifestsString; do
    manifestsString="$manifestsString $m"
done
echo -e "manifestsString: $manifestsString"

ok_message "Please choose from available base types on the next screen."
while :
do
    menu $manifestsString
    answer=$(0< "${dir_tmp}/${file_tmp}" )
    #
    echo -e "answer: ${answer}"
    for ms in $manifestsString ; do
        echo -e "ms: $ms"
        if [ "*${answer}*" = "*${ms}*" ]; then
        notify_message "Selected \"${ms}\" ..."
        # notify_change "${i}"
        manifests_path="$base_manifests_path/${ms}"
        echo -e "manifests_path: $manifests_path"
        
        echo -e ${reset}""${reset}
        echo -e ${green}"Placing manifest fragments..."${reset}
        echo -e ${reset}""${reset}
        cp -fpr ${manifests_path}/*.xml "${loc_man}/"

        echo -e ${reset}""${reset}
        echo -e ${teal}"INFO: Cleaning up remove manifest entries"${reset}
        echo -e ${reset}""${reset}
        while IFS= read -r rpitem; do
            if [[ $rpitem == *"remove-project"* ]]; then
                rpitem_trimmed="$(echo "$rpitem" | xargs)"
                if grep -qRlZ "$rpitem_trimmed" "${top_dir}/.repo/manifests/"; then
                    echo -e ${yellow}"WARN: ROM already includes: $rpitem"${reset}
                else
                    echo -e ${green}"INFO: Needed: $rpitem"${reset}
                    prefix="<remove-project name="
                    suffix=" />"
                    item=${rpitem_trimmed#"$prefix"}
                    item=${item%"$suffix"}
                    if ! grep -qRlZ "$item" "${top_dir}/.repo/manifests/"; then
                        sed -e "$item"'d' "${loc_man}/01-removes.xml"
                    fi
                fi
            fi
        done < "${loc_man}/01-removes.xml"

        echo -e ${reset}""${reset}
        echo -e ${green}"Manifest generation complete. Files have been copied to $rompath/.repo/local_manifests/"${reset}
        echo -e ${reset}""${reset}

        [[ $_ != $0 ]] && exit 0 2>/dev/null || return 0 2>/dev/null;
        fi
    done
    if [ "${answer}" = "" ]; then
        exit
    fi
done

