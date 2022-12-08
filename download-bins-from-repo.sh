#download bins from repo

#Copyright 2022 illumio
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

echo -n "Download bins from repo..."

dir=/illumio-repo/19.3.6/
mkdir --parents $dir
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/19.3/GA%20Releases/19.3.6+H2/pce/pkgs/illumio-pce-19.3.6-17289.H2.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/19.3/GA%20Releases/19.3.6+H2/pce/pkgs/UI/illumio-pce-ui-19.3.6.UI3-17283.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/19.3/GA%20Releases/19.3.8/ven/bundle/illumio-ven-bundle-19.3.8-6520.tar.bz2
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases-local/22.2/GA%20Releases/22.2.1/compatibility/illumio-release-compatibility-20-186.tar.bz2
echo -n "."

dir=/illumio-repo/21.2.7/
mkdir --parents $dir
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/21.2/GA%20Releases/21.2.7/pce/pkgs/illumio-pce-21.2.7-656.c8.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/21.2/GA%20Releases/21.2.7/pce/pkgs/UI/illumio-pce-ui-21.2.7.UI1-284.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/21.2/GA%20Releases/21.2.5/ven/bundle/illumio-ven-bundle-21.2.5-8017.tar.bz2
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/21.2/GA%20Releases/21.2.5/compatibility/illumio-release-compatibility-15-161.tar.bz2
echo -n "."

dir=/illumio-repo/21.5.34/
mkdir --parents $dir
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/21.5/GA%20Releases/21.5.34/pce/pkgs/illumio-pce-21.5.34-4.c8.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/21.5/GA%20Releases/21.5.34/pce/pkgs/UI/illumio-pce-ui-21.5.34.UI1-1.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/21.5/GA%20Releases/21.5.32/ven/bundle/illumio-ven-bundle-21.5.32-8533.tar.bz2
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/21.5/GA%20Releases/21.5.34/compatibility/illumio-release-compatibility-26-222.tar.bz2
echo -n "."

dir=/illumio-repo/22.2.30/
mkdir --parents $dir
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/22.2/GA%20Releases/22.2.30/pce/pkgs/illumio-pce-22.2.30-631.c8.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/22.2/GA%20Releases/22.2.30/pce/pkgs/UI/illumio-pce-ui-22.2.30.UI1-460.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/22.2/GA%20Releases/22.2.30/ven/bundle/illumio-ven-bundle-22.2.30-9138.tar.bz2
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/22.2/GA%20Releases/22.2.30/compatibility/illumio-release-compatibility-25-219.tar.bz2
echo -n "."

dir=/illumio-repo/22.5.0/
mkdir --parents $dir
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/22.5/GA%20Releases/22.5.0/pce/pkgs/illumio-pce-22.5.0-1002.c8.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/22.5/GA%20Releases/22.5.0/pce/pkgs/UI/illumio-pce-ui-22.5.0.UI1-1150.x86_64.rpm
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/22.5/GA%20Releases/22.5.0/ven/bundle/illumio-ven-bundle-22.5.0-9616.tar.bz2
echo -n "."
wget --quiet --timestamping --directory-prefix $dir $REPO/illumio-releases/22.5/GA%20Releases/22.5.0/compatibility/illumio-release-compatibility-29-233.tar.bz2
echo -n "."

#bin cleanup

versions="19.3.6 21.2.7 21.5.34 22.2.30 22.5.0"
dirs=$(ls /illumio-repo/)
for dir in $dirs; do
    if [[ "$versions" != *"$dir"* ]]; then
        rm -rf /illumio-repo/$dir
    fi
done
